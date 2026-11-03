#!/usr/bin/env bash
# Check: signal is scheduled and available.
set -uo pipefail

if ! kubectl -n orbit rollout status deployment/signal --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: deployment/signal is not available"
  exit 1
fi

cpu="$(kubectl -n orbit get deployment signal -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null || true)"
if [ -z "$cpu" ]; then
  echo "FAIL: signal has no CPU request. Lower the request, do not remove it"
  exit 1
fi

echo "PASS: signal is scheduled with a CPU request of $cpu"
