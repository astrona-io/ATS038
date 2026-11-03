#!/usr/bin/env bash
# Check: the probe Deployment is available and still mounts probe-data.
set -uo pipefail

claim="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}' 2>/dev/null || true)"
if [ "$claim" != "probe-data" ]; then
  echo "FAIL: probe must keep using the claim probe-data, found '${claim}'"
  exit 1
fi
ready="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${ready:-0}" -lt 1 ]; then
  echo "FAIL: the probe Deployment has no available replica"
  exit 1
fi
echo "PASS: probe is available and mounts probe-data"
