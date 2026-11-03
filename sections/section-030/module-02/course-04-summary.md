# Summary

A failure that touches several workloads points at something they share, and a failure in one workload points at that workload. Deciding the width of the problem comes first, and the smallest scope that the evidence supports is tested first. A node problem shows in the node conditions: `Ready`, `MemoryPressure`, `DiskPressure`, `PIDPressure` and `NetworkUnavailable`. A `NotReady` node gets taints from the node lifecycle controller, and its pods are evicted and replaced on other nodes.

The scheduler fits pods by requests against allocatable capacity. A node can be full of requests while real usage is low, and real usage comes from the metrics server. System components such as CoreDNS, the forwarding proxy and the network plugin run as pods in `kube-system`, and a failure in one of them affects many applications at once. A pod that references a missing ConfigMap or Secret shows `CreateContainerConfigError`, a missing volume source shows `ContainerCreating` with a mount event, and an unbound claim keeps the pod `Pending`. Each recovers once the missing object exists.

A request reaches a pod in four hops: the name lookup, the ClusterIP, the choice of an endpoint and the `targetPort`. The EndpointSlice is where the Service and the pods meet. A selector that matches no Ready pod gives an empty EndpointSlice and refused connections, a wrong `targetPort` gives an endpoint that refuses connections at the pod, and a pod that is not Ready is listed as not ready and receives no traffic. The `Service` looks healthy in all three cases, so the EndpointSlice is the evidence.

A pod resolves names through the cluster DNS server, CoreDNS, which the kubelet writes into `/etc/resolv.conf`. The search list and `ndots:5` make a short name resolve only inside the client's own namespace. The exit code of `curl` separates the failures: `6` is a name that did not resolve, `7` is a refused connection and `28` is a timeout. `kubectl debug` adds an ephemeral container with its own tools to a running pod, shares its network and cannot be removed from the pod afterwards. The key facts to remember are these:

- Empty EndpointSlice: compare the selector with the pod labels and check that the pods are Ready.
- Endpoint present, connection refused: compare `targetPort` with the container port.
- `curl` exit code 6 is DNS, 7 is refused, 28 is a timeout.
- A short Service name works only in the namespace of the client.
- A missing ConfigMap or Secret blocks every pod that uses it, and the pod recovers after the object is created.

<!-- astrona:playground:destroy -->
