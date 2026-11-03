#!/usr/bin/env bash
# Check: the reporter Deployment is available and report-cache is Bound with class standard.
set -uo pipefail

class="$(kubectl -n orbit get pvc report-cache -o jsonpath='{.spec.storageClassName}' 2>/dev/null || true)"
phase="$(kubectl -n orbit get pvc report-cache -o jsonpath='{.status.phase}' 2>/dev/null || true)"
if [ "$class" != "standard" ] || [ "$phase" != "Bound" ]; then
  echo "FAIL: report-cache is '${phase}' with class '${class}', expected Bound with standard"
  exit 1
fi
claim="$(kubectl -n orbit get deployment reporter -o jsonpath='{.spec.template.spec.volumes[0].persistentVolumeClaim.claimName}' 2>/dev/null || true)"
if [ "$claim" != "report-cache" ]; then
  echo "FAIL: reporter must keep using the claim report-cache, found '${claim}'"
  exit 1
fi
ready="$(kubectl -n orbit get deployment reporter -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${ready:-0}" -lt 1 ]; then
  echo "FAIL: the reporter Deployment has no available replica"
  exit 1
fi
echo "PASS: reporter is available and report-cache is Bound with class standard"
