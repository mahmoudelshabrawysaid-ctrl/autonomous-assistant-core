#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT
export HOME="$TMP_HOME"
export SEC_LAB_DIR="$TMP_HOME/sec_lab"

bash -n "$ROOT/lab-manager.sh"
bash "$ROOT/lab-manager.sh" >/dev/null

[[ -x "$HOME/bin/sec" ]]
[[ -x "$HOME/bin/guard" ]]
[[ -x "$SEC_LAB_DIR/tools/phone-osint.sh" ]]
[[ -x "$SEC_LAB_DIR/tools/report-engine.sh" ]]
[[ -f "$SEC_LAB_DIR/ctf/targets.tsv" ]]
grep -q $'CTF007\tPhone OSINT Lab\tprivacy\tlocal-only' "$SEC_LAB_DIR/ctf/targets.tsv"

grep -Fxq localhost "$SEC_LAB_DIR/targets/allowlist.txt"
grep -Fxq 127.0.0.1 "$SEC_LAB_DIR/targets/allowlist.txt"
grep -Fxq ::1 "$SEC_LAB_DIR/targets/allowlist.txt"

help_out="$(bash "$HOME/bin/sec" phone help)"
grep -q 'offline, authorized lab workflow' <<<"$help_out"
inspect_out="$(bash "$HOME/bin/sec" phone inspect +201001234567)"
grep -q '^country=Egypt$' <<<"$inspect_out"

fixture="$(bash "$HOME/bin/sec" phone ctf-fixture)"
[[ -f "$fixture/target.json" ]]
grep -q 'CTF Synthetic User' "$fixture/target.json"

! bash "$HOME/bin/guard" 8.8.8.8 >/dev/null 2>&1
! bash "$HOME/bin/guard" 192.168.1.10 >/dev/null 2>&1

echo 'lab-manager tests: PASS'
