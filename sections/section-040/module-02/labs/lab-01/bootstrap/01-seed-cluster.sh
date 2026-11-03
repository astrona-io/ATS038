#!/usr/bin/env bash
# Starting state for the reclaim lab. Environment only: it creates the
# workloads and the claim that already exists. It creates no PersistentVolume
# and no archive-claim; the learner writes those.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/shuttle --timeout=180s
echo "[lab] Ready."
