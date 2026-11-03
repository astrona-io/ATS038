#!/usr/bin/env bash
# Check: the probe-data claim uses the standard class and is Bound.
set -uo pipefail

class="$(kubectl -n starfleet get pvc probe-data -o jsonpath='{.spec.storageClassName}' 2>/dev/null || true)"
phase="$(kubectl -n starfleet get pvc probe-data -o jsonpath='{.status.phase}' 2>/dev/null || true)"
if [ -z "$phase" ]; then
  echo "FAIL: the claim probe-data does not exist in starfleet"
  exit 1
fi
if [ "$class" != "standard" ]; then
  echo "FAIL: probe-data uses class '${class}', expected standard"
  exit 1
fi
if [ "$phase" != "Bound" ]; then
  echo "FAIL: probe-data is '${phase}', expected Bound"
  exit 1
fi
echo "PASS: probe-data is Bound with class standard"
