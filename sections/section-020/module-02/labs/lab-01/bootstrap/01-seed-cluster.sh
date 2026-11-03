#!/usr/bin/env bash
# Starting state for the workload security lab. Environment only: it creates
# the workloads, the Secret and the privileged debug-tool. It does not create
# the fixes. shuttle receives the Secret as an environment variable.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# lab-start.yaml creates the namespaces. The shuttle pod waits for the Secret
# from extras.yaml and starts as soon as it exists.
kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl apply -f "$DIR/manifests/extras.yaml"

for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
kubectl -n outpost rollout status deployment/debug-tool --timeout=180s
echo "[lab] Ready."
