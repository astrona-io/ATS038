#!/usr/bin/env bash
# Check: relay is available, still has a liveness probe, and its running pod
# has not restarted.
set -uo pipefail

if ! kubectl -n orbit rollout status deployment/relay --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: deployment/relay is not available"
  exit 1
fi

path="$(kubectl -n orbit get deployment relay -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null || true)"
if [ -z "$path" ]; then
  echo "FAIL: relay has no liveness probe. Fix the probe, do not remove it"
  exit 1
fi

sleep 15
restarts="$(kubectl -n orbit get pods -l app=relay --field-selector=status.phase=Running -o jsonpath='{.items[*].status.containerStatuses[*].restartCount}' 2>/dev/null || true)"
if [ -z "$restarts" ]; then
  echo "FAIL: no running relay pod"
  exit 1
fi
for count in $restarts; do
  if [ "$count" -gt 0 ]; then
    echo "FAIL: a relay container restarted $count time(s). The liveness probe still fails"
    exit 1
  fi
done

echo "PASS: relay stays running with its liveness probe ($path)"
