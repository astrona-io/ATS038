#!/usr/bin/env bash
# Check: no ClusterRoleBinding names ci-deployer, and the service account
# still exists.
set -uo pipefail

if ! kubectl -n orbit get serviceaccount ci-deployer >/dev/null 2>&1; then
  echo "FAIL: the ci-deployer service account was deleted"
  exit 1
fi

if kubectl get clusterrolebindings \
  -o jsonpath='{range .items[*]}{range .subjects[*]}{.kind}/{.name}/{.namespace}{"\n"}{end}{end}' 2>/dev/null |
  grep -qx 'ServiceAccount/ci-deployer/orbit'; then
  echo "FAIL: a ClusterRoleBinding still names ci-deployer"
  exit 1
fi

echo "PASS: ci-deployer has no cluster-wide binding"
