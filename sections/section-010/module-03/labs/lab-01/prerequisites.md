# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know how a NetworkPolicy selects Pods, how ingress and egress rules differ, and why egress needs a DNS rule.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads and a `relay` Pod. The checks need a network plugin that enforces NetworkPolicy; the default kind plugin is expected to do so in current kind releases.
