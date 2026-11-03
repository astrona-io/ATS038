#!/usr/bin/env bash
# Check: Service beacon has ready endpoints and relay reaches it by name.
set -uo pipefail

fail=0
ready="$(kubectl -n orbit get endpointslices -l kubernetes.io/service-name=beacon \
  -o jsonpath='{.items[*].endpoints[*].conditions.ready}' 2>/dev/null || true)"
if ! echo "$ready" | grep -q true; then
  echo "FAIL: Service beacon in orbit has no ready endpoints"
  fail=1
fi

code="$(kubectl -n orbit exec deploy/relay -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' http://beacon/healthz 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: relay got '$code' from http://beacon/healthz (expected 200)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: relay reaches beacon through the Service"
fi
exit "$fail"
