#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n orbit patch service beacon --type merge -p '{
  "spec": {
    "selector": {"app": "beacon"},
    "ports": [{"name": "http", "port": 80, "targetPort": "http"}]
  }
}'
kubectl apply -f "$DIR/solution.yaml"

# The EndpointSlice controller and the network plugin need a few seconds.
for i in $(seq 1 30); do
  if kubectl -n orbit get endpointslices -l kubernetes.io/service-name=beacon \
    -o jsonpath='{.items[*].endpoints[*].conditions.ready}' | grep -q true; then
    break
  fi
  sleep 2
done
sleep 10
echo "[solution] Applied."
