#!/usr/bin/env bash
# Guard check: passes before any change. It fails when a fix breaks a workload,
# for example by deleting a Deployment or a service account.
set -uo pipefail

fail=0
for name in scout probe shuttle; do
  if ! kubectl -n starfleet rollout status "deployment/$name" --timeout=60s >/dev/null 2>&1; then
    echo "FAIL: deployment $name in starfleet is not available"
    fail=1
  fi
done
if ! kubectl -n outpost rollout status deployment/drifter --timeout=60s >/dev/null 2>&1; then
  echo "FAIL: deployment drifter in outpost is not available"
  fail=1
fi
for sa in starfleet/probe starfleet/shuttle outpost/drifter; do
  if ! kubectl -n "${sa%%/*}" get serviceaccount "${sa##*/}" >/dev/null 2>&1; then
    echo "FAIL: service account $sa was deleted"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: all workloads and service accounts are in place"
fi
exit "$fail"
