#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/solution.yaml"
# The kubelet retries a missing ConfigMap on its own. Restart lander so the
# wait is short.
kubectl -n starfleet rollout restart deployment/lander
echo "[solution] Applied."
