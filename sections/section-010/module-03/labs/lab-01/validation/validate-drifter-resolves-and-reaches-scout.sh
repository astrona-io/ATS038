#!/usr/bin/env bash
# Guard: drifter still resolves scout and reaches it. It passes before any
# change, and it fails when the egress policy forgets DNS or port 9898.
set -uo pipefail
pod_ip() {
  kubectl -n starfleet get pod -l "app=$1" -o jsonpath='{.items[0].status.podIP}' 2>/dev/null || true
}

# status_from NAMESPACE DEPLOYMENT URL prints the HTTP status, or 000 on failure.
status_from() {
  kubectl -n "$1" exec "deploy/$2" -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' "$3" 2>/dev/null || true
}

code="$(status_from outpost drifter "http://scout.starfleet/healthz")"
if [ "$code" != "200" ]; then
  echo "FAIL: drifter got '$code' from http://scout.starfleet/healthz (expected 200). Check the DNS rule and the scout Pod port."
  exit 1
fi
echo "PASS: drifter resolves and reaches scout"
