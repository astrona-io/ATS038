#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The probe pod is not scheduled, so the claim is not protected and can go.
kubectl -n starfleet delete pvc probe-data --wait=true
kubectl apply -f "$DIR/solution.yaml"

# Replace the emptyDir of scout with the claim.
kubectl -n starfleet patch deployment scout --type=json -p '[
  {"op":"replace","path":"/spec/template/spec/volumes/0","value":{"name":"data","persistentVolumeClaim":{"claimName":"scout-data"}}}
]'

kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl -n starfleet rollout status deployment/probe --timeout=180s
echo "[solution] Applied."
