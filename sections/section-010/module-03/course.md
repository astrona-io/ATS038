# Traffic Control

By default every Pod in a Kubernetes cluster can send traffic to every other Pod. That is convenient for a start and dangerous for production, because one compromised Pod can reach every database in the cluster. This module shows how to limit traffic with NetworkPolicy, what a service mesh adds on top of it, and how Transport Layer Security (TLS) protects a connection and proves who is on the other end.

Keep one sentence in mind for this module: **a NetworkPolicy selects Pods and lists the traffic they may receive or send, and once a Pod is selected for a direction, everything not listed is denied in that direction.** You will isolate a Pod, allow one client, add egress rules and see why name resolution needs its own rule.

The module has three parts. **NetworkPolicy And Allowed Connections** explains how a policy selects Pods and how ingress rules allow traffic. **Egress Rules And Both Directions** covers outgoing traffic, the DNS rule that is easy to forget, and why a connection needs both sides to allow it. **Service Mesh And Transport Security** compares policy with a service mesh and shows what TLS certificates do.

## Learning objectives

After this module you can:

- Explain how a NetworkPolicy selects Pods and what isolation means.
- Write an ingress policy that allows one client Pod on one port.
- Write an egress policy that includes DNS.
- Predict whether a connection works when ingress and egress policies are both present.
- Distinguish NetworkPolicy from a service mesh.
- Explain what TLS encrypts, what a certificate proves and what a certificate authority does.

## Before you start

You need to know Pods, labels, namespaces and Services, and the commands `kubectl apply`, `kubectl exec` and `kubectl get`.

Your playground is a single-node `kind` cluster running Kubernetes 1.35. The default `kind` network plugin enforces NetworkPolicy in current releases, so the policies you apply take effect. It has these workloads:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout`, `probe` | Two web applications, each with a ClusterIP Service on port 80 |
| `starfleet` | `shuttle` | A client Pod with `curl` |
| `outpost` | `drifter` | A client Pod with `curl` that belongs to another team |

No NetworkPolicy exists at the start. For the TLS exercises you use `openssl` on your own machine.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
