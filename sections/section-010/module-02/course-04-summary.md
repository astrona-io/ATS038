# Summary

A Service gives a changing set of Pods one stable address and name. It selects Pods by label, in its own namespace only. The EndpointSlice controller writes the addresses of the ready Pods into EndpointSlice objects, and `kube-proxy` on each node turns them into forwarding rules. A Service without endpoints has a selector that matches no ready Pod, and a Service with endpoints that refuses connections usually has a wrong `targetPort`.

The Service type decides who can reach the address. ClusterIP works inside the cluster. NodePort adds a port on every node. LoadBalancer adds an external address that a cloud controller or another controller creates, and without that controller the address stays pending. A headless Service has no virtual address and DNS answers with the Pod addresses. An ExternalName Service is a DNS alias to another name.

HTTP routing by host and path is stored in an Ingress object, and an Ingress controller reads it and configures a proxy. The Ingress alone changes nothing. The Gateway API divides the same work between a GatewayClass for the controller, a Gateway for the listener and an HTTPRoute for the rules, so different teams can own different parts.

The key facts to remember are these:

- `port` is the Service port, `targetPort` is the Pod port and `nodePort` is the node port, by default in the range 30000 to 32767.
- Each Service type builds on the one before: LoadBalancer includes NodePort, and NodePort includes ClusterIP.
- An Ingress needs an Ingress controller. A Gateway needs a Gateway API controller.
- Check the chain from the Pod outward: readiness, endpoints, Service, route, external address.

<!-- astrona:playground:destroy -->
