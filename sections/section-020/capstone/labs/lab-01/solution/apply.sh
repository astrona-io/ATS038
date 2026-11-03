#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

# 1. ci-deployer: a namespaced Role and RoleBinding, then remove the cluster-wide grant.
kubectl -n orbit create role deployment-updater \
  --verb=get,list,watch,update,patch --resource=deployments.apps
kubectl -n orbit create rolebinding ci-deployer-deployment-updater \
  --role=deployment-updater --serviceaccount=orbit:ci-deployer
kubectl delete clusterrolebinding ci-deployer-edit

# 2. beacon: harden it, drop the token, deliver the Secret as a volume.
kubectl -n orbit patch deployment beacon --type json -p '[
  {"op": "remove", "path": "/spec/template/spec/containers/0/env"},
  {"op": "replace", "path": "/spec/template/spec/containers/0/securityContext",
   "value": {"privileged": false, "allowPrivilegeEscalation": false,
             "readOnlyRootFilesystem": true, "capabilities": {"drop": ["ALL"]}}},
  {"op": "add", "path": "/spec/template/spec/containers/0/volumeMounts",
   "value": [{"name": "beacon-key", "mountPath": "/etc/beacon-key", "readOnly": true}]},
  {"op": "add", "path": "/spec/template/spec/volumes",
   "value": [{"name": "beacon-key", "secret": {"secretName": "beacon-key"}}]},
  {"op": "add", "path": "/spec/template/spec/automountServiceAccountToken", "value": false},
  {"op": "add", "path": "/spec/template/spec/securityContext",
   "value": {"runAsNonRoot": true, "runAsUser": 10001, "runAsGroup": 10001}}
]'
kubectl -n orbit rollout status deployment/beacon --timeout=180s

# 3. Enforce baseline on the namespace.
kubectl label namespace orbit pod-security.kubernetes.io/enforce=baseline --overwrite
echo "[solution] Applied."
