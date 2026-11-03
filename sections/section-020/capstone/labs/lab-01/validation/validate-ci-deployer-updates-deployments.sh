#!/usr/bin/env bash
# Guard check: passes before any change, because the built-in edit role allows
# it. It fails when the fix leaves ci-deployer without the Deployment rights.
set -uo pipefail

SA="system:serviceaccount:orbit:ci-deployer"
fail=0

for verb in get list watch update patch; do
  answer="$(kubectl auth can-i "$verb" deployments.apps -n orbit --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "yes" ]; then
    echo "FAIL: ci-deployer cannot $verb deployments in orbit"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: ci-deployer can read and update Deployments in orbit"
fi
exit "$fail"
