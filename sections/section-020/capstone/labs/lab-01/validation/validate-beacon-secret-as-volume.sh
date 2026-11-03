#!/usr/bin/env bash
# Check: beacon gets the beacon-key Secret as a read-only file, not as a variable.
set -uo pipefail

fail=0

if ! kubectl -n orbit rollout status deployment/beacon --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: the beacon Deployment is not fully rolled out"
  exit 1
fi

refs="$(kubectl -n orbit get deployment beacon \
  -o jsonpath='{.spec.template.spec.containers[*].env[*].valueFrom.secretKeyRef.name}' 2>/dev/null || true)"
if [ -n "$refs" ]; then
  echo "FAIL: beacon still reads a Secret through an environment variable"
  fail=1
fi

volume="$(kubectl -n orbit get deployment beacon \
  -o jsonpath='{.spec.template.spec.volumes[?(@.secret.secretName=="beacon-key")].name}' 2>/dev/null || true)"
if [ -z "$volume" ]; then
  echo "FAIL: beacon has no volume from the Secret beacon-key"
  fail=1
else
  readonly_flag="$(kubectl -n orbit get deployment beacon \
    -o jsonpath="{.spec.template.spec.containers[0].volumeMounts[?(@.name==\"${volume}\")].readOnly}" 2>/dev/null || true)"
  if [ "$readonly_flag" != "true" ]; then
    echo "FAIL: the beacon-key volume is not mounted read-only"
    fail=1
  fi
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: beacon reads the Secret from a read-only volume"
fi
exit "$fail"
