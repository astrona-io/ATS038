#!/usr/bin/env bash
# Check: guard. shuttle-logs is still Bound and the marker file is still
# there. It passes before any change, and it fails if the learner deletes
# and re-creates the claim.
set -uo pipefail

phase="$(kubectl -n starfleet get pvc shuttle-logs -o jsonpath='{.status.phase}' 2>/dev/null || true)"
if [ "$phase" != "Bound" ]; then
  echo "FAIL: shuttle-logs is '${phase}', expected Bound. Do not delete the claim."
  exit 1
fi
content="$(kubectl -n starfleet exec deploy/shuttle -- cat /logs/marker.txt 2>/dev/null || true)"
if [ "$content" != "shuttle-log" ]; then
  echo "FAIL: /logs/marker.txt in shuttle is '${content}', expected shuttle-log"
  exit 1
fi
echo "PASS: shuttle-logs is Bound and its data is intact"
