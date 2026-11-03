# DNS Resolution And Debug Containers

Before a client can send a request to a Service, it must turn the Service name into an IP address. When that step fails, the application reports "could not resolve host" or "no such host", and the cause is not in the Service or in the pod behind it. This part explains how a pod resolves names, how to tell a DNS failure from a connection failure, and how to look inside a pod that has no debugging tools.

## How a pod resolves a name

Kubernetes runs a DNS server for the cluster, usually **CoreDNS**, as a Deployment in the `kube-system` namespace. A Service called `kube-dns` in that namespace gives it a stable address. The kubelet writes that address into the file `/etc/resolv.conf` of every pod that uses the default DNS policy (`ClusterFirst`). Look at the file in the `shuttle` pod:

<!-- astrona:playground:renew -->

```sh
kubectl exec deploy/shuttle -n starfleet -- cat /etc/resolv.conf
```

The file should contain a `nameserver` line with the cluster DNS address, a `search` line and `options ndots:5`. The search line lists the namespace first, then `svc.cluster.local` and `cluster.local`. The `ndots:5` option means that a name with fewer than five dots is first tried with each search suffix, and only then as written. This is why a short name works:

- `scout` becomes `scout.starfleet.svc.cluster.local` in the namespace of the pod that asks.
- `scout.starfleet` becomes `scout.starfleet.svc.cluster.local`, from any namespace.
- `scout.starfleet.svc.cluster.local` is the full name, which always works.

A short name only resolves in the namespace of the client. The `drifter` client in `outpost` that asks for `scout` looks for `scout.outpost.svc.cluster.local`, which does not exist. The error is a DNS failure, although the Service is healthy.

## Name failure or connection failure

The two failures look alike in an application log and need different fixes, so separate them with one tool. First ask the name server directly:

```sh
kubectl exec deploy/shuttle -n starfleet -- nslookup scout
```

The answer should name the DNS server and return the ClusterIP of the `scout` Service. If this step fails, no request has been sent yet, and the cause is in DNS: the name, the namespace, the search list or CoreDNS. If it succeeds, the name is not the problem, and you move to the Service and the endpoints. Then repeat the same request with `curl` and read its exit code. The code `6` means the host could not be resolved, `7` means the connection was refused and `28` means the request timed out:

```sh
kubectl exec deploy/drifter -n outpost -- sh -c "curl -s -o /dev/null -m 5 -w 'http=%{http_code}\n' http://scout; echo curl_exit=\$?"
```

From `outpost`, the short name should fail with exit code `6`. Repeat it with `http://scout.starfleet`, and it should return HTTP 200. The only change is the name, so the evidence points at the lookup and not at the pod, the Service or the network.

## The DNS server itself

If every name fails, or names fail in every namespace, check CoreDNS. List its pods, read their logs and read its configuration:

```sh
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl logs -n kube-system -l k8s-app=kube-dns
kubectl get configmap coredns -n kube-system -o yaml
```

The pods should be `Running` and Ready. The logs should be mostly quiet. Errors there name the upstream server that it cannot reach. The ConfigMap holds the `Corefile`. In it, the `kubernetes` block answers names under the cluster domain (`cluster.local`) from the Service and Pod objects in the API, and the `forward` line sends every other name to the upstream resolvers of the node. This split tells you where to look: a failure for `scout.starfleet` is a cluster problem, and a failure for an outside name such as `example.com` with working cluster names points at the `forward` line and the node's network.

CoreDNS answers from the API data it watches. If a Service was created a second ago, the record may need a moment. If CoreDNS cannot reach the API server, it keeps serving what it already has and stops learning about changes.

## Matching the DNS address to the Service

The `nameserver` address in `resolv.conf` must be the ClusterIP of the `kube-dns` Service. Compare them:

```sh
kubectl get service kube-dns -n kube-system
```

The `CLUSTER-IP` column should equal the `nameserver` value you saw in the pod. Pods that start after a change of the DNS Service address keep the old file until they are recreated, because the kubelet writes `resolv.conf` when it creates the pod. If the two values differ, the pod is the problem and not CoreDNS.

A worked reading of the evidence: a client gets "could not resolve host" for `scout`. `nslookup scout` fails in the client's namespace, but `nslookup scout.starfleet.svc.cluster.local` works. The name server is healthy and the Service exists, so the short name is the problem, and the client is in another namespace. If instead both fail, check the CoreDNS pods and the `resolv.conf` of the client. If both work and the connection still fails, the failure belongs to the Service and the endpoints.

## Records and DNS policy

CoreDNS answers three kinds of questions that matter for troubleshooting. A name `<service>.<namespace>.svc.cluster.local` gets an `A` record with the ClusterIP of the Service. A **headless Service** (`clusterIP: None`) has no ClusterIP, so its name returns the addresses of the ready pods instead. A named port gets an `SRV` record with the port number. If a client expects one stable address and the Service is headless, it receives a list, and the symptoms look like a random choice of pod.

The `dnsPolicy` field of a pod changes where `/etc/resolv.conf` comes from. `ClusterFirst`, the default, points the pod at CoreDNS. `Default` copies the resolver settings of the node, so cluster names no longer resolve. `None` lets the pod define everything in `dnsConfig`. A pod with `hostNetwork: true` uses the node's network and needs `ClusterFirstWithHostNet` to keep resolving cluster names. When one pod cannot resolve cluster names and its neighbours can, read the `dnsPolicy` and the `resolv.conf` of that pod first.

The `ndots:5` setting has a cost. A lookup for an outside name such as `example.com` has fewer than five dots, so the resolver first tries it with each search suffix and receives an error for each, before it asks for the real name. Those extra queries add delay and load on CoreDNS. Ending a name with a dot (`example.com.`) skips the search list.

## Debug containers

A production image often has no shell, no `curl` and no `nslookup`, so you cannot run these commands inside it. `kubectl debug` adds an **ephemeral container**: a temporary container that joins a running pod without restarting it. With `--target`, it also shares the process namespace of one container. It uses its own image, so you bring the tools:

```sh
kubectl debug -it deploy/shuttle -n starfleet --image=busybox:1.37.0 -- sh
```

In the shell, the pod's network namespace is shared, so `nslookup`, `wget` and `cat /etc/resolv.conf` show what the application sees, and `exit` ends the session. Ephemeral containers cannot be removed from the pod after they are added. They disappear with the pod, and their resource use is not limited by the pod spec. Another form of `kubectl debug` copies the pod with `--copy-to` so that you can change its command or image without touching the original, and a third form starts a debug pod on a node. When you only need to check one request, run `kubectl exec` with the tools that already exist in the image.

## What you know now

You can explain how a pod resolves a name, why a short name works only in its own namespace, separate a lookup failure from a refused connection and a timeout with `nslookup` and the exit code of `curl`, read the state of CoreDNS and attach a debug container to a pod. Together with the Service checklist, you can now follow any request from the client to the pod and name the hop where it stops.

## Common pitfalls

> [!WARNING]
> A short Service name resolves only in the client's own namespace. Do not conclude that a Service is down because a client in another namespace cannot resolve its short name. Do not test a Service with a name that bypasses DNS and then claim DNS works. A debug container cannot be removed from a pod and shares its network, so it shows the application's view, including its mistakes.
