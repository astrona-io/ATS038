# Diagnosing Cluster Services

A single failing pod points at that workload. A failure that touches several workloads points at something they share: a node, a name lookup, a Service, a ConfigMap or a storage claim. This module teaches you to decide how wide a problem is and to follow one request from the client to the pod, one hop at a time.

Keep one sentence in mind: **test the smallest scope the evidence supports, and move one hop at a time.** A client resolves a name, sends the request to a Service address, the node's packet forwarding sends it to a pod, and the pod answers on a port. Each hop has its own evidence, and each hop can fail on its own.

The module has three parts. **Node Health And Shared Dependencies** reads node conditions, resource pressure and allocated resources, and follows a pod that waits on a missing ConfigMap or an unbound claim. **Tracing A Service Request** follows a request to a Service and finds a selector that matches nothing, a wrong target port and a pod that is not Ready, with EndpointSlices as the evidence. **DNS Resolution And Debug Containers** separates a name that does not resolve from a connection that fails, reads the DNS settings of a pod and CoreDNS, and uses an ephemeral debug container.

## Learning objectives

After this module you can:

- Decide whether a failure belongs to one workload, to a Service, to DNS or to a node.
- Read node conditions, taints, capacity and allocated resources with `kubectl describe node`.
- Explain how missing ConfigMaps, Secrets and unbound claims keep a pod from starting.
- Read an EndpointSlice and explain why a Service has no endpoints, or endpoints that refuse connections.
- Use the exit code of `curl` to tell a DNS failure from a refused connection and a timeout.
- Explain how a pod resolves names, what CoreDNS does and how to start a debug container.

## Before you start

You need Kubernetes basics: pods, Deployments, Services, namespaces and the commands `kubectl get`, `kubectl describe` and `kubectl exec`.

Your playground is a single-node `kind` cluster running Kubernetes 1.35, with CoreDNS in `kube-system` and no metrics server. It has the following workloads:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout` and its Service | A healthy backend |
| `starfleet` | `shuttle` | A client with `curl`, used to send test requests |
| `outpost` | `drifter` | A client in another namespace |
| `starfleet` | `probe` and its Service | The pod is healthy. The Service selector matches no pod |
| `starfleet` | `relay` and its Service | The pod is healthy. The Service sends traffic to the wrong port |
| `starfleet` | `lander` | Reads a variable from a ConfigMap that does not exist |
| `starfleet` | `gate` and its Service | The only pod fails its readiness probe |
| `starfleet` | `archive` and the claim `ledger` | The claim names a StorageClass that does not exist |

You run every command as the cluster administrator. `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
