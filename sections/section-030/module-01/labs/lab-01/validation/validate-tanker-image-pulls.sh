#!/usr/bin/env bash
# Check: tanker runs an image that exists, and the pod is available.
set -uo pipefail

if ! kubectl -n starfleet rollout status deployment/tanker --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: deployment/tanker is not available (image pull still failing?)"
  exit 1
fi

reason="$(kubectl -n starfleet get pods -l app=tanker -o jsonpath="{.items[*].status.containerStatuses[*].state.waiting.reason}" 2>/dev/null || true)"
if [ -n "$reason" ]; then
  echo "FAIL: a tanker container is waiting: $reason"
  exit 1
fi

echo "PASS: tanker pulls its image and is available"
