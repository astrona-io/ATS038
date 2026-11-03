# Overview: Pod Networking (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail. Break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The example workloads:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout` (Deployment, Service `scout`) | podinfo web application, Service port 80 to container port 9898 |
  | `starfleet` | `probe` (Deployment, Service `probe`) | go-httpbin echo application, Service port 80 to container port 8080 |
  | `starfleet` | `shuttle` | A client Pod with `curl`, used to send requests from inside the cluster |
  | `outpost` | `drifter` | A client Pod with `curl` that belongs to another team |

## Helpers

Paste this once in each new terminal. `from_shuttle` runs `curl` inside the `shuttle` Pod, so the request starts from a Pod network namespace and not from your machine.

```sh
from_shuttle() {
  kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "$@"
}
```

## Practice tasks

- List the Pods with `kubectl get pods -A -o wide` and write down each Pod IP and node. Compare the Pod IPs with the node IP.
- Read `/etc/resolv.conf` inside `shuttle` and explain the `search` line and `ndots`.
- Request `http://probe/get`, `http://probe.starfleet/get` and `http://probe.starfleet.svc.cluster.local/get` from `shuttle`. Then try the short name `probe` from `drifter` and explain the result.
- Delete the `probe` Pod, wait for the new one, and compare its Pod IP with the old one. Check that the Service name still works.
- Create a headless Service for `probe` and compare the DNS answer with the one for the normal Service.
- Look at the CoreDNS Deployment in `kube-system` and read its Corefile ConfigMap.
