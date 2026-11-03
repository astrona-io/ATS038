#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n orbit delete statefulset ledger --wait=true
kubectl -n orbit delete pvc report-cache --wait=true
kubectl apply -f "$DIR/solution.yaml"

kubectl -n orbit rollout status statefulset/ledger --timeout=240s
kubectl -n orbit rollout status deployment/reporter --timeout=180s

for claim in data-ledger-0 data-ledger-1; do
  volume="$(kubectl -n orbit get pvc "$claim" -o jsonpath='{.spec.volumeName}')"
  kubectl patch pv "$volume" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
done
echo "[solution] Applied."
