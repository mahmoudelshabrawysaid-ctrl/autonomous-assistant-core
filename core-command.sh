#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$ROOT_DIR/config.json"
TASKS="$ROOT_DIR/tasks.json"
SHORTCUTS="$ROOT_DIR/shortcuts.json"

usage() {
  cat <<'EOF'
CORE — command gateway

Usage:
  ./core-command.sh <request>
  ./core-command.sh status
  ./core-command.sh shortcuts
  ./core-command.sh help

The gateway classifies natural-language requests into project areas. It never
bypasses the security guard and never authorizes external targets.
EOF
}

shortcuts() {
  python3 - "$SHORTCUTS" <<'PY'
import json,sys
with open(sys.argv[1], encoding='utf-8') as f: d=json.load(f)
for command, description in d.get('commands', {}).items():
    print(f'{command} — {description}')
PY
}

status() {
  printf 'project=autonomous-assistant-core\n'
  if [[ -f "$CONFIG" ]]; then
    python3 - "$CONFIG" <<'PY'
import json,sys
with open(sys.argv[1], encoding='utf-8') as f: d=json.load(f)
print('version=' + str(d.get('version','unknown')))
print('engine_status=' + str(d.get('engine_status','unknown')))
print('command_center=' + str(d.get('command_center',{}).get('enabled',False)).lower())
PY
  fi
  [[ -f "$TASKS" ]] && echo "tasks=$(python3 - "$TASKS" <<'PY'
import json,sys
with open(sys.argv[1], encoding='utf-8') as f: d=json.load(f)
print(len(d.get('tasks',[])))
PY
)"
}

classify() {
  local text="${1,,}"
  if [[ "$text" =~ (ctf|lab|scan|recon|vuln|target|allowlist|nmap|sqli|xss|security|cyber|اختبار|اختراق|لاب|سكان|فحص|ثغرة|هدف|سيبر) ]]; then echo security; return; fi
  if [[ "$text" =~ (github|repo|commit|branch|pull request|workflow|code|bug|fix|build|test|برمج|كود|مشروع|جيت) ]]; then echo code; return; fi
  if [[ "$text" =~ (report|summary|document|docs|تقرير|ملخص|توثيق) ]]; then echo report; return; fi
  if [[ "$text" =~ (english|pronunciation|travel|انجليزي|إنجليزي|نطق|سفر) ]]; then echo english; return; fi
  if [[ "$text" =~ (football|soccer|match|player|league|كرة|مباراة|لاعب|دوري) ]]; then echo football; return; fi
  if [[ "$text" =~ (notion|airtable|coda|monday|canva|plugin|بلاجن|نوشن) ]]; then echo integrations; return; fi
  echo general
}

if [[ $# -eq 0 ]]; then usage; exit 0; fi
case "${1,,}" in
  help|-h|--help) usage ;;
  status|doctor) status ;;
  shortcuts|shortcut|اختصارات) shortcuts ;;
  classify) shift; [[ $# -gt 0 ]] || { echo general; exit 0; }; classify "$*" ;;
  *)
    area="$(classify "$*")"
    printf 'area=%s\nrequest=%s\n' "$area" "$*"
    ;;
esac
