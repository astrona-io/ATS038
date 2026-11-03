# Summary

By default every Pod can send traffic to every other Pod, in any namespace. A NetworkPolicy changes this for the Pods it selects. It names Pods in its own namespace with a `podSelector`, and it lists the directions it controls in `policyTypes`. A selected Pod is isolated in each listed direction, and only traffic that some policy allows is permitted. Policies only allow, they never deny, and the allowed traffic is the union of all policies that select the Pod.

Rules select peers with a Pod selector, a namespace selector or an IP block. Two list items are alternatives, and one item with two selectors is a combination. Rules match Pod addresses and Pod ports, not Service addresses and ports. A connection needs the sender's egress policies and the receiver's ingress policies to allow it. An egress policy needs its own rule for DNS, or name resolution fails at once, while a blocked connection to a resolved address times out.

The API server only stores a NetworkPolicy. The network plugin enforces it, so a policy has no effect on a plugin that does not support it. NetworkPolicy works on addresses and ports and does not encrypt traffic or verify identity.

A service mesh adds those functions through proxies, usually sidecar proxies. It provides mutual TLS, authorization by workload identity, traffic management and request metrics. It works only for traffic that passes through its proxies. TLS encrypts a connection, and a certificate signed by a certificate authority proves the name of the server. A client accepts the certificate only when the signature, the name and the validity dates are all correct.

The key facts to remember are these:

- A Pod is isolated for a direction as soon as one policy selects it for that direction.
- Always allow DNS in an egress policy.
- NetworkPolicy is enforced by the network plugin, mTLS by a mesh.
- A valid certificate for the wrong name is still rejected.

<!-- astrona:playground:destroy -->
