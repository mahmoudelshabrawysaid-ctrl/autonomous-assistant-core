#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL="$ROOT/tools/vuln-validation.sh"
bash -n "$TOOL"
bash "$TOOL" self-test
f="$(mktemp)"; trap 'rm -f "$f"' EXIT
printf '%s\n' 'finding=fixture-x' 'proof=proof-x' 'repeatable=yes' 'status=confirmed' 'severity=high' 'remediation=patch-x' > "$f"
out="$(bash "$TOOL" validate "$f")"
grep -q '^verdict=CONFIRMED$' <<<"$out"
grep -q '^finding=fixture-x$' <<<"$out"
grep -q '^severity=high$' <<<"$out"
echo 'vulnerability-validation tests: PASS'
