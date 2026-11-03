#!/usr/bin/env bash
# Check: the ConfigMap probe-address holds the current IP address of the probe Pod.
set -uo pipefail

actual="$(kubectl -n starfleet get pod -l app=probe -o jsonpath='{.items[0].status.podIP}' 2>/dev/null || true)"
recorded="$(kubectl -n starfleet get configmap probe-address -o jsonpath='{.data.podIP}' 2>/dev/null || true)"

if [ -z "$actual" ]; then
  echo "FAIL: the probe Pod has no IP address yet"
  exit 1
fi
if [ -z "$recorded" ]; then
  echo "FAIL: ConfigMap probe-address in starfleet has no key podIP"
  exit 1
fi
if [ "$recorded" != "$actual" ]; then
  echo "FAIL: probe-address records $recorded but the probe Pod has $actual"
  exit 1
fi
echo "PASS: probe-address records the probe Pod IP"
