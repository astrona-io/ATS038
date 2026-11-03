#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROBE_IP="$(kubectl -n starfleet get pod -l app=probe -o jsonpath='{.items[0].status.podIP}')"
kubectl -n starfleet create configmap probe-address --from-literal=podIP="$PROBE_IP"
kubectl apply -f "$DIR/solution.yaml"
echo "[solution] Applied."
