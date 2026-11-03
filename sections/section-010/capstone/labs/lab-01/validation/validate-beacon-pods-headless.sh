#!/usr/bin/env bash
# Check: beacon-pods is headless, selects beacon, and has ready endpoints.
set -uo pipefail

fail=0
cluster_ip="$(kubectl -n orbit get svc beacon-pods -o jsonpath='{.spec.clusterIP}' 2>/dev/null || true)"
selector="$(kubectl -n orbit get svc beacon-pods -o jsonpath='{.spec.selector.app}' 2>/dev/null || true)"
ready="$(kubectl -n orbit get endpointslices -l kubernetes.io/service-name=beacon-pods \
  -o jsonpath='{.items[*].endpoints[*].conditions.ready}' 2>/dev/null || true)"

[ "$cluster_ip" = "None" ] || { echo "FAIL: beacon-pods is missing or not headless (clusterIP is '$cluster_ip')"; fail=1; }
[ "$selector" = "beacon" ] || { echo "FAIL: beacon-pods does not select app=beacon"; fail=1; }
echo "$ready" | grep -q true || { echo "FAIL: beacon-pods has no ready endpoints"; fail=1; }

if [ "$fail" -eq 0 ]; then
  echo "PASS: beacon-pods is headless and has ready endpoints"
fi
exit "$fail"
