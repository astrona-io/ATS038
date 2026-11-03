# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You can read pod status, events and logs, and you know how a Service reaches its pods.

The lab starts a single-node kind cluster (Kubernetes 1.35) with a namespace `orbit`. The commands for the lab are in the README of this folder.
