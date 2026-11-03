#!/usr/bin/env bash
# Check: two ledger replicas are ready and the data volume is a claim, not an emptyDir.
set -uo pipefail

ready="$(kubectl -n orbit get statefulset ledger -o jsonpath='{.status.readyReplicas}' 2>/dev/null || true)"
replicas="$(kubectl -n orbit get statefulset ledger -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ "$replicas" != "2" ] || [ "${ready:-0}" != "2" ]; then
  echo "FAIL: ledger has ${ready:-0} ready of ${replicas:-?} replicas, expected 2 of 2"
  exit 1
fi
empty="$(kubectl -n orbit get statefulset ledger -o jsonpath='{.spec.template.spec.volumes[?(@.name=="data")].emptyDir}' 2>/dev/null || true)"
if [ -n "$empty" ]; then
  echo "FAIL: ledger still has an emptyDir volume named data"
  exit 1
fi
path="$(kubectl -n orbit get statefulset ledger -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.name=="data")].mountPath}' 2>/dev/null || true)"
if [ "$path" != "/var/ledger" ]; then
  echo "FAIL: the data volume is mounted at '${path}', expected /var/ledger"
  exit 1
fi
echo "PASS: ledger has 2 ready replicas with the data volume at /var/ledger"
