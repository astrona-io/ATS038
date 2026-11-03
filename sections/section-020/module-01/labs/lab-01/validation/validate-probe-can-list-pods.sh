#!/usr/bin/env bash
# Check: the probe service account can read pods in starfleet.
set -uo pipefail

SA="system:serviceaccount:starfleet:probe"
fail=0

for verb in get list watch; do
  answer="$(kubectl auth can-i "$verb" pods -n starfleet --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "yes" ]; then
    echo "FAIL: probe cannot $verb pods in starfleet"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: probe can get, list and watch pods in starfleet"
fi
exit "$fail"
