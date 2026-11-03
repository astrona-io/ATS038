#!/usr/bin/env bash
# Check: behaviour. A file written in ledger-0 survives deletion of that pod.
# This check deletes the pod ledger-0 once and waits for its replacement.
set -uo pipefail

if ! kubectl -n orbit exec ledger-0 -- sh -c 'echo entry-1 > /var/ledger/validation-entry' >/dev/null 2>&1; then
  echo "FAIL: could not write to /var/ledger in ledger-0"
  exit 1
fi
old_uid="$(kubectl -n orbit get pod ledger-0 -o jsonpath='{.metadata.uid}')"
kubectl -n orbit delete pod ledger-0 --wait=true >/dev/null 2>&1

ok=0
for _ in $(seq 1 60); do
  new_uid="$(kubectl -n orbit get pod ledger-0 -o jsonpath='{.metadata.uid}' 2>/dev/null || true)"
  phase="$(kubectl -n orbit get pod ledger-0 -o jsonpath='{.status.phase}' 2>/dev/null || true)"
  if [ -n "$new_uid" ] && [ "$new_uid" != "$old_uid" ] && [ "$phase" = "Running" ]; then
    ok=1
    break
  fi
  sleep 2
done
if [ "$ok" -ne 1 ]; then
  echo "FAIL: ledger-0 did not come back as a new running pod"
  exit 1
fi

content="$(kubectl -n orbit exec ledger-0 -- cat /var/ledger/validation-entry 2>/dev/null || true)"
if [ "$content" != "entry-1" ]; then
  echo "FAIL: the entry written before the deletion is missing in the new ledger-0"
  exit 1
fi
echo "PASS: the data in /var/ledger survived the deletion of ledger-0"
