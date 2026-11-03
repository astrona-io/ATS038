#!/usr/bin/env bash
# Check: the scout Deployment mounts the claim at /data and no longer uses an emptyDir.
set -uo pipefail

claim="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.volumes[?(@.name=="data")].persistentVolumeClaim.claimName}' 2>/dev/null || true)"
empty="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.volumes[?(@.name=="data")].emptyDir}' 2>/dev/null || true)"
path="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.name=="data")].mountPath}' 2>/dev/null || true)"

if [ "$claim" != "scout-data" ]; then
  echo "FAIL: the volume 'data' of scout uses claim '${claim}', expected scout-data"
  exit 1
fi
if [ -n "$empty" ]; then
  echo "FAIL: the volume 'data' still has an emptyDir"
  exit 1
fi
if [ "$path" != "/data" ]; then
  echo "FAIL: the volume is mounted at '${path}', expected /data"
  exit 1
fi
ready="$(kubectl -n starfleet get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${ready:-0}" -lt 1 ]; then
  echo "FAIL: the scout Deployment has no available replica"
  exit 1
fi
echo "PASS: scout mounts scout-data at /data and is available"
