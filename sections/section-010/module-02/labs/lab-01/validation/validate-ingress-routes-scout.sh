#!/usr/bin/env bash
# Check: the Ingress starfleet-web routes scout.starfleet.test / to Service scout-public port 80.
set -uo pipefail

fail=0
base='{.spec.rules[?(@.host=="scout.starfleet.test")].http.paths[0]'
path="$(kubectl -n starfleet get ingress starfleet-web -o jsonpath="${base}.path}" 2>/dev/null || true)"
ptype="$(kubectl -n starfleet get ingress starfleet-web -o jsonpath="${base}.pathType}" 2>/dev/null || true)"
svc="$(kubectl -n starfleet get ingress starfleet-web -o jsonpath="${base}.backend.service.name}" 2>/dev/null || true)"
port="$(kubectl -n starfleet get ingress starfleet-web -o jsonpath="${base}.backend.service.port.number}" 2>/dev/null || true)"

[ "$path" = "/" ] || { echo "FAIL: no rule for host scout.starfleet.test with path / (path is '$path')"; fail=1; }
[ "$ptype" = "Prefix" ] || { echo "FAIL: pathType is '$ptype', expected Prefix"; fail=1; }
[ "$svc" = "scout-public" ] || { echo "FAIL: backend Service is '$svc', expected scout-public"; fail=1; }
[ "$port" = "80" ] || { echo "FAIL: backend port is '$port', expected 80"; fail=1; }

if [ "$fail" -eq 0 ]; then
  echo "PASS: the Ingress routes scout.starfleet.test to scout-public:80"
fi
exit "$fail"
