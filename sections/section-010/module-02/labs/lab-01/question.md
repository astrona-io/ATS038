# Question

Solve this question on: `terminal`

The `starfleet` namespace is running. The team wants to publish the `scout` application. A new Service was created for it, and a review asks for two more objects. Do not change the `scout` Deployment or the original `scout` Service.

1. The Service `scout-public` in `starfleet` has no endpoints, and requests to it fail. Fix the Service so that the `shuttle` Pod gets status 200 from `http://scout-public/healthz`. Do not recreate it under another name.

2. Create a Service named `scout-nodeport` in `starfleet` of type NodePort for the `scout` Pods. It must listen on port 80 and use the node port 30080.

3. Create an Ingress named `starfleet-web` in `starfleet`. It must send requests for the host `scout.starfleet.test`, path `/` with path type `Prefix`, to the Service `scout-public` on port 80. Use the class name `nginx`.

`kubectl` already points at the cluster as the cluster administrator. The cluster has no Ingress controller, so the Ingress stays without an address.
