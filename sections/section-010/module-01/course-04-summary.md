# Summary

Every Pod has one IP address that all of its containers share. Pod-to-Pod and node-to-Pod traffic needs no address translation, and a Pod sees the same address for itself that other Pods use. The address belongs to the Pod and ends with it, so clients must not store it.

The network plugin builds the network that makes these rules true. The container runtime calls it through the Container Network Interface when a Pod starts and when it stops. The plugin assigns the address from the block that belongs to the node, connects the Pod namespace to the node, and arranges routing or encapsulation between nodes. Features such as NetworkPolicy enforcement come from the plugin, not from the interface.

CoreDNS gives clients stable names. The kubelet writes the cluster DNS address and a search list into each Pod, so the name `probe` resolves in its own namespace, `probe.starfleet` resolves from anywhere, and the fully qualified name always works. A normal Service name resolves to the Service address. A headless Service name resolves to the addresses of the ready Pods.

The key facts to remember are these:

- The network model: no NAT between Pods, no NAT between a node and its Pods, and the same address seen from inside and outside.
- The plugin allocates Pod addresses, the scheduler does not move packets, and `kube-proxy` and CoreDNS are separate components.
- Short Service names depend on the namespace of the client.
- A name that does not resolve and an address that does not answer are different failures.

<!-- astrona:playground:destroy -->
