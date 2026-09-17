#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
step() { printf '\n==> %s\n' "$1"; shift; "$@"; }
step 'Python syntax' python3 -m py_compile "$ROOT/openai_client.py" "$ROOT/assistant/safety_guard.py"
step 'JSON validation' bash -c 'python3 -m json.tool "$1" >/dev/null && python3 -m json.tool "$2" >/dev/null && python3 -m json.tool "$3" >/dev/null && [[ ! -e "$4" || -f "$4" ]]' _ "$ROOT/config.json" "$ROOT/tasks.json" "$ROOT/shortcuts.json" "$ROOT/router.json"
step 'Bash syntax' bash -c '
  root="$1"
  for f in main.sh sync.sh setup-sec-lab.sh lab-manager.sh termux-ethical-lab-install.sh core-command.sh tools/test-manager.sh tools/ctf-manager.sh tools/report-engine.sh tools/phone-osint.sh tools/finding-engine.sh tests/test_core_command.sh tests/test_test_manager.sh tests/test_ctf_manager.sh tests/test_report_engine.sh tests/test_phone_osint.sh tests/test_lab_manager.sh tests/test_finding_engine.sh; do
    if [[ -f "$root/$f" ]]; then bash -n "$root/$f"; fi
  done
' _ "$ROOT"
step 'Core tests' bash "$ROOT/tests/test_core_command.sh"
step 'Test Manager tests' bash "$ROOT/tests/test_test_manager.sh"
step 'CTF Manager tests' bash "$ROOT/tests/test_ctf_manager.sh"
step 'Report Engine tests' bash "$ROOT/tests/test_report_engine.sh"
step 'Phone OSINT tests' bash "$ROOT/tests/test_phone_osint.sh"
step 'Finding Engine tests' bash "$ROOT/tests/test_finding_engine.sh"
step 'Lab Manager tests' bash "$ROOT/tests/test_lab_manager.sh"
step 'Python unit tests' python3 -m unittest discover -s "$ROOT/tests" -p 'test_*.py' -q
step 'Secret scan' bash -c '! grep -RInE '\''(sk-[A-Za-z0-9_-]{20,}|BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY)'\'' "$1" --exclude-dir=.git --exclude='*.md'' _ "$ROOT"
printf '\nproject tests: PASS\n'
