#!/usr/bin/env bash
# Check: rover is available and its pod has not restarted since the fix. A pod
# that still exits with code 1 never becomes available for long.
set -uo pipefail

if ! kubectl -n starfleet rollout status deployment/rover --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: deployment/rover is not available"
  exit 1
fi

sleep 15
restarts="$(kubectl -n starfleet get pods -l app=rover --field-selector=status.phase=Running -o jsonpath="{.items[*].status.containerStatuses[*].restartCount}" 2>/dev/null || true)"
if [ -z "$restarts" ]; then
  echo "FAIL: no running rover pod"
  exit 1
fi
for count in $restarts; do
  if [ "$count" -gt 0 ]; then
    echo "FAIL: a rover container restarted $count time(s). Its main process still exits"
    exit 1
  fi
done

echo "PASS: rover keeps running"
