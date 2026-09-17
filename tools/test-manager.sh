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
  ./tools/test-manager.sh reports
  ./tools/test-manager.sh vuln
  ./tools/test-manager.sh phone
  ./tools/test-manager.sh lab
  ./tools/test-manager.sh help
EOF
}

run_syntax() {
  echo '[test-manager] syntax/config'
  python3 -m py_compile "$ROOT_DIR/openai_client.py" "$ROOT_DIR/assistant/safety_guard.py"
  for f in main.sh sync.sh setup-sec-lab.sh lab-manager.sh termux-ethical-lab-install.sh core-command.sh tools/test-manager.sh tools/ctf-manager.sh tools/report-engine.sh tools/phone-osint.sh tools/finding-engine.sh tools/vuln-validation.sh tests/test_core_command.sh tests/test_test_manager.sh tests/test_ctf_manager.sh tests/test_report_engine.sh tests/test_phone_osint.sh tests/test_lab_manager.sh tests/test_finding_engine.sh tests/test_vuln_validation.sh; do
    [[ -f "$ROOT_DIR/$f" ]] && bash -n "$ROOT_DIR/$f"
  done
  python3 -m json.tool "$ROOT_DIR/config.json" >/dev/null
  python3 -m json.tool "$ROOT_DIR/tasks.json" >/dev/null
  python3 -m json.tool "$ROOT_DIR/shortcuts.json" >/dev/null
}

run_unit() {
  echo '[test-manager] unit: core'
  [[ -f "$ROOT_DIR/tests/test_core_command.sh" ]] && bash "$ROOT_DIR/tests/test_core_command.sh"
  echo '[test-manager] unit: test-manager'
  [[ -f "$ROOT_DIR/tests/test_test_manager.sh" ]] && bash "$ROOT_DIR/tests/test_test_manager.sh"
  echo '[test-manager] unit: ctf'
  [[ -f "$ROOT_DIR/tests/test_ctf_manager.sh" ]] && bash "$ROOT_DIR/tests/test_ctf_manager.sh"
  echo '[test-manager] unit: reports'
  [[ -f "$ROOT_DIR/tests/test_report_engine.sh" ]] && bash "$ROOT_DIR/tests/test_report_engine.sh"
  echo '[test-manager] unit: phone-osint'
  [[ -f "$ROOT_DIR/tests/test_phone_osint.sh" ]] && bash "$ROOT_DIR/tests/test_phone_osint.sh"
  echo '[test-manager] unit: finding-engine'
  [[ -f "$ROOT_DIR/tests/test_finding_engine.sh" ]] && bash "$ROOT_DIR/tests/test_finding_engine.sh"
  echo '[test-manager] unit: vulnerability-validation'
  [[ -f "$ROOT_DIR/tests/test_vuln_validation.sh" ]] && bash "$ROOT_DIR/tests/test_vuln_validation.sh"
  echo '[test-manager] unit: lab-manager'
  [[ -f "$ROOT_DIR/tests/test_lab_manager.sh" ]] && bash "$ROOT_DIR/tests/test_lab_manager.sh"
  echo '[test-manager] unit: python'
  python3 -m unittest discover -s "$ROOT_DIR/tests" -p 'test_*.py' -q
}

run_security() {
  echo '[test-manager] security scan'
  if grep -RInE '(sk-[A-Za-z0-9_-]{20,}|BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY)' "$ROOT_DIR" --exclude-dir=.git --exclude='*.md'; then
    echo 'potential secret detected' >&2
    return 1
  fi
  echo 'secret scan: PASS'
}

run_ctf() {
  echo '[test-manager] ctf validation'
  SEC_LAB_DIR="${SEC_LAB_DIR:-${HOME}/sec_lab}" "$ROOT_DIR/tools/ctf-manager.sh" validate
}

run_reports() {
  echo '[test-manager] report validation'
  SEC_LAB_DIR="${SEC_LAB_DIR:-${HOME}/sec_lab}" "$ROOT_DIR/tools/report-engine.sh" validate
}

run_vuln() {
  echo '[test-manager] vulnerability validation'
  bash "$ROOT_DIR/tools/vuln-validation.sh" self-test
}

run_phone() {
  echo '[test-manager] phone OSINT validation'
  bash "$ROOT_DIR/tests/test_phone_osint.sh"
}

run_lab() {
  echo '[test-manager] Lab Manager validation'
  bash "$ROOT_DIR/tests/test_lab_manager.sh"
}

case "${1:-all}" in
  all) run_syntax; run_unit; run_security; run_ctf; run_reports; run_vuln; echo 'test-manager: PASS' ;;
  syntax) run_syntax; echo 'syntax/config: PASS' ;;
  unit) run_unit; echo 'unit: PASS' ;;
  security) run_security ;;
  ctf) run_ctf ;;
  reports) run_reports ;;
  vuln) run_vuln ;;
  phone) run_phone ;;
  lab) run_lab ;;
  help|-h|--help) usage ;;
  *) echo "unknown command: $1" >&2; usage >&2; exit 2 ;;
esac
