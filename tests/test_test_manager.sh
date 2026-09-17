#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[[ -x "$ROOT/tools/test-manager.sh" || -f "$ROOT/tools/test-manager.sh" ]]
bash -n "$ROOT/tools/test-manager.sh"
"$ROOT/tools/test-manager.sh" syntax >/dev/null
"$ROOT/tools/test-manager.sh" security >/dev/null

echo 'test manager tests: PASS'
