#!/usr/bin/env bash
# Starting state for the troubleshooting lab. Environment only: it creates the
# healthy workloads and the six faulty Deployments. It does not fix anything.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/starfleet.yaml"
kubectl apply -f "$DIR/manifests/lab-start.yaml"

# Wait only for the healthy workloads. The faulty ones never become ready.
for name in scout shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
echo "[lab] Ready."
