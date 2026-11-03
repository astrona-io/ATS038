#!/usr/bin/env bash
# Check: the probe Service selects the probe pod and shuttle gets HTTP 200
# through the Service name.
set -uo pipefail

ready="$(kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe -o jsonpath='{.items[*].endpoints[*].addresses[0]}' 2>/dev/null || true)"
if [ -z "$ready" ]; then
  echo "FAIL: the probe Service has no endpoint"
  exit 1
fi

code="$(kubectl -n starfleet exec deploy/shuttle -- curl -s -o /dev/null -m 5 -w '%{http_code}' http://probe.starfleet.svc.cluster.local/get 2>/dev/null || true)"
if [ "$code" != "200" ]; then
  echo "FAIL: shuttle got HTTP '${code}' from the probe Service, expected 200"
  exit 1
fi

echo "PASS: the probe Service has an endpoint and answers with HTTP 200"
