# Summary

A pod that does not work has stopped at one stage of its lifecycle, and each stage has its own component and its own evidence. The scheduler places the pod on a node and explains a failure in a `FailedScheduling` event. The kubelet pulls the image, creates the container and runs the probes, and it records the result in the container state, the exit code and the pod events. The pod phase gives only a short summary, so the conditions and the events carry the real information.

A pod that stays `Pending` with no node is a placement problem. The scheduler rejects every node that fails a node selector, a node affinity rule, a taint without a matching toleration, or a resource request that does not fit in the node's allocatable capacity. It compares requests, not real usage. A pod that has a node and a waiting container is a kubelet problem: `ErrImagePull` and `ImagePullBackOff` come from a missing tag, missing credentials or an unreachable registry, and `CreateContainerConfigError` comes from a missing ConfigMap or Secret.

A container that starts and stops shows `CrashLoopBackOff`, which is a waiting period between restarts and not a cause. The cause is in `kubectl logs --previous` and in the last exit code. A memory limit is enforced by the kernel, and a container that exceeds it ends with the reason `OOMKilled` and exit code `137`. A CPU limit slows a container down and never kills it.

Probes are the checks that the kubelet runs against the application. A failing readiness probe removes the pod from the Service endpoints and does not restart the container. A failing liveness probe restarts the container. A startup probe holds back the other two until a slow application has started. A pod that is `Running` with `0/1` ready usually has a readiness probe that checks the wrong path or port.

A safe correction collects the evidence, names one cause, changes one field and verifies with the same evidence. A change to the pod template starts a rolling update, `kubectl rollout status` waits for it, and `kubectl rollout history` and `kubectl rollout undo` return to an earlier template. The key facts to remember are these:

- Empty `NODE` column and `FailedScheduling`: look at selectors, taints and requests.
- Waiting container with a pull reason: look at the image name, the tag and the credentials.
- `CrashLoopBackOff`: read the previous logs and the exit code.
- `OOMKilled` and exit code `137`: the memory limit is too low for the process.
- `Running` and `0/1` ready: the readiness probe fails.

<!-- astrona:playground:destroy -->
