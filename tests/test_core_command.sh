#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE="$ROOT_DIR/core-command.sh"

bash -n "$CORE"

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

echo 'core command tests: PASS'
