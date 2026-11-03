#!/usr/bin/env bash
# Guard: the original scout Service still works. It passes before any change and
# fails if the learner edits or deletes it instead of fixing scout-public.
set -uo pipefail

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' http://scout/healthz 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got '$code' from http://scout/healthz (expected 200)"
  exit 1
fi
echo "PASS: the scout Service still answers"
