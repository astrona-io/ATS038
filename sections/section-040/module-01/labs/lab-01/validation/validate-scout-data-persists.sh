#!/usr/bin/env bash
# Check: behaviour. A file written to /data survives deletion of the pod.
# This check deletes the scout pod once and waits for the replacement.
set -uo pipefail

old_pod="$(kubectl -n starfleet get pods -l app=scout -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
if [ -z "$old_pod" ]; then
  echo "FAIL: no scout pod found"
  exit 1
fi
if ! kubectl -n starfleet exec "$old_pod" -- sh -c 'echo persisted > /data/validation-marker' >/dev/null 2>&1; then
  echo "FAIL: could not write to /data in ${old_pod}"
  exit 1
fi

kubectl -n starfleet delete pod "$old_pod" --wait=true >/dev/null 2>&1

new_pod=""
for _ in $(seq 1 60); do
  candidate="$(kubectl -n starfleet get pods -l app=scout --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
  if [ -n "$candidate" ] && [ "$candidate" != "$old_pod" ]; then
    new_pod="$candidate"
    break
  fi
  sleep 2
done
if [ -z "$new_pod" ]; then
  echo "FAIL: no replacement scout pod reached Running"
  exit 1
fi

content="$(kubectl -n starfleet exec "$new_pod" -- cat /data/validation-marker 2>/dev/null || true)"
if [ "$content" != "persisted" ]; then
  echo "FAIL: the file written before the pod was deleted is missing in ${new_pod}"
  exit 1
fi
echo "PASS: /data survived the deletion of the scout pod"
