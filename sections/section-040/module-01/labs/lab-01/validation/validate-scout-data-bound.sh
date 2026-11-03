#!/usr/bin/env bash
# Check: the claim scout-data exists, uses the standard class, and is Bound.
set -uo pipefail

phase="$(kubectl -n starfleet get pvc scout-data -o jsonpath='{.status.phase}' 2>/dev/null || true)"
if [ -z "$phase" ]; then
  echo "FAIL: the claim scout-data does not exist in starfleet"
  exit 1
fi
class="$(kubectl -n starfleet get pvc scout-data -o jsonpath='{.spec.storageClassName}')"
mode="$(kubectl -n starfleet get pvc scout-data -o jsonpath='{.spec.accessModes[0]}')"
size="$(kubectl -n starfleet get pvc scout-data -o jsonpath='{.spec.resources.requests.storage}')"

if [ "$phase" != "Bound" ]; then
  echo "FAIL: scout-data is '${phase}', expected Bound (a Pod must use it if the class waits for a consumer)"
  exit 1
fi
if [ "$class" != "standard" ]; then
  echo "FAIL: scout-data uses class '${class}', expected standard"
  exit 1
fi
if [ "$mode" != "ReadWriteOnce" ] || [ "$size" != "1Gi" ]; then
  echo "FAIL: scout-data asks for ${size} with ${mode}, expected 1Gi with ReadWriteOnce"
  exit 1
fi
echo "PASS: scout-data is Bound, 1Gi, ReadWriteOnce, class standard"
