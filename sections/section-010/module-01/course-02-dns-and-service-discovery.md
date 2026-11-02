---
draft: true
exam_objectives:
  - Networking
---
# DNS And Service Discovery

The `shuttle` application contacts a backend named `probe` instead of storing an individual Pod address. The Domain Name System (DNS) resolves names to network information. Kubernetes cluster DNS publishes Service records so clients can discover stable names for application access.

A normal Service usually resolves to its virtual cluster address. Network forwarding then directs traffic to an eligible backend. A headless Service has no allocated cluster virtual address and can expose backend addresses through DNS. These patterns support different ways for clients to find endpoints.

A Service name is scoped by namespace. A short name normally uses the client's namespace search path. A namespace-qualified name identifies a Service in another namespace. The cluster DNS domain is commonly `cluster.local`, but it is configurable; a full name must use the actual cluster domain rather than assuming every cluster has the same setting.

Resolution and reachability are separate stages. A successful DNS answer proves that a name can be resolved, not that a backend is ready or that its application accepts requests. A connection can still fail because of an empty backend set, incorrect port, network policy or application problem.

Suppose `probe` works from `starfleet` but the short name fails from `outpost`. Check whether the client is asking for a Service in the wrong namespace before blaming all cluster networking. If the correct name resolves but connections fail, investigate the Service's backends and traffic path.

Discovery removes hard-coded backend addresses, but clients still need suitable connection handling. Existing connections can fail during replacement, and name or endpoint changes may require a new connection. Reliable clients retry safe operations without assuming that a previous successful lookup guarantees future health.

## Resolving Names In Different Namespaces

Assume the Service `probe` exists in `starfleet`. A client in that namespace can commonly use the short name `probe` through its configured DNS search path. A client in `outpost` using the same short name normally asks first for a Service in its own namespace, not automatically for `starfleet`'s application.

A namespace-qualified name such as `probe.starfleet` identifies the intended namespace. A full Service name also includes the Service subdomain and the configured cluster domain. That domain often uses `cluster.local`, but the client must follow the actual cluster configuration. Name shape and search behavior are configuration-dependent details, not application identities guaranteed across every cluster.

A headless Service returns backend discovery information instead of the ordinary allocated virtual address. The client may then need to choose and connect to individual endpoints itself. That can suit applications needing member identity, but it gives clients different connection responsibilities from a virtual Service access point.

## Distinguishing Four Failure Results

A name lookup failure can mean the record is absent, the namespace is wrong or the resolver cannot be reached. A resolved address with a connection refusal can indicate an absent listener or unsuitable destination. A connection timeout can indicate a blocked or unreachable path. A completed connection with an application error indicates progress beyond discovery and transport establishment.

These observations are not perfect diagnoses by themselves, but they narrow the stage. Compare the actual name queried, answer received and client context before changing cluster-wide DNS. A policy blocking DNS requests can break discovery even when the DNS service itself is healthy.

Caching adds timing. Clients and resolvers can retain answers, and an application may reuse connections after discovery. A newly correct record does not guarantee every client immediately uses the new endpoint. Reliable behavior therefore combines meaningful names, suitable cache and connection handling, and verification from the caller experiencing the failure.

## Common pitfalls

> [!WARNING]
> A DNS answer is not a health check. Short Service names depend on namespace search rules, and the cluster domain is configurable.
