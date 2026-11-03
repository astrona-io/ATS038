#!/usr/bin/env bash
# Starting state for the networking capstone. Environment only: it creates the
# orbit workloads and the faulty Service. It creates none of the objects the
# learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

kubectl -n orbit rollout status deployment/beacon --timeout=180s
kubectl -n orbit rollout status deployment/relay --timeout=180s
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
