# Question

Solve this question on: `terminal`

The `starfleet` and `outpost` namespaces are running. The `drifter` team in `outpost` wants a stable way to reach the `scout` application. The `starfleet` team wants a record of the `probe` Pod address and a name that resolves to the Pod itself. Do the following. Do not change the existing workloads or the existing Services.

1. Create a ConfigMap named `probe-address` in `starfleet` with the key `podIP`. Its value must be the current IP address of the `probe` Pod.

2. Create a headless Service named `probe-pods` in `starfleet` that selects the Pods labelled `app=probe`. The `shuttle` Pod must be able to send a request to `http://probe-pods:8080/get` and get status 200.

3. The `drifter` Pod in `outpost` must reach the `scout` application with the short name `http://scout/healthz`. Create a Service named `scout` in `outpost` that makes the name resolve to the `scout` Service in `starfleet`. Do not use an IP address.

`kubectl` already points at the cluster as the cluster administrator.
