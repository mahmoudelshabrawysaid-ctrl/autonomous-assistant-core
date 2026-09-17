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
[[ "$(bash "$TOOL" inspect '01001234567' | grep '^normalized=')" == 'normalized=+201001234567' ]]

audit="$(bash "$TOOL" audit +201001234567)"
grep -q '^public-intelligence-scope=' <<<"$audit"
grep -q '^privacy-risk-checks=' <<<"$audit"
grep -q 'public disclosure' <<<"$audit"
grep -q '^not-performed=' <<<"$audit"
grep -q 'OTP' <<<"$audit"

deep="$(bash "$TOOL" deep +201001234567)"
grep -q '^deep_status=completed' <<<"$deep"
grep -q '^observed_at=' <<<"$deep"
grep -q '^provider_config=' <<<"$deep"
grep -q 'Evidence must be public' <<<"$deep"
grep -q 'Identity, address, private profile' <<<"$deep"
grep -q '^evidence_state=NONE' <<<"$deep"
grep -q '^correlation_status=INSUFFICIENT_EVIDENCE' <<<"$deep"
grep -q '^confidence=LOW' <<<"$deep"
grep -q '^risk=UNDETERMINED' <<<"$deep"
grep -q '^remediation=' <<<"$deep"

fixture="$(bash "$TOOL" ctf-fixture)"
[[ -f "$fixture/target.json" ]]
grep -q 'CTF Synthetic User' "$fixture/target.json"

echo 'phone-osint tests: PASS'
