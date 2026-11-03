# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know what a Pod IP address is, how CoreDNS resolves Service names, and what a headless Service is.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the Starfleet workloads in `starfleet` and `outpost`.
