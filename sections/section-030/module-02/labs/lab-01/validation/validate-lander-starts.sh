#!/usr/bin/env bash
# Check: lander is available, and it is not running without the setting
# (the environment variable must still come from the ConfigMap).
set -uo pipefail

if ! kubectl -n starfleet rollout status deployment/lander --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: deployment/lander is not available"
  exit 1
fi

name="$(kubectl -n starfleet get deployment lander -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="LANDING_MODE")].valueFrom.configMapKeyRef.name}' 2>/dev/null || true)"
if [ "$name" != "lander-config" ]; then
  echo "FAIL: lander no longer reads LANDING_MODE from the ConfigMap lander-config"
  exit 1
fi

value="$(kubectl -n starfleet get configmap lander-config -o jsonpath='{.data.LANDING_MODE}' 2>/dev/null || true)"
if [ -z "$value" ]; then
  echo "FAIL: the ConfigMap lander-config has no value for LANDING_MODE"
  exit 1
fi

echo "PASS: lander starts with LANDING_MODE=$value from the ConfigMap"
