#!/usr/bin/env bash
# Check: the volumes behind data-ledger-0 and data-ledger-1 keep their data
# when the claims are deleted (reclaim policy Retain).
set -uo pipefail

for claim in data-ledger-0 data-ledger-1; do
  volume="$(kubectl -n orbit get pvc "$claim" -o jsonpath='{.spec.volumeName}' 2>/dev/null || true)"
  if [ -z "$volume" ]; then
    echo "FAIL: claim ${claim} is missing or not bound"
    exit 1
  fi
  policy="$(kubectl get pv "$volume" -o jsonpath='{.spec.persistentVolumeReclaimPolicy}' 2>/dev/null || true)"
  if [ "$policy" != "Retain" ]; then
    echo "FAIL: volume ${volume} behind ${claim} has policy '${policy}', expected Retain"
    exit 1
  fi
done
echo "PASS: both ledger volumes have the Retain policy"
