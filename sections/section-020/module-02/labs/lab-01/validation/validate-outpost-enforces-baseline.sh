#!/usr/bin/env bash
# Check: outpost enforces exactly the baseline level. The API server rejects a
# privileged pod and accepts a plain pod. Server-side dry runs still run
# admission, so nothing is created.
set -uo pipefail

fail=0

label="$(kubectl get namespace outpost \
  -o jsonpath='{.metadata.labels.pod-security\.kubernetes\.io/enforce}' 2>/dev/null || true)"
if [ "$label" != "baseline" ]; then
  echo "FAIL: outpost enforce label is '${label}', expected 'baseline'"
  fail=1
fi

if cat <<'POD' | kubectl apply --dry-run=server -f - >/dev/null 2>&1; then
apiVersion: v1
kind: Pod
metadata:
  name: probe-privileged
  namespace: outpost
spec:
  containers:
    - name: shell
      image: busybox:1.37
      command: ["sleep", "60"]
      securityContext:
        privileged: true
POD
  echo "FAIL: the API server accepted a privileged pod in outpost"
  fail=1
fi

if ! cat <<'POD' | kubectl apply --dry-run=server -f - >/dev/null 2>&1; then
apiVersion: v1
kind: Pod
metadata:
  name: probe-plain
  namespace: outpost
spec:
  containers:
    - name: shell
      image: busybox:1.37
      command: ["sleep", "60"]
POD
  echo "FAIL: the API server rejected a plain pod in outpost"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: outpost enforces baseline"
fi
exit "$fail"
