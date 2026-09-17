#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[[ -f "$ROOT/tools/test-manager.sh" ]]
bash -n "$ROOT/tools/test-manager.sh"
bash "$ROOT/tools/test-manager.sh" syntax >/dev/null
bash "$ROOT/tools/test-manager.sh" security >/dev/null
bash "$ROOT/tools/test-manager.sh" vuln >/dev/null
bash "$ROOT/tools/test-manager.sh" help | grep -q 'vuln'

# The unit manager must include both evidence engines.
bash "$ROOT/tools/test-manager.sh" unit >/dev/null

echo 'test manager tests: PASS'
