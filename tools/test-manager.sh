#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  cat <<'EOF'
Test Manager — local project validation

Usage:
  ./tools/test-manager.sh all
  ./tools/test-manager.sh syntax
  ./tools/test-manager.sh unit
  ./tools/test-manager.sh security
  ./tools/test-manager.sh ctf
  ./tools/test-manager.sh help
EOF
}

run_syntax() {
  python3 -m py_compile "$ROOT_DIR/openai_client.py" "$ROOT_DIR/assistant/safety_guard.py"
  for f in main.sh sync.sh setup-sec-lab.sh lab-manager.sh termux-ethical-lab-install.sh core-command.sh tools/test-manager.sh tools/ctf-manager.sh tests/test_core_command.sh tests/test_test_manager.sh tests/test_ctf_manager.sh; do
    [[ -f "$ROOT_DIR/$f" ]] && bash -n "$ROOT_DIR/$f"
  done
  python3 -m json.tool "$ROOT_DIR/config.json" >/dev/null
  python3 -m json.tool "$ROOT_DIR/tasks.json" >/dev/null
  python3 -m json.tool "$ROOT_DIR/shortcuts.json" >/dev/null
}

run_unit() {
  [[ -f "$ROOT_DIR/tests/test_core_command.sh" ]] && bash "$ROOT_DIR/tests/test_core_command.sh"
  [[ -f "$ROOT_DIR/tests/test_test_manager.sh" ]] && bash "$ROOT_DIR/tests/test_test_manager.sh"
  [[ -f "$ROOT_DIR/tests/test_ctf_manager.sh" ]] && bash "$ROOT_DIR/tests/test_ctf_manager.sh"
  python3 -m unittest discover -s "$ROOT_DIR/tests" -p 'test_*.py' -q
}

run_security() {
  if grep -RInE '(sk-[A-Za-z0-9_-]{20,}|BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY)' "$ROOT_DIR" --exclude-dir=.git --exclude='*.md'; then
    echo 'potential secret detected' >&2
    return 1
  fi
  echo 'secret scan: PASS'
}

run_ctf() {
  SEC_LAB_DIR="${SEC_LAB_DIR:-${HOME}/sec_lab}" "$ROOT_DIR/tools/ctf-manager.sh" validate
}

case "${1:-all}" in
  all) run_syntax; run_unit; run_security; run_ctf; echo 'test-manager: PASS' ;;
  syntax) run_syntax; echo 'syntax/config: PASS' ;;
  unit) run_unit; echo 'unit: PASS' ;;
  security) run_security ;;
  ctf) run_ctf ;;
  help|-h|--help) usage ;;
  *) echo "unknown command: $1" >&2; usage >&2; exit 2 ;;
esac
