# Services And External Access

Pods come and go, and each new Pod has a new address. A Service gives a group of Pods one stable address and name, and it keeps a list of the Pods that are ready to receive traffic. Clients outside the cluster need more: a way to enter from the node network or the internet. This module follows a request from a client to a Pod and shows what each Kubernetes object contributes.

Keep one sentence in mind for this module: **a Service selects Pods with labels, the EndpointSlice lists the ready Pod addresses, the Service type decides who can reach it, and an Ingress or a Gateway adds routing for HTTP traffic.** You will read selectors and ports, change a Service by hand, expose an application through a node port, and create an Ingress object.

The module has three parts. **Selectors, Ports And Backends** shows how a Service finds its Pods, what `port`, `targetPort` and `nodePort` mean, and how EndpointSlices record the ready backends. **Service Types And Node Access** compares ClusterIP, NodePort, LoadBalancer, headless and ExternalName Services. **External Entry And Application Routing** explains what an Ingress is, why it needs a controller, and how the Gateway API divides the work between roles.

## Learning objectives

After this module you can:

- Explain how a Service selector, the `port` and `targetPort` fields, and EndpointSlices decide where a request goes.
- Diagnose a Service that has no endpoints.
- Compare ClusterIP, NodePort and LoadBalancer Services and state who can reach each one.
- Explain headless and ExternalName Services.
- Distinguish an Ingress from a Service and from an Ingress controller.
- Explain the roles of GatewayClass, Gateway and HTTPRoute in the Gateway API.

## Before you start

You need to know what a Pod, a Deployment and a label are, and the commands `kubectl get`, `kubectl apply`, `kubectl describe` and `kubectl exec`.

Your playground is a single-node `kind` cluster running Kubernetes 1.35. It has these workloads:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout`, `probe` | Two web applications, each with a ClusterIP Service on port 80 |
| `starfleet` | `shuttle` | A client Pod with `curl` |
| `outpost` | `drifter` | A client Pod with `curl` that belongs to another team |

The cluster has no Ingress controller and no Gateway API controller. You can create Ingress objects, but no component acts on them.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
