# Overview: Traffic Control (Playground)

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

- No NetworkPolicy exists yet, so every Pod can reach every other Pod. The default `kind` network plugin (kindnet) is expected to enforce NetworkPolicy in current kind releases. Test a first policy to confirm it in your environment.
- The `openssl` command is not preinstalled in the client Pods. Run the TLS exercises on your own machine.

## Helpers

```sh
probe_ip() { kubectl -n starfleet get pod -l app=probe -o jsonpath='{.items[0].status.podIP}'; }
from_shuttle() { kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 "$@"; }
from_drifter() { kubectl -n outpost exec deploy/drifter -- curl -s --max-time 5 "$@"; }
```

## Practice tasks

- Send a request to the `probe` Pod from `shuttle` and from `drifter`. Both should work.
- Apply a default-deny ingress policy to `starfleet`, then repeat both requests. Then allow only `shuttle` to reach `probe` on port 8080.
- Restrict egress for `drifter` and see name resolution fail. Add a rule for DNS and test again.
- Create a certificate authority and a server certificate with `openssl` on your machine and verify the certificate with `openssl verify`.
