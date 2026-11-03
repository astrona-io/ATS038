#!/usr/bin/env bash
# Check: beacon-external is a NodePort Service on 30090 that reaches beacon.
set -uo pipefail

fail=0
type="$(kubectl -n orbit get svc beacon-external -o jsonpath='{.spec.type}' 2>/dev/null || true)"
node_port="$(kubectl -n orbit get svc beacon-external -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || true)"

[ "$type" = "NodePort" ] || { echo "FAIL: beacon-external is missing or has type '$type', expected NodePort"; fail=1; }
[ "$node_port" = "30090" ] || { echo "FAIL: nodePort is '$node_port', expected 30090"; fail=1; }

code="$(kubectl -n orbit exec deploy/relay -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' http://beacon-external/healthz 2>/dev/null || true)"
[ "$code" = "200" ] || { echo "FAIL: relay got '$code' from http://beacon-external/healthz (expected 200)"; fail=1; }

if [ "$fail" -eq 0 ]; then
  echo "PASS: beacon-external is a working NodePort Service on 30090"
fi
exit "$fail"
