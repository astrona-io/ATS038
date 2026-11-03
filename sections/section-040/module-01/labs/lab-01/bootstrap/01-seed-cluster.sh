#!/usr/bin/env bash
# Starting state for the storage lab. Environment only: it creates the
# workloads and the faulty storage setup. It creates no claim the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
echo "[lab] Ready."
