#!/usr/bin/env bash
# Check: debug-tool still runs, and no container in it is privileged.
set -uo pipefail

if ! kubectl -n outpost rollout status deployment/debug-tool --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: the debug-tool Deployment is not available"
  exit 1
fi

privileged="$(kubectl -n outpost get deployment debug-tool \
  -o jsonpath='{.spec.template.spec.containers[*].securityContext.privileged}' 2>/dev/null || true)"
case "$privileged" in
  *true*)
    echo "FAIL: a debug-tool container is still privileged"
    exit 1
    ;;
esac

running="$(kubectl -n outpost get pods -l app=debug-tool --field-selector=status.phase=Running \
  -o jsonpath='{.items[*].metadata.name}' 2>/dev/null || true)"
if [ -z "$running" ]; then
  echo "FAIL: no debug-tool pod is running"
  exit 1
fi

echo "PASS: debug-tool runs without privilege"
