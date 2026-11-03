#!/usr/bin/env bash
# Check: miner is available and no current container was OOMKilled.
set -uo pipefail

if ! kubectl -n starfleet rollout status deployment/miner --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: deployment/miner is not available"
  exit 1
fi

reasons="$(kubectl -n starfleet get pods -l app=miner -o jsonpath="{.items[*].status.containerStatuses[*].lastState.terminated.reason}" 2>/dev/null || true)"
case "$reasons" in
  *OOMKilled*) echo "FAIL: a miner container was OOMKilled"; exit 1 ;;
esac

echo "PASS: miner runs within its memory limit"
