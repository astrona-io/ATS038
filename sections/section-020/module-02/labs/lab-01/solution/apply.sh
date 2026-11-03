#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

# 1. Harden scout.
kubectl -n starfleet patch deployment scout --type merge -p '{
  "spec": {"template": {"spec": {
    "securityContext": {"runAsNonRoot": true, "runAsUser": 10001, "runAsGroup": 10001},
    "containers": [{
      "name": "scout",
      "securityContext": {
        "allowPrivilegeEscalation": false,
        "readOnlyRootFilesystem": true,
        "capabilities": {"drop": ["ALL"]}
      }
    }]
  }}}
}'

# 2. Deliver the Secret to shuttle as a read-only volume, not as a variable.
kubectl -n starfleet patch deployment shuttle --type json -p '[
  {"op": "remove", "path": "/spec/template/spec/containers/0/env"},
  {"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts",
   "value": [{"name": "api-key", "mountPath": "/etc/api-key", "readOnly": true}]},
  {"op": "add", "path": "/spec/template/spec/volumes",
   "value": [{"name": "api-key", "secret": {"secretName": "api-key"}}]}
]'

# 3. Remove the privilege from debug-tool, then enforce baseline on outpost.
kubectl -n outpost patch deployment debug-tool --type json -p '[
  {"op": "replace", "path": "/spec/template/spec/containers/0/securityContext/privileged", "value": false}
]'
kubectl -n outpost rollout status deployment/debug-tool --timeout=180s
kubectl label namespace outpost pod-security.kubernetes.io/enforce=baseline --overwrite

for name in scout shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
echo "[solution] Applied."
