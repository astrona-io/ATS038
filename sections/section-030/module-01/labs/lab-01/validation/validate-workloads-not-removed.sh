#!/usr/bin/env bash
# Guard: passes before any change (scout is healthy). Fails if a fix scales a
# Deployment to zero, deletes it or damages scout.
set -uo pipefail

fail=0
for name in scout shuttle lander hauler tanker rover miner warden; do
  replicas="$(kubectl -n starfleet get deployment "$name" -o jsonpath="{.spec.replicas}" 2>/dev/null || true)"
  if [ -z "$replicas" ] || [ "$replicas" -lt 1 ]; then
    echo "FAIL: deployment/$name is missing or scaled to zero"
    fail=1
  fi
done

image="$(kubectl -n starfleet get deployment scout -o jsonpath="{.spec.template.spec.containers[0].image}" 2>/dev/null || true)"
if [ "$image" != "ghcr.io/stefanprodan/podinfo:6.15.0" ]; then
  echo "FAIL: scout image changed to $image"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: all workloads still run and scout is untouched"
fi
exit "$fail"
