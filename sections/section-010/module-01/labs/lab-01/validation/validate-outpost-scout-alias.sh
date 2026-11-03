#!/usr/bin/env bash
# Check: drifter in outpost reaches scout by the short name through an ExternalName Service.
set -uo pipefail

fail=0
type="$(kubectl -n outpost get svc scout -o jsonpath='{.spec.type}' 2>/dev/null || true)"
target="$(kubectl -n outpost get svc scout -o jsonpath='{.spec.externalName}' 2>/dev/null || true)"

if [ "$type" != "ExternalName" ]; then
  echo "FAIL: Service scout in outpost is missing or is not of type ExternalName (type is '$type')"
  fail=1
fi
if [ "$target" != "scout.starfleet.svc.cluster.local" ]; then
  echo "FAIL: externalName is '$target', expected scout.starfleet.svc.cluster.local"
  fail=1
fi

code="$(kubectl -n outpost exec deploy/drifter -- curl -s --max-time 5 -o /dev/null -w '%{http_code}' http://scout/healthz 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: drifter got '$code' from http://scout/healthz (expected 200)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: drifter reaches scout by its short name"
fi
exit "$fail"
