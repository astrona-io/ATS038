# Question

Solve this question on: `terminal`

The `starfleet` and `outpost` namespaces are running. A review found three access problems. Fix all three with RBAC and the pod template. Do not delete any Deployment or service account.

1. The service account `probe` in `starfleet` must read pods there (`get`, `list`, `watch`) and nothing else. A Role named `pod-lister` and a RoleBinding already exist, but `probe` still cannot list pods. Find the fault in the Role and fix it. Do not add a second grant.

2. The service account `drifter` in `outpost` is bound to the built-in `view` ClusterRole in every namespace by the ClusterRoleBinding `drifter-view`. The `drifter` team must read objects in `outpost` only. Give them the `view` ClusterRole in `outpost` only, and remove the cluster-wide binding.

3. The `shuttle` Deployment in `starfleet` only calls other Services and never calls the Kubernetes API. Its pods must not receive a service account token.

`kubectl` already points at the cluster as the cluster administrator. You can check any identity with `--as`.
