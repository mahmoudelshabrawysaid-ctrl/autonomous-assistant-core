#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 -m py_compile "$ROOT/openai_client.py"
python3 -m json.tool "$ROOT/config.json" >/dev/null
python3 -m json.tool "$ROOT/tasks.json" >/dev/null
bash -n "$ROOT/core-command.sh"
for f in main.sh sync.sh setup-sec-lab.sh lab-manager.sh termux-ethical-lab-install.sh; do
  [[ -f "$ROOT/$f" ]] && bash -n "$ROOT/$f"
done
! grep -RInE '(sk-[A-Za-z0-9_-]{20,}|BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY)' "$ROOT" --exclude-dir=.git --exclude='*.md'
echo 'project tests: PASS'
