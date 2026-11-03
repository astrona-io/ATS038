# Pod Networking

Every container in a Kubernetes cluster needs to send and receive network traffic, and the people who run the cluster need to know which component makes that possible. Pod networking is the set of rules and components that give each Pod an address and let Pods talk to each other, on one node or across nodes. When it breaks, nothing in the cluster can reach anything else, so you must be able to say which layer failed.

Keep one sentence in mind for this module: **a Pod has its own IP address, the network plugin makes that address reachable from every other Pod, and DNS turns stable names into addresses so that clients do not have to remember them.** You will list Pod addresses, send requests between Pods, read the DNS settings inside a Pod, and resolve Service names in three forms.

The module has three parts. **Pod Addresses And The Network Model** shows that every Pod gets an IP address and that all containers in a Pod share it. **The Network Plugin And Cross-Node Traffic** shows which component allocates the addresses, what the Container Network Interface (CNI) is, and how a packet reaches a Pod on another node. **DNS And Service Discovery In Practice** reads the resolver settings inside a Pod and resolves names through CoreDNS.

## Learning objectives

After this module you can:

- Explain that each Pod has one IP address that its containers share, and that the address changes when the Pod is replaced.
- State the three rules of the Kubernetes network model.
- Identify the network plugin's role and describe the CNI interface.
- Find the Pod address range assigned to each node.
- Explain how a Service name resolves through CoreDNS, including the short, namespaced and fully qualified forms.
- Distinguish a name that does not resolve from an address that does not answer.

## Before you start

You need to know what a Pod, a Deployment and a Service are, and the commands `kubectl get`, `kubectl describe` and `kubectl exec`.

Your playground is a single-node `kind` cluster running Kubernetes 1.35. `kubectl` already points at it. It has these workloads:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout`, `probe` | Two web applications, each with a ClusterIP Service on port 80 |
| `starfleet` | `shuttle` | A client Pod with `curl` |
| `outpost` | `drifter` | A client Pod with `curl` that belongs to another team |

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
