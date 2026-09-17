#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[[ -f "$ROOT/tools/test-manager.sh" ]]
bash -n "$ROOT/tools/test-manager.sh"
bash "$ROOT/tools/test-manager.sh" syntax >/dev/null
bash "$ROOT/tools/test-manager.sh" security >/dev/null
bash "$ROOT/tools/test-manager.sh" vuln >/dev/null
bash "$ROOT/tools/test-manager.sh" help | grep -q 'vuln'

# Avoid invoking `unit` here because unit intentionally runs this test itself.
# Exercise the newly integrated engines directly as a non-recursive smoke test.
bash "$ROOT/tests/test_finding_engine.sh" >/dev/null
bash "$ROOT/tests/test_vuln_validation.sh" >/dev/null

echo 'test manager tests: PASS'
