# Workload Security

Access control decides who may call the API. It does not decide what a container may do once it runs. A container that runs as root, can gain extra privileges or mounts the host filesystem can damage the node it runs on and every other pod on that node. Credentials and images create two more risks: a password stored in the wrong place leaks easily, and an image that nobody checked can carry a known vulnerability or come from the wrong builder.

This module covers the controls that limit a running workload. You will set a security context on a pod, learn what the three Pod Security Standards levels forbid, enforce a level on a namespace, handle a Secret in the safest of the available ways and separate two checks that sound alike: scanning an image for vulnerabilities and verifying who built it.

The module has three parts. The first part, **Security Contexts And Pod Admission**, explains the settings in a security context and what each one limits. The second part, **Credentials And Image Supply Chains**, explains Secrets, why base64 is not encryption, and how scanning differs from signing. The third part, **Enforcing Pod Security Levels**, applies the Privileged, Baseline and Restricted levels to a namespace with labels and reads the rejections.

## Learning goals

After this module you can:

- Explain what `runAsNonRoot`, `allowPrivilegeEscalation`, `readOnlyRootFilesystem`, `capabilities` and `privileged` control.
- Explain the limits of a security context: it restricts one container but does not isolate a kernel.
- Compare the Privileged, Baseline and Restricted Pod Security Standards.
- Enforce a level on a namespace with `pod-security.kubernetes.io` labels and explain the enforce, audit and warn modes.
- Choose a safer way to give a pod a credential and explain what base64 does and does not protect.
- Distinguish an image vulnerability scan from a signature or digest check.

## Before you start

You need to know namespaces, pods and Deployments, and how to edit a pod template. You do not need to know RBAC. Every term is defined where it first appears.

Your playground is a single-node `kind` cluster that runs Kubernetes 1.35. `kubectl` already points at it as the cluster administrator. The cluster holds the following objects:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout`, `probe`, `shuttle` | The example application, with no security context set |
| `starfleet` | Secret `api-key` | A credential with one key, `token` |
| `outpost` | `drifter` | A client that belongs to another team |
| `outpost` | `debug-tool` | A Deployment whose container runs as privileged. This is wrong on purpose |

No Pod Security label is set on either namespace.

Launch your playground now and keep it open while you read:

<!-- astrona:playground -->
