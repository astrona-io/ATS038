# Troubleshooting

When an application does not work on Kubernetes, the cause is almost never a mystery. Every failure happens at one stage of a pod's life or at one hop of a request, and the cluster records evidence for each: the pod phase and conditions, the container state and exit code, the events, the node conditions, the EndpointSlices and the DNS answers. This section teaches you to read that evidence, name the failing stage and the component that owns it, and make one change that fixes it.

You work in two modules, each with a hands-on playground and a graded lab. The first module follows a single pod from placement to readiness: pods that stay `Pending` because of a node selector or a resource request, containers that cannot pull an image, crash or run out of memory, and probes that mark a healthy process as not ready. The second module widens the view to what pods share: node conditions and capacity, missing ConfigMaps, Secrets and claims, Services with no endpoints or the wrong port, and name resolution with CoreDNS. A capstone lab closes the section with a namespace that has four different failures to find and fix. A short quiz checks the ideas.

## Learning Outcomes

- Use status, conditions and events to identify a failed lifecycle stage.
- Distinguish placement failures from preparation and startup failures.
- Explain image pull errors, crash loops, out-of-memory kills and failing probes.
- Choose evidence before making a corrective change, change one thing and verify it.
- Distinguish a node problem from a single workload problem.
- Separate DNS resolution from Service backend connectivity with EndpointSlices and the exit code of `curl`.
- Explain how missing ConfigMaps, Secrets, storage claims and resource requests affect workloads.
- Choose the smallest diagnostic scope that the evidence supports.
