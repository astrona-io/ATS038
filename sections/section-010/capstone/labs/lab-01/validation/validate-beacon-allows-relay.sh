#!/usr/bin/env bash
# Check: relay reaches a beacon Pod directly on 9898. The Pod address is used
# so that the check does not depend on the Service.
set -uo pipefail

ip="$(kubectl -n orbit get pod -l app=beacon -o jsonpath='{.items[0].status.podIP}' 2>/dev/null || true)"
code="$(kubectl -n orbit exec deploy/relay -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' "http://$ip:9898/healthz" 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: relay got '$code' from the beacon Pod (expected 200)"
  exit 1
fi
echo "PASS: relay reaches the beacon Pod"
