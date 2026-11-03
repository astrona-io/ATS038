#!/usr/bin/env bash
# Check: the hand-made PersistentVolume archive-pv has the right shape.
set -uo pipefail

if ! kubectl get pv archive-pv >/dev/null 2>&1; then
  echo "FAIL: the PersistentVolume archive-pv does not exist"
  exit 1
fi
policy="$(kubectl get pv archive-pv -o jsonpath='{.spec.persistentVolumeReclaimPolicy}')"
class="$(kubectl get pv archive-pv -o jsonpath='{.spec.storageClassName}')"
mode="$(kubectl get pv archive-pv -o jsonpath='{.spec.accessModes[0]}')"
size="$(kubectl get pv archive-pv -o jsonpath='{.spec.capacity.storage}')"
hostpath="$(kubectl get pv archive-pv -o jsonpath='{.spec.hostPath.path}')"

if [ "$policy" != "Retain" ]; then
  echo "FAIL: archive-pv has reclaim policy '${policy}', expected Retain"
  exit 1
fi
if [ "$class" != "manual" ] || [ "$mode" != "ReadWriteOnce" ] || [ "$size" != "1Gi" ]; then
  echo "FAIL: archive-pv is ${size}, ${mode}, class '${class}'; expected 1Gi, ReadWriteOnce, class manual"
  exit 1
fi
if [ -z "$hostpath" ]; then
  echo "FAIL: archive-pv has no hostPath"
  exit 1
fi
echo "PASS: archive-pv is a 1Gi ReadWriteOnce hostPath volume with class manual and policy Retain"
