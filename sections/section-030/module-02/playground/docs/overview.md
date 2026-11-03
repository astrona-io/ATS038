# Overview: Diagnosing Cluster Services (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with a healthy application and five broken pieces around it, and then waits. There is no task, no `astrona submit` and no pass or fail. Trace each request, fix what you find, break it again, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator. The cluster has CoreDNS in `kube-system`. It has no metrics server, so `kubectl top` does not work.
- Workloads:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout` and its Service | A healthy backend |
  | `starfleet` | `shuttle` | A client with `curl`, used to send test requests |
  | `outpost` | `drifter` | A client in another namespace |
  | `starfleet` | `probe` and its Service | The pod is healthy. The Service selector is `app=probes`, so the Service has no endpoints |
  | `starfleet` | `relay` and its Service | The pod is healthy. The Service sends traffic to port 8081, but the pod listens on 8080 |
  | `starfleet` | `lander` | Reads an environment variable from the ConfigMap `lander-config`, which does not exist |
  | `starfleet` | `gate` and its Service | The only pod fails its readiness probe |
  | `starfleet` | `archive` and the claim `ledger` | The claim names a StorageClass that does not exist |

## Helpers

Paste these once in each new terminal. `fetch_from` sends one request from a client pod and prints the exit code of `curl` and the HTTP status. Exit code 6 means the name did not resolve, 7 means the connection was refused and 28 means a timeout.

```sh
fetch_from() {
  kubectl -n "$1" exec "deploy/$2" -- sh -c "curl -s -o /dev/null -m 5 -w 'http=%{http_code}\n' '$3'; echo curl_exit=\$?"
}
```

Use it like this: `fetch_from starfleet shuttle http://scout`, `fetch_from outpost drifter http://scout.starfleet`.

## Practice tasks

- From `shuttle`, request each of `scout`, `probe`, `relay` and `gate`. Write down which ones fail and with which `curl` exit code before you open any other command.
- For `probe`, compare the Service selector with the labels of the pod, and list the EndpointSlice of the Service. Fix the Service.
- For `relay`, show that the EndpointSlice has an address and that the port in it is wrong. Fix the Service.
- For `gate`, show that the pod is listed as not ready in the EndpointSlice. Explain why that is correct behaviour.
- For `lander`, read the pod status and the event, create the ConfigMap and watch the pod start.
- For `archive`, follow the chain from the pod event to the claim to the StorageClass.
- From `drifter` in `outpost`, request `scout` by its short name and by its name with the namespace. Explain the difference with `/etc/resolv.conf`.
- Read the CoreDNS pods and logs in `kube-system`, then use `kubectl debug` to start a `busybox` container next to `shuttle`.
