#!/usr/bin/env bash
# Guard check: passes before any change. It fails when hardening breaks scout,
# for example a read-only filesystem or a wrong user that stops the container.
set -uo pipefail

if ! kubectl -n starfleet rollout status deployment/scout --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: the scout Deployment is not fully rolled out"
  exit 1
fi

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -m 5 -w '%{http_code}' http://scout.starfleet.svc.cluster.local/healthz 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got HTTP '${code}' from scout, expected 200"
  exit 1
fi

echo "PASS: shuttle reaches scout (HTTP 200)"
