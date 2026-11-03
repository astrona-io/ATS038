#!/usr/bin/env bash
# Guard check: passes before any change, because probe has no working rule yet.
# It fails when the fix is too broad (a wildcard, edit, admin or cluster-admin).
set -uo pipefail

SA="system:serviceaccount:starfleet:probe"
fail=0

expect_no() {
  local description="$1"
  shift
  local answer
  answer="$(kubectl auth can-i "$@" --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "no" ]; then
    echo "FAIL: probe is allowed to $description"
    fail=1
  fi
}

expect_no "delete pods in starfleet" delete pods -n starfleet
expect_no "read secrets in starfleet" get secrets -n starfleet
expect_no "create deployments in starfleet" create deployments.apps -n starfleet
expect_no "do anything in starfleet" '*' '*' -n starfleet
expect_no "list pods in outpost" list pods -n outpost
expect_no "list pods in every namespace" list pods --all-namespaces

if [ "$fail" -eq 0 ]; then
  echo "PASS: probe has no rights beyond reading pods in starfleet"
fi
exit "$fail"
