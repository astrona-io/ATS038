#!/usr/bin/env bash
# Check: drifter reads pods in outpost only, with no cluster-wide binding.
set -uo pipefail

SA="system:serviceaccount:outpost:drifter"
fail=0

answer="$(kubectl auth can-i list pods -n outpost --as="$SA" 2>/dev/null || true)"
if [ "$answer" != "yes" ]; then
  echo "FAIL: drifter cannot list pods in outpost"
  fail=1
fi

for args in "list pods -n starfleet" "list pods --all-namespaces" "get secrets -n outpost"; do
  # shellcheck disable=SC2086
  answer="$(kubectl auth can-i $args --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: drifter is allowed to: $args"
    fail=1
  fi
done

if kubectl get clusterrolebindings \
  -o jsonpath='{range .items[*]}{range .subjects[*]}{.kind}/{.name}/{.namespace}{"\n"}{end}{end}' 2>/dev/null |
  grep -qx 'ServiceAccount/drifter/outpost'; then
  echo "FAIL: a ClusterRoleBinding still names the drifter service account"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter reads pods in outpost only"
fi
exit "$fail"
