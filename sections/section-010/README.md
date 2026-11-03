# Networking

This section teaches how traffic moves in a Kubernetes cluster and how to control it. It starts with the Pod address and the network plugin, continues with DNS and Services, and ends with NetworkPolicy and transport security. Each topic is practised in a playground on a single-node `kind` cluster that runs Kubernetes 1.35.

You work through three modules. Pod Networking explains Pod addresses, the network model, the Container Network Interface and cluster DNS. Services And External Access explains selectors, EndpointSlices, the Service types, Ingress and the Gateway API. Traffic Control explains NetworkPolicy, egress and DNS rules, service meshes and TLS certificates. Each module has a playground, a graded lab and a summary. A capstone lab closes the section, followed by a knowledge check.

The labs in this section were written from documentation and have not been run yet.

## Learning Outcomes

- Explain that each Pod has one IP address and describe the Kubernetes network model.
- Identify the network plugin's role and the CNI interface.
- Explain how Service names resolve through CoreDNS.
- Distinguish a name that does not resolve from an address that does not answer.
- Explain how Service selectors, ports and EndpointSlices decide where a request goes.
- Compare ClusterIP, NodePort, LoadBalancer, headless and ExternalName Services.
- Distinguish an Ingress from a Service and from an Ingress controller, and describe the Gateway API roles.
- Explain how NetworkPolicy selects and isolates Pods, including egress and DNS rules.
- Predict whether a connection works when ingress and egress policies both apply.
- Distinguish NetworkPolicy from a service mesh and explain what TLS certificates prove.
