#!/usr/bin/env bash
# Check: archive-claim in starfleet is bound to archive-pv.
set -uo pipefail

phase="$(kubectl -n starfleet get pvc archive-claim -o jsonpath='{.status.phase}' 2>/dev/null || true)"
volume="$(kubectl -n starfleet get pvc archive-claim -o jsonpath='{.spec.volumeName}' 2>/dev/null || true)"
if [ -z "$phase" ]; then
  echo "FAIL: the claim archive-claim does not exist in starfleet"
  exit 1
fi
if [ "$phase" != "Bound" ] || [ "$volume" != "archive-pv" ]; then
  echo "FAIL: archive-claim is '${phase}' on volume '${volume}', expected Bound to archive-pv"
  exit 1
fi
echo "PASS: archive-claim is Bound to archive-pv"
