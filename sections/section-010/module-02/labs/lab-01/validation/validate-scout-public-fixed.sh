#!/usr/bin/env bash
# Check: scout-public selects the scout Pods, has ready endpoints, and a client reaches it.
set -uo pipefail

fail=0
selector="$(kubectl -n starfleet get svc scout-public -o jsonpath='{.spec.selector.app}' 2>/dev/null || true)"
if [ "$selector" != "scout" ]; then
  echo "FAIL: scout-public selects app='$selector', expected app=scout"
  fail=1
fi

ready="$(kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=scout-public \
  -o jsonpath='{.items[*].endpoints[*].conditions.ready}' 2>/dev/null || true)"
if ! echo "$ready" | grep -q true; then
  echo "FAIL: scout-public has no ready endpoints"
  fail=1
fi

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' http://scout-public/healthz 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got '$code' from http://scout-public/healthz (expected 200)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout-public reaches the scout Pods"
fi
exit "$fail"
