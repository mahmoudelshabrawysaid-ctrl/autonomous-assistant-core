#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 -m py_compile "$ROOT/openai_client.py" "$ROOT/assistant/safety_guard.py"
python3 -m json.tool "$ROOT/config.json" >/dev/null
python3 -m json.tool "$ROOT/tasks.json" >/dev/null
python3 -m json.tool "$ROOT/shortcuts.json" >/dev/null
bash -n "$ROOT/core-command.sh"
for f in main.sh sync.sh setup-sec-lab.sh lab-manager.sh termux-ethical-lab-install.sh tests/test_core_command.sh; do
  [[ -f "$ROOT/$f" ]] && bash -n "$ROOT/$f"
done
bash "$ROOT/tests/test_core_command.sh"
python3 -m unittest discover -s "$ROOT/tests" -p 'test_*.py' -q
! grep -RInE '(sk-[A-Za-z0-9_-]{20,}|BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY)' "$ROOT" --exclude-dir=.git --exclude='*.md'
echo 'project tests: PASS'
