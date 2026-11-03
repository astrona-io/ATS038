# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know the main security context fields, the three Pod Security levels and the difference between an environment variable and a Secret volume.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads in `starfleet` and `outpost`.
