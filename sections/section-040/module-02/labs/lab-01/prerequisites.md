# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know how a PersistentVolume, a PersistentVolumeClaim and a reclaim policy work.

The lab starts a single-node kind cluster (Kubernetes 1.35) with the default StorageClass `standard`. The commands for the lab are in the README of this folder.
