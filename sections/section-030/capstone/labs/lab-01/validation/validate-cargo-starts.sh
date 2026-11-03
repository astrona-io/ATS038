#!/usr/bin/env bash
# Check: cargo is available and still reads CARGO_TOKEN from the Secret.
set -uo pipefail

if ! kubectl -n orbit rollout status deployment/cargo --timeout=120s >/dev/null 2>&1; then
  echo "FAIL: deployment/cargo is not available"
  exit 1
fi

name="$(kubectl -n orbit get deployment cargo -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="CARGO_TOKEN")].valueFrom.secretKeyRef.name}' 2>/dev/null || true)"
if [ "$name" != "cargo-token" ]; then
  echo "FAIL: cargo no longer reads CARGO_TOKEN from the Secret cargo-token"
  exit 1
fi

if ! kubectl -n orbit get secret cargo-token -o jsonpath='{.data.token}' 2>/dev/null | grep -q .; then
  echo "FAIL: the Secret cargo-token has no key token"
  exit 1
fi

echo "PASS: cargo starts with its token from the Secret"
