#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C.UTF-8

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CORE="$ROOT_DIR/core-command.sh"
SHORTCUTS="$ROOT_DIR/shortcuts.json"
ROUTER="$ROOT_DIR/router.json"

assert_eq() {
  local name="$1" expected="$2" actual="$3"
  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL: %s\nexpected=%q\nactual=%q\n' "$name" "$expected" "$actual" >&2
    return 1
  fi
  printf 'PASS: %s\n' "$name"
}

bash -n "$CORE"
python3 -m json.tool "$SHORTCUTS" >/dev/null
python3 -m json.tool "$ROUTER" >/dev/null

security_out="$(bash "$CORE" classify 'اعمل فحص للاب CTF')"
assert_eq 'Arabic security classification' security "$security_out"
code_out="$(bash "$CORE" classify 'fix github workflow bug')"
assert_eq 'code classification' code "$code_out"
english_out="$(bash "$CORE" classify 'ساعدني في النطق بالانجليزي')"
assert_eq 'Arabic English classification' english "$english_out"
football_out="$(bash "$CORE" classify 'اعرف نتيجة المباراة')"
assert_eq 'Arabic football classification' football "$football_out"
integration_out="$(bash "$CORE" classify 'ظبط notion plugin')"
assert_eq 'integration classification' integrations "$integration_out"
general_out="$(bash "$CORE" classify 'اعمل خطة عامة')"
assert_eq 'general classification' general "$general_out"

route_out="$(bash "$CORE" route 'اعمل فحص للاب CTF')"
grep -q '^area=security$' <<<"$route_out"
grep -q '^gateway=/sec$' <<<"$route_out"
grep -q '^execution=authorized-tools-only$' <<<"$route_out"
grep -q '^validation=required$' <<<"$route_out"
grep -q '^retry=on-retryable-failure$' <<<"$route_out"
printf 'PASS: security route contract\n'

echo 'core command tests: PASS'
