#!/usr/bin/env bash
# Check: scout-nodeport is a NodePort Service on port 30080 with ready scout endpoints.
set -uo pipefail

fail=0
type="$(kubectl -n starfleet get svc scout-nodeport -o jsonpath='{.spec.type}' 2>/dev/null || true)"
node_port="$(kubectl -n starfleet get svc scout-nodeport -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || true)"

if [ "$type" != "NodePort" ]; then
  echo "FAIL: scout-nodeport is missing or has type '$type', expected NodePort"
  fail=1
fi
if [ "$node_port" != "30080" ]; then
  echo "FAIL: nodePort is '$node_port', expected 30080"
  fail=1
fi

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' http://scout-nodeport/healthz 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got '$code' from http://scout-nodeport/healthz (expected 200)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout-nodeport is a working NodePort Service on 30080"
fi
exit "$fail"
