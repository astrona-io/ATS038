# Summary

A security context changes how the container runtime starts a process. `runAsNonRoot` and `runAsUser` choose the user, `allowPrivilegeEscalation: false` blocks gaining privileges, `readOnlyRootFilesystem` protects the image files, `capabilities` drops root powers and `seccompProfile` filters system calls. `privileged: true` removes most of these limits. A security context restricts one process, but containers on a node still share one kernel.

The Pod Security Standards define three levels. Privileged allows everything. Baseline blocks known escalations such as privileged containers, host namespaces and `hostPath` volumes. Restricted adds the hardening settings: non-root, no privilege escalation, all capabilities dropped and a seccomp profile. A namespace chooses a level and a mode with `pod-security.kubernetes.io` labels. The mode `enforce` rejects a pod, `warn` returns a warning to the client and `audit` annotates the audit log. Existing pods keep running, a server-side dry run shows what a label would break, and the checks cover only the pod spec.

A Secret holds sensitive data, but base64 is only an encoding. Real protection comes from access control, including the fact that `list` on Secrets returns values and that creating pods exposes the namespace Secrets, from encryption at rest for etcd, and from careful delivery. A mounted volume is memory-backed, can be restricted by file mode and updates when the Secret changes. An environment variable is inherited by child processes and appears in dumps.

Two checks apply to images. A vulnerability scan compares the packages in an image with known flaws. A signature check proves who built an exact digest and that it has not changed. A tag can move, and a digest names exactly one image.

The key facts to remember are these:

- Baseline blocks privileged containers; Restricted also requires non-root, no privilege escalation, dropped capabilities and a seccomp profile.
- `enforce` rejects, `warn` warns, `audit` annotates. None of them stops a running pod.
- Base64 is not encryption. Prefer a volume over an environment variable.
- A scan finds known vulnerabilities. A signature proves origin and integrity. They answer different questions.

<!-- astrona:playground:destroy -->
