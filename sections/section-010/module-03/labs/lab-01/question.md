# Question

Solve this question on: `terminal`

The `starfleet` and `outpost` namespaces are running, and no NetworkPolicy exists. A review found two problems. Fix both with NetworkPolicy objects. Do not change the workloads or the Services.

1. The `probe` Pods in `starfleet` accept connections from every Pod. They must accept connections only from the `shuttle` Pods in `starfleet`, on TCP port 8080. The `drifter` Pod in `outpost` must no longer reach `probe`.

2. The `drifter` Pod in `outpost` may send traffic anywhere. It must send traffic only to the `scout` Pods in `starfleet` on TCP port 9898, and to the cluster DNS Pods. It must still reach `http://scout.starfleet/healthz` by name. It must no longer reach the `relay` Pods in `starfleet`.

Remember that policy rules match Pod addresses and Pod ports. `kubectl` already points at the cluster as the cluster administrator.
