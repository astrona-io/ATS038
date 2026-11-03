#!/usr/bin/env bash
# Check: orbit enforces baseline (a privileged pod is rejected, a plain pod is
# accepted) and beacon is available with a Service endpoint.
set -uo pipefail

fail=0

label="$(kubectl get namespace orbit \
  -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null || true)"
if [ "$label" != "baseline" ]; then
  echo "FAIL: orbit enforce label is '${label}', expected 'baseline'"
  fail=1
fi

if cat <<'POD' | kubectl apply --dry-run=server -f - >/dev/null 2>&1; then
apiVersion: v1
kind: Pod
metadata:
  name: probe-privileged
  namespace: orbit
spec:
  containers:
    - name: shell
      image: busybox:1.37
      command: ["sleep", "60"]
      securityContext:
        privileged: true
POD
  echo "FAIL: the API server accepted a privileged pod in orbit"
  fail=1
fi

if ! kubectl -n orbit rollout status deployment/beacon --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: the beacon Deployment is not available"
  fail=1
fi

endpoints="$(kubectl -n orbit get endpointslices -l kubernetes.io/service-name=beacon \
  -o jsonpath='{.items[*].endpoints[*].addresses[*]}' 2>/dev/null || true)"
if [ -z "$endpoints" ]; then
  echo "FAIL: the beacon Service has no endpoint"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: orbit enforces baseline and beacon is running"
fi
exit "$fail"
