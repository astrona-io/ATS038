#!/usr/bin/env bash
# Check: the ledger StatefulSet gives each replica its own Bound claim from
# a volumeClaimTemplate named data, with class standard, 1Gi, ReadWriteOnce.
set -uo pipefail

template="$(kubectl -n orbit get statefulset ledger -o jsonpath='{.spec.volumeClaimTemplates[0].metadata.name}' 2>/dev/null || true)"
if [ "$template" != "data" ]; then
  echo "FAIL: the StatefulSet ledger has no volumeClaimTemplate named data"
  exit 1
fi
for claim in data-ledger-0 data-ledger-1; do
  phase="$(kubectl -n orbit get pvc "$claim" -o jsonpath='{.status.phase}' 2>/dev/null || true)"
  class="$(kubectl -n orbit get pvc "$claim" -o jsonpath='{.spec.storageClassName}' 2>/dev/null || true)"
  mode="$(kubectl -n orbit get pvc "$claim" -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null || true)"
  size="$(kubectl -n orbit get pvc "$claim" -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null || true)"
  if [ "$phase" != "Bound" ]; then
    echo "FAIL: claim ${claim} is '${phase}', expected Bound"
    exit 1
  fi
  if [ "$class" != "standard" ] || [ "$mode" != "ReadWriteOnce" ] || [ "$size" != "1Gi" ]; then
    echo "FAIL: claim ${claim} is ${size}, ${mode}, class '${class}'; expected 1Gi, ReadWriteOnce, standard"
    exit 1
  fi
done
echo "PASS: data-ledger-0 and data-ledger-1 are Bound (1Gi, ReadWriteOnce, standard)"
