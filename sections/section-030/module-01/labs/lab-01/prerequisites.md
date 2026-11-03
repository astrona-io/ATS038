# Prerequisites

- The `astrona` command-line tool, installed and working (`astrona check` passes).
- A container engine that kind can use (Podman or Docker) with about 2 GiB of free memory.
- `kubectl`.
- You know the lifecycle of a pod, and you can read `kubectl get pods`, `kubectl describe pod` and `kubectl logs`.

The lab starts a single-node kind cluster (Kubernetes 1.35) with a healthy `scout` and `shuttle` and six faulty Deployments in `starfleet`. The commands for the lab are in the README of this folder.
