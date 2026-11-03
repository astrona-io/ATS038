#!/usr/bin/env bash
# Check: the beacon pod template is unprivileged and hardened, and no running
# beacon pod has a service account token mounted.
set -uo pipefail

TEMPLATE='.spec.template.spec'
fail=0

container_value() {
  kubectl -n orbit get deployment beacon \
    -o jsonpath="{${TEMPLATE}.containers[0].securityContext.$1}" 2>/dev/null || true
}
pod_value() {
  kubectl -n orbit get deployment beacon \
    -o jsonpath="{${TEMPLATE}.securityContext.$1}" 2>/dev/null || true
}
effective() {
  local value
  value="$(container_value "$1")"
  [ -z "$value" ] && value="$(pod_value "$1")"
  echo "$value"
}

if [ "$(container_value privileged)" = "true" ]; then
  echo "FAIL: beacon is still privileged"
  fail=1
fi
if [ "$(effective runAsNonRoot)" != "true" ]; then
  echo "FAIL: beacon does not set runAsNonRoot: true"
  fail=1
fi
user="$(effective runAsUser)"
if [ -z "$user" ] || [ "$user" = "0" ]; then
  echo "FAIL: beacon has no numeric non-root runAsUser"
  fail=1
fi
if [ "$(container_value allowPrivilegeEscalation)" != "false" ]; then
  echo "FAIL: beacon does not set allowPrivilegeEscalation: false"
  fail=1
fi
if [ "$(container_value readOnlyRootFilesystem)" != "true" ]; then
  echo "FAIL: beacon does not set readOnlyRootFilesystem: true"
  fail=1
fi
drop="$(kubectl -n orbit get deployment beacon \
  -o jsonpath="{${TEMPLATE}.containers[0].securityContext.capabilities.drop[*]}" 2>/dev/null || true)"
case " $drop " in
  *" ALL "*) ;;
  *)
    echo "FAIL: beacon does not drop all capabilities"
    fail=1
    ;;
esac

# The token: off in the pod template, or off on the service account.
pod_automount="$(kubectl -n orbit get deployment beacon \
  -o jsonpath="{${TEMPLATE}.automountServiceAccountToken}" 2>/dev/null || true)"
sa_automount="$(kubectl -n orbit get serviceaccount beacon \
  -o jsonpath='{.automountServiceAccountToken}' 2>/dev/null || true)"
if [ "$pod_automount" != "false" ] && { [ -n "$pod_automount" ] || [ "$sa_automount" != "false" ]; }; then
  echo "FAIL: beacon pods still receive a service account token"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: beacon is unprivileged, hardened and has no token"
fi
exit "$fail"
