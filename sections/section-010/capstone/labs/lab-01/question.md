# Question

Solve this question on: `terminal`

The team `orbit` runs the `beacon` application in the namespace `orbit`, and a `relay` client runs next to it. The `drifter` client in `outpost` belongs to another team. Do the following in `orbit`. Do not change the Deployments.

1. The Service `beacon` has no endpoints. Fix it so that the `relay` Pod gets status 200 from `http://beacon/healthz`. Keep the name and the Service port 80.

2. Create a headless Service named `beacon-pods` that selects the `beacon` Pods and uses the Pod port 9898 as its port.

3. Create a Service named `beacon-external` of type NodePort for the `beacon` Pods, with Service port 80 and node port 30090.

4. The `beacon` Pods must accept connections only from the `relay` Pods in `orbit`, on TCP port 9898. The `drifter` Pod in `outpost` must not reach them. Use a NetworkPolicy.

`kubectl` already points at the cluster as the cluster administrator.
