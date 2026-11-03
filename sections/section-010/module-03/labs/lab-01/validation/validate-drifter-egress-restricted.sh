#!/usr/bin/env bash
# Check: drifter cannot reach relay (no egress rule), while relay has no
# ingress policy, so only the egress policy of drifter can stop the request.
set -uo pipefail
pod_ip() {
  kubectl -n starfleet get pod -l "app=$1" -o jsonpath='{.items[0].status.podIP}' 2>/dev/null || true
}

# status_from NAMESPACE DEPLOYMENT URL prints the HTTP status, or 000 on failure.
status_from() {
  kubectl -n "$1" exec "deploy/$2" -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' "$3" 2>/dev/null || true
}

ip="$(pod_ip relay)"
code="$(status_from outpost drifter "http://$ip:8080/get")"
if [ "$code" = "200" ]; then
  echo "FAIL: drifter still reaches the relay Pod. Restrict its egress."
  exit 1
fi
echo "PASS: drifter egress to relay is blocked"
