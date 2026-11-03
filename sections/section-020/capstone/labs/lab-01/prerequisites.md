# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know RBAC roles and bindings, service account tokens, security context fields, Pod Security levels and how a pod can receive a Secret.

The lab starts a single-node kind cluster (Kubernetes 1.35) with a team namespace `orbit`.
