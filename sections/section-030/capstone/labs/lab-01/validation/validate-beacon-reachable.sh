#!/usr/bin/env bash
# Check: beacon runs and shuttle gets HTTP 200 through the beacon Service.
set -uo pipefail

if ! kubectl -n orbit rollout status deployment/beacon --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: deployment/beacon is not available"
  exit 1
fi

code="$(kubectl -n orbit exec deploy/shuttle -- curl -s -o /dev/null -m 5 -w '%{http_code}' http://beacon.orbit.svc.cluster.local/healthz 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got HTTP '${code}' from the beacon Service, expected 200"
  exit 1
fi

echo "PASS: beacon runs and answers through its Service"
