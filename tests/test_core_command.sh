#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE="$ROOT_DIR/core-command.sh"
SHORTCUTS="$ROOT_DIR/shortcuts.json"
ROUTER="$ROOT_DIR/router.json"

bash -n "$CORE"
python3 -m json.tool "$SHORTCUTS" >/dev/null
python3 -m json.tool "$ROUTER" >/dev/null

security_out="$(bash "$CORE" classify 'اعمل فحص للاب CTF')"
[[ "$security_out" == "security" ]]
code_out="$(bash "$CORE" classify 'fix github workflow bug')"
[[ "$code_out" == "code" ]]
english_out="$(bash "$CORE" classify 'ساعدني في النطق بالانجليزي')"
[[ "$english_out" == "english" ]]
football_out="$(bash "$CORE" classify 'اعرف نتيجة المباراة')"
[[ "$football_out" == "football" ]]
integration_out="$(bash "$CORE" classify 'ظبط notion plugin')"
[[ "$integration_out" == "integrations" ]]
general_out="$(bash "$CORE" classify 'اعمل خطة للمشروع')"
[[ "$general_out" == "general" ]]

route_out="$(bash "$CORE" route 'اعمل فحص للاب CTF')"
grep -q '^area=security$' <<<"$route_out"
grep -q '^gateway=/sec$' <<<"$route_out"
grep -q '^execution=authorized-tools-only$' <<<"$route_out"
grep -q '^validation=required$' <<<"$route_out"
grep -q '^retry=on-retryable-failure$' <<<"$route_out"

echo 'core command tests: PASS'
