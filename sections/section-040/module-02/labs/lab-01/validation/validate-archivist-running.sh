#!/usr/bin/env bash
# Check: behaviour. The archivist pod runs and wrote its file to the volume.
set -uo pipefail

phase="$(kubectl -n starfleet get pod archivist -o jsonpath='{.status.phase}' 2>/dev/null || true)"
if [ "$phase" != "Running" ]; then
  echo "FAIL: the archivist pod is '${phase}', expected Running"
  exit 1
fi
content="$(kubectl -n starfleet exec archivist -- cat /archive/owner 2>/dev/null || true)"
if [ "$content" != "logbook" ]; then
  echo "FAIL: /archive/owner in archivist is '${content}', expected logbook"
  exit 1
fi
echo "PASS: archivist runs and writes to the archive volume"
