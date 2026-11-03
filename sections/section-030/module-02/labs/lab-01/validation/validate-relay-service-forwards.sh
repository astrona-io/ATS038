#!/usr/bin/env bash
# Check: the relay Service forwards to the port the container listens on.
set -uo pipefail

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -m 5 -w '%{http_code}' http://relay.starfleet.svc.cluster.local/get 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got HTTP '${code}' from the relay Service, expected 200"
  exit 1
fi

echo "PASS: shuttle reaches relay through its Service"
