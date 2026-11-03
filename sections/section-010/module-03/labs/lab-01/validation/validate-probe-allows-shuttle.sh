#!/usr/bin/env bash
# Check: shuttle still reaches probe on port 8080 by Pod address.
set -uo pipefail
pod_ip() {
  kubectl -n starfleet get pod -l "app=$1" -o jsonpath='{.items[0].status.podIP}' 2>/dev/null || true
}

# status_from NAMESPACE DEPLOYMENT URL prints the HTTP status, or 000 on failure.
status_from() {
  kubectl -n "$1" exec "deploy/$2" -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' "$3" 2>/dev/null || true
}

ip="$(pod_ip probe)"
code="$(status_from starfleet shuttle "http://$ip:8080/get")"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got '$code' from the probe Pod (expected 200)"
  exit 1
fi
echo "PASS: shuttle reaches probe on 8080"
