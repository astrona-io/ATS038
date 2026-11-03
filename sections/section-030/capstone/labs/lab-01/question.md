# Question

Solve this question on: `terminal`

A new team namespace `orbit` is running, and four applications in it do not work. The client `shuttle` is healthy and has `curl`. Diagnose each failure from the pod status, the events and the logs, and fix it. Fix problems in the Deployments, the Service and the objects they depend on. Do not label, taint or change a node. Do not scale a Deployment to zero or delete it.

1. The Deployment `beacon` has a pod that cannot start. After you fix that, `shuttle` must still get HTTP 200 from `http://beacon/healthz`. Check the whole path from the client to the pod, not only the pod.

2. The Deployment `signal` has a pod that stays `Pending`. It must be scheduled and available. Keep a CPU request, but make it small enough for the node.

3. The Deployment `relay` runs, but its container is restarted again and again by the kubelet. It must stay running without restarts. Keep the liveness probe. The application serves `/healthz`.

4. The Deployment `cargo` has a pod that never creates its container. It reads the variable `CARGO_TOKEN` from the key `token` of a Secret. Create what is missing with any non-empty value. Do not remove the variable.

`kubectl` already points at the cluster as the cluster administrator.
