#!/usr/bin/env bash
# Check: no running shuttle pod has the service account token mounted.
set -uo pipefail

if ! kubectl -n starfleet rollout status deployment/shuttle --timeout=90s >/dev/null 2>&1; then
  echo "FAIL: the shuttle Deployment is not fully rolled out"
  exit 1
fi

lines="$(kubectl -n starfleet get pods -l app=shuttle \
  -o jsonpath='{range .items[*]}{.metadata.deletionTimestamp}{"|"}{.spec.volumes[*].name}{"\n"}{end}' 2>/dev/null || true)"

checked=0
fail=0
while IFS='|' read -r deleted volumes; do
  # Skip pods that are already terminating.
  [ -n "$deleted" ] && continue
  checked=$((checked + 1))
  case "$volumes" in
    *kube-api-access*)
      echo "FAIL: a shuttle pod still mounts the service account token"
      fail=1
      ;;
  esac
done <<<"$lines"

if [ "$checked" -eq 0 ]; then
  echo "FAIL: no running shuttle pod found"
  exit 1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle pods have no service account token mounted"
fi
exit "$fail"
