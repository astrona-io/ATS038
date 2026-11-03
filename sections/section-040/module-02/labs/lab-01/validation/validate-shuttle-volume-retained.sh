#!/usr/bin/env bash
# Check: the dynamically provisioned volume behind shuttle-logs is set to Retain.
set -uo pipefail

volume="$(kubectl -n starfleet get pvc shuttle-logs -o jsonpath='{.spec.volumeName}' 2>/dev/null || true)"
if [ -z "$volume" ]; then
  echo "FAIL: the claim shuttle-logs is missing or not bound to a volume"
  exit 1
fi
policy="$(kubectl get pv "$volume" -o jsonpath='{.spec.persistentVolumeReclaimPolicy}' 2>/dev/null || true)"
if [ "$policy" != "Retain" ]; then
  echo "FAIL: the volume ${volume} behind shuttle-logs has policy '${policy}', expected Retain"
  exit 1
fi
echo "PASS: the volume ${volume} behind shuttle-logs has the Retain policy"
