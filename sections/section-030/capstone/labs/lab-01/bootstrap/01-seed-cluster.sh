#!/usr/bin/env bash
# Starting state for the troubleshooting capstone. Environment only: it creates
# the namespace, the client and the four faulty applications.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

# Wait only for the healthy client. The four applications fail on purpose.
kubectl -n orbit rollout status deployment/shuttle --timeout=180s
echo "[lab] Ready."
