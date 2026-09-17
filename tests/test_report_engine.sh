#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP"
export SEC_LAB_DIR="$HOME/sec_lab"

bash -n "$ROOT/tools/report-engine.sh"
bash -n "$ROOT/tools/vuln-validation.sh"
bash "$ROOT/tools/report-engine.sh" init >/dev/null
printf 'scan result: PASS\n' > "$TMP/result.txt"
report="$(bash "$ROOT/tools/report-engine.sh" from-file ctf localhost Demo "$TMP/result.txt")"
test -f "$report"
grep -q '^# Security Lab Report$' "$report"
grep -q 'Scope:\*\* local-only' "$report"
grep -q 'scan result: PASS' "$report"

printf '%s\n' \
  'finding=synthetic-vulnerability' \
  'proof=deterministic-test-evidence' \
  'repeatable=yes' \
  'status=confirmed' \
  'severity=medium' \
  'remediation=patch-fixture' > "$TMP/vuln.txt"
vuln_report="$(bash "$ROOT/tools/report-engine.sh" from-vuln ctf localhost Vulnerability "$TMP/vuln.txt")"
test -f "$vuln_report"
grep -q '^## Vulnerability Validation$' "$vuln_report"
grep -q '^engine=vulnerability-validation$' "$vuln_report"
grep -q '^verdict=CONFIRMED$' "$vuln_report"
grep -q '^severity=medium$' "$vuln_report"
grep -q 'patch-fixture' "$vuln_report"

bash "$ROOT/tools/report-engine.sh" validate >/dev/null
bash "$ROOT/tools/report-engine.sh" stats | grep -q '^reports=2$'
echo 'report engine tests: PASS'
