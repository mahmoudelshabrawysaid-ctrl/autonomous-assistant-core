#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL="$ROOT/tools/finding-engine.sh"
bash -n "$TOOL"
bash "$TOOL" self-test
f="$(mktemp)"
trap 'rm -f "$f"' EXIT
printf '%s\n' 'finding=synthetic-x' 'evidence=proof' 'source=a' 'source=b' 'status=confirmed' 'severity=medium' 'remediation=patch-local-target' > "$f"
out="$(bash "$TOOL" from-file ctf target "$f")"
grep -q '^confidence=confirmed$' <<<"$out"
grep -q '^verdict=confirmed$' <<<"$out"
grep -q '^remediation=patch-local-target$' <<<"$out"
echo 'finding-engine tests: PASS'
