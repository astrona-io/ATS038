#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n starfleet patch service scout-public --type merge -p '{
  "spec": {
    "selector": {"app": "scout"},
    "ports": [{"name": "http", "port": 80, "targetPort": "http"}]
  }
}'
kubectl apply -f "$DIR/solution.yaml"

# The EndpointSlice controller fills the new slices within a few seconds.
for i in $(seq 1 30); do
  if kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=scout-public \
    -o jsonpath='{.items[*].endpoints[*].conditions.ready}' | grep -q true; then
    break
  fi
  sleep 2
done
echo "[solution] Applied."
