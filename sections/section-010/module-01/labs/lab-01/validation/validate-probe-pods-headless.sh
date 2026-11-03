#!/usr/bin/env bash
# Check: Service probe-pods is headless, selects probe, and a client reaches the Pod through it.
set -uo pipefail

fail=0
cluster_ip="$(kubectl -n starfleet get svc probe-pods -o jsonpath='{.spec.clusterIP}' 2>/dev/null || true)"
selector="$(kubectl -n starfleet get svc probe-pods -o jsonpath='{.spec.selector.app}' 2>/dev/null || true)"

if [ "$cluster_ip" != "None" ]; then
  echo "FAIL: Service probe-pods in starfleet is missing or not headless (clusterIP is '$cluster_ip')"
  fail=1
fi
if [ "$selector" != "probe" ]; then
  echo "FAIL: Service probe-pods does not select app=probe"
  fail=1
fi

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' http://probe-pods:8080/get 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got '$code' from http://probe-pods:8080/get (expected 200)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: probe-pods is headless and resolves to the probe Pod"
fi
exit "$fail"
