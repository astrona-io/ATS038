# Overview: Services And External Access (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and then waits. There is no task, no `astrona submit` and no pass or fail.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- The example workloads:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout` (Deployment, Service `scout`) | podinfo web application, Service port 80 to container port 9898 |
  | `starfleet` | `probe` (Deployment, Service `probe`) | go-httpbin echo application, Service port 80 to container port 8080 |
  | `starfleet` | `shuttle` | A client Pod with `curl`, used to send requests from inside the cluster |
  | `outpost` | `drifter` | A client Pod with `curl` that belongs to another team |

- There is no Ingress controller and no Gateway API controller in the cluster. You can create `Ingress` objects, because the API server stores them, but nothing routes traffic for them.

## Helpers

```sh
from_shuttle() {
  kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "$@"
}
```

## Practice tasks

- Run `kubectl get endpointslices -n starfleet` and `kubectl describe svc scout -n starfleet`. Match the endpoint IP with the `scout` Pod IP.
- Scale `scout` to 3 replicas and watch the EndpointSlice change. Scale it to 0 and send a request to the Service.
- Create a Service named `scout-nodeport` of type NodePort for `scout` and read the node port it received.
- Create a Service with a selector that matches nothing and read its EndpointSlices.
- Create a headless Service (`clusterIP: None`) and compare it with a normal Service.
- Create an `Ingress` for `scout`, read it with `kubectl describe`, and find out why its address stays empty.
