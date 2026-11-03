# Question

Solve this question on: `terminal`

A review of the `starfleet` and `outpost` namespaces found three workload security problems. Fix all three. Do not delete any Deployment and do not change the Secret.

1. The `scout` Deployment in `starfleet` runs with no security context. Harden its container: it must run as a numeric non-root user, must not allow privilege escalation, must use a read-only root filesystem and must drop all capabilities. The `scout` Service must keep answering requests from `shuttle`.

2. The `shuttle` Deployment in `starfleet` receives the Secret `api-key` through the environment variable `API_KEY`. Deliver it as a read-only volume mounted at `/etc/api-key` instead, and remove the environment variable. The file `/etc/api-key/token` must hold the Secret value.

3. The `debug-tool` Deployment in `outpost` runs a privileged container. Make its pod unprivileged, and make the namespace `outpost` enforce the `baseline` Pod Security level, so the API server rejects privileged pods there. `debug-tool` must keep running.

`kubectl` already points at the cluster as the cluster administrator.
