#!/usr/bin/env bash
# Check: shuttle gets the api-key Secret as a read-only file, not as a variable.
set -uo pipefail

fail=0

if ! kubectl -n starfleet rollout status deployment/shuttle --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: the shuttle Deployment is not fully rolled out"
  exit 1
fi

# No environment variable may take its value from a Secret.
refs="$(kubectl -n starfleet get deployment shuttle \
  -o jsonpath='{.spec.template.spec.containers[*].env[*].valueFrom.secretKeyRef.name}' 2>/dev/null || true)"
if [ -n "$refs" ]; then
  echo "FAIL: shuttle still reads a Secret through an environment variable"
  fail=1
fi

# A secret volume for api-key, mounted read-only.
volume="$(kubectl -n starfleet get deployment shuttle \
  -o jsonpath='{.spec.template.spec.volumes[?(@.secret.secretName=="api-key")].name}' 2>/dev/null || true)"
if [ -z "$volume" ]; then
  echo "FAIL: shuttle has no volume from the Secret api-key"
  fail=1
else
  readonly_flag="$(kubectl -n starfleet get deployment shuttle \
    -o jsonpath="{.spec.template.spec.containers[0].volumeMounts[?(@.name==\"${volume}\")].readOnly}" 2>/dev/null || true)"
  if [ "$readonly_flag" != "true" ]; then
    echo "FAIL: the api-key volume is not mounted read-only"
    fail=1
  fi
fi

# Behaviour: the running pod reads the value from a file and has no variable.
expected="$(kubectl -n starfleet get secret api-key -o jsonpath='{.data.token}' 2>/dev/null | base64 -d 2>/dev/null || true)"
found="$(kubectl -n starfleet exec deploy/shuttle -- sh -c 'cat /etc/api-key/token' 2>/dev/null || true)"
if [ -z "$expected" ] || [ "$found" != "$expected" ]; then
  echo "FAIL: /etc/api-key/token in the shuttle pod does not hold the Secret value"
  fail=1
fi
variable="$(kubectl -n starfleet exec deploy/shuttle -- sh -c 'echo "${API_KEY:-}"' 2>/dev/null || true)"
if [ -n "$variable" ]; then
  echo "FAIL: the shuttle pod still has the API_KEY environment variable"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle reads the Secret from a read-only file"
fi
exit "$fail"
