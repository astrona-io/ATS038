#!/usr/bin/env bash
# Check: lander and hauler are scheduled and available. Rejects the shortcut of
# labelling the node with disktype=quantum.
set -uo pipefail

fail=0
for name in lander hauler; do
  if ! kubectl -n starfleet rollout status "deployment/$name" --timeout=90s >/dev/null 2>&1; then
    echo "FAIL: deployment/$name is not available"
    fail=1
  fi
done

if [ -n "$(kubectl get nodes -l disktype=quantum -o name 2>/dev/null)" ]; then
  echo "FAIL: a node was labelled disktype=quantum. Change the Deployment, not the node"
  fail=1
fi

cpu="$(kubectl -n starfleet get deployment hauler -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}" 2>/dev/null || true)"
case "$cpu" in
  64|64000m) echo "FAIL: hauler still requests $cpu CPU"; fail=1 ;;
esac

if [ "$fail" -eq 0 ]; then
  echo "PASS: lander and hauler are scheduled and available"
fi
exit "$fail"
