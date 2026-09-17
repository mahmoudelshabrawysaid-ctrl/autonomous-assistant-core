#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL="$ROOT/tools/phone-osint.sh"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT
export HOME="$TMP_HOME"
export SEC_LAB_DIR="$TMP_HOME/sec_lab"

bash -n "$TOOL"
[[ "$(bash "$TOOL" inspect +201001234567 | grep '^country=')" == 'country=Egypt' ]]
[[ "$(bash "$TOOL" inspect '+20 100-123-4567' | grep '^normalized=')" == 'normalized=+201001234567' ]]
! bash "$TOOL" inspect '01001234567' >/dev/null 2>&1

audit="$(bash "$TOOL" audit +201001234567)"
grep -q '^public-data-that-may-exist=' <<<"$audit"
grep -q '^privacy-risk-checks=' <<<"$audit"
grep -q 'SIM-swap' <<<"$audit"
grep -q '^not-performed=' <<<"$audit"

fixture="$(bash "$TOOL" ctf-fixture)"
[[ -f "$fixture/target.json" ]]
grep -q 'CTF Synthetic User' "$fixture/target.json"

echo 'phone-osint tests: PASS'
