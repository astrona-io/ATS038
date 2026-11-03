# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know how a Service selects Pods, the Service types, headless Services, and how a NetworkPolicy selects Pods and allows ingress.

The lab starts a single-node kind cluster (Kubernetes 1.35). The policy checks need a network plugin that enforces NetworkPolicy; the default kind plugin is expected to do so in current kind releases.
