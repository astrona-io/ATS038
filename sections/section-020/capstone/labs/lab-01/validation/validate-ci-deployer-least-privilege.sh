#!/usr/bin/env bash
# Check: ci-deployer has no more than the Deployment read and update rights.
set -uo pipefail

SA="system:serviceaccount:orbit:ci-deployer"
fail=0

expect_no() {
  local description="$1"
  shift
  local answer
  answer="$(kubectl auth can-i "$@" --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: ci-deployer is allowed to $description"
    fail=1
  fi
}

expect_no "delete deployments in orbit" delete deployments.apps -n orbit
expect_no "read secrets in orbit" get secrets -n orbit
expect_no "create pods in orbit" create pods -n orbit
expect_no "do anything in orbit" '*' '*' -n orbit
expect_no "list deployments in kube-system" list deployments.apps -n kube-system
expect_no "list deployments in every namespace" list deployments.apps --all-namespaces

if [ "$fail" -eq 0 ]; then
  echo "PASS: ci-deployer has only the Deployment rights in orbit"
fi
exit "$fail"
