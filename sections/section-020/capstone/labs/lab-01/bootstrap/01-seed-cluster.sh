#!/usr/bin/env bash
# Starting state for the capstone. Environment only: it creates the orbit
# namespace and the faulty setup. It does not create any fix.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n orbit rollout status deployment/beacon --timeout=180s
echo "[lab] Ready."
