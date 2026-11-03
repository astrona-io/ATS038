#!/usr/bin/env bash
# Guard: passes before any change (shuttle is healthy). Fails if a fix scales a
# Deployment to zero, deletes it or changes the client.
set -uo pipefail

fail=0
for name in shuttle beacon signal relay cargo; do
  replicas="$(kubectl -n orbit get deployment "$name" -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
  if [ -z "$replicas" ] || [ "$replicas" -lt 1 ]; then
    echo "FAIL: deployment/$name is missing or scaled to zero"
    fail=1
  fi
done

if [ -n "$(kubectl get nodes -l disktype -o name 2>/dev/null)" ]; then
  echo "FAIL: a node label was added. Fix the Deployments, not the nodes"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: all five Deployments still run at least one replica"
fi
exit "$fail"
