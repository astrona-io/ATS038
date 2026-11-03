#!/usr/bin/env bash
# Starting state for the Services lab. Environment only: it creates the
# Starfleet workloads and the faulty scout-public Service. It does not create
# the NodePort Service or the Ingress that the learner must write.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl apply -f "$DIR/manifests/scout-public.yaml"

for name in scout probe shuttle; do
  kubectl -n starfleet rollout status "deployment/$name" --timeout=180s
done
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
