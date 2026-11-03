#!/usr/bin/env bash
# Check: the scout pod template sets the hardening fields, at pod or container
# level. The container value wins when both are set.
set -uo pipefail

TEMPLATE='.spec.template.spec'
fail=0

container_value() {
  kubectl -n starfleet get deployment scout \
    -o jsonpath="{${TEMPLATE}.containers[0].securityContext.$1}" 2>/dev/null || true
}
pod_value() {
  kubectl -n starfleet get deployment scout \
    -o jsonpath="{${TEMPLATE}.securityContext.$1}" 2>/dev/null || true
}
effective() {
  local value
  value="$(container_value "$1")"
  [ -z "$value" ] && value="$(pod_value "$1")"
  echo "$value"
}

if [ "$(effective runAsNonRoot)" != "true" ]; then
  echo "FAIL: scout does not set runAsNonRoot: true"
  fail=1
fi
user="$(effective runAsUser)"
if [ -z "$user" ] || [ "$user" = "0" ]; then
  echo "FAIL: scout has no numeric non-root runAsUser"
  fail=1
fi
if [ "$(container_value allowPrivilegeEscalation)" != "false" ]; then
  echo "FAIL: scout does not set allowPrivilegeEscalation: false"
  fail=1
fi
if [ "$(container_value readOnlyRootFilesystem)" != "true" ]; then
  echo "FAIL: scout does not set readOnlyRootFilesystem: true"
  fail=1
fi
drop="$(kubectl -n starfleet get deployment scout \
  -o jsonpath="{${TEMPLATE}.containers[0].securityContext.capabilities.drop[*]}" 2>/dev/null || true)"
case " $drop " in
  *" ALL "*) ;;
  *)
    echo "FAIL: scout does not drop all capabilities"
    fail=1
    ;;
esac

if [ "$fail" -eq 0 ]; then
  echo "PASS: scout sets the hardening fields"
fi
exit "$fail"
