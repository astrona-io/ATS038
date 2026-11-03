# Question

Solve this question on: `terminal`

A new team namespace `orbit` is running. A security review found problems in access, in the workload and in the namespace. Fix all of them. Do not delete the `beacon` Deployment, the Secret or any service account.

1. The service account `ci-deployer` in `orbit` is bound to the `edit` ClusterRole in every namespace. The pipeline only has to read (`get`, `list`, `watch`) and change (`update`, `patch`) Deployments in `orbit`. Give it exactly that with a Role and a RoleBinding in `orbit`, and remove the cluster-wide binding.

2. The `beacon` Deployment in `orbit` is privileged and has no hardening. Make it run as a numeric non-root user, with no privilege escalation, a read-only root filesystem and all capabilities dropped. It never calls the Kubernetes API, so its pods must not receive a service account token.

3. `beacon` reads the Secret `beacon-key` through the environment variable `BEACON_KEY`. Deliver the Secret as a read-only volume mounted at `/etc/beacon-key` and remove the variable.

4. Make the namespace `orbit` enforce the `baseline` Pod Security level. `beacon` must stay available and its Service `beacon` must keep an endpoint.

`kubectl` already points at the cluster as the cluster administrator.
