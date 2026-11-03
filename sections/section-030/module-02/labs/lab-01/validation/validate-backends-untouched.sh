#!/usr/bin/env bash
# Guard: passes before any change. Fails if a fix changes the probe or relay
# pods instead of their Services.
set -uo pipefail

fail=0

for name in probe relay; do
  label="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null || true)"
  port="$(kubectl -n starfleet get deployment "$name" -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}' 2>/dev/null || true)"
  if [ "$label" != "$name" ]; then
    echo "FAIL: the pod label app of deployment/$name changed to '$label'"
    fail=1
  fi
  if [ "$port" != "8080" ]; then
    echo "FAIL: the container port of deployment/$name changed to '$port'"
    fail=1
  fi
done

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -m 5 -w '%{http_code}' http://scout.starfleet.svc.cluster.local/healthz 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got HTTP '${code}' from scout, expected 200"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout works and the probe and relay pods are unchanged"
fi
exit "$fail"
