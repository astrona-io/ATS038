#!/usr/bin/env bash
# Starting state for the storage capstone. Environment only: it creates the
# faulty workloads. It creates no volumeClaimTemplates and no valid claim.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n orbit rollout status statefulset/ledger --timeout=240s
echo "[lab] Ready."
