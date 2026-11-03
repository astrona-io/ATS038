#!/usr/bin/env bash
# Starting state for the cluster services lab. Environment only: it creates the
# healthy workloads and the three faults. It does not fix anything.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/starfleet.yaml"
kubectl apply -f "$DIR/manifests/lab-start.yaml"

# Wait only for the healthy workloads. lander never becomes ready.
for name in scout shuttle probe relay; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
