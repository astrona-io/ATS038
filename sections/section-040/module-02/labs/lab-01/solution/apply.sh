#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/solution.yaml"

volume="$(kubectl -n starfleet get pvc shuttle-logs -o jsonpath='{.spec.volumeName}')"
kubectl patch pv "$volume" -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'

kubectl -n starfleet wait --for=condition=Ready pod/archivist --timeout=180s
echo "[solution] Applied."
