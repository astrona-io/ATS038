#!/usr/bin/env bash
# Check: warden is Ready, and it is Ready because the probe passes, not because
# the probe was removed.
set -uo pipefail

if ! kubectl -n starfleet rollout status deployment/warden --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: deployment/warden is not available (readiness probe still failing?)"
  exit 1
fi

path="$(kubectl -n starfleet get deployment warden -o jsonpath="{.spec.template.spec.containers[0].readinessProbe.httpGet.path}" 2>/dev/null || true)"
if [ -z "$path" ]; then
  echo "FAIL: warden has no readiness probe. Fix the probe, do not remove it"
  exit 1
fi

echo "PASS: warden passes its readiness probe ($path)"
