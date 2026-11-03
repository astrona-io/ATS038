#!/usr/bin/env bash
# Guard: the original probe Service still works. It passes before any change and
# fails if the learner replaces or breaks it.
set -uo pipefail

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' http://probe/get 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got '$code' from http://probe/get (expected 200)"
  exit 1
fi
echo "PASS: the probe Service still answers"
