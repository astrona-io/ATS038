#!/usr/bin/env bash
# Check: drifter in outpost cannot reach a beacon Pod. The Pod address is used,
# because the Service is broken at the start and would block drifter by itself.
set -uo pipefail

ip="$(kubectl -n orbit get pod -l app=beacon -o jsonpath='{.items[0].status.podIP}' 2>/dev/null || true)"
code="$(kubectl -n outpost exec deploy/drifter -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' "http://$ip:9898/healthz" 2>/dev/null || true)"
if [ "$code" = "200" ]; then
  echo "FAIL: drifter still reaches the beacon Pod. Allow only relay."
  exit 1
fi
echo "PASS: drifter cannot reach the beacon Pod"
