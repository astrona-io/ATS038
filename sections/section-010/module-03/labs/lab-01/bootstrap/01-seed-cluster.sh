#!/usr/bin/env bash
# Starting state for the traffic control lab. Environment only: it creates the
# workloads. It creates no NetworkPolicy. Every Pod can reach every other Pod.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

for name in scout probe shuttle relay; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
