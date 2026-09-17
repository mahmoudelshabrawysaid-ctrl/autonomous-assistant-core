#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP"
export SEC_LAB_DIR="$HOME/sec_lab"

bash -n "$ROOT/tools/report-engine.sh"
bash "$ROOT/tools/report-engine.sh" init >/dev/null
printf 'scan result: PASS\n' > "$TMP/result.txt"
report="$(bash "$ROOT/tools/report-engine.sh" from-file ctf localhost Demo "$TMP/result.txt")"
test -f "$report"
grep -q '^# Security Lab Report$' "$report"
grep -q 'Scope:\*\* local-only' "$report"
grep -q 'scan result: PASS' "$report"
bash "$ROOT/tools/report-engine.sh" validate >/dev/null
bash "$ROOT/tools/report-engine.sh" stats | grep -q '^reports=1$'
echo 'report engine tests: PASS'
