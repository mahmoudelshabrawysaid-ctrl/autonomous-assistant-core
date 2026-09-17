#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$ROOT_DIR/config.json"
TASKS="$ROOT_DIR/tasks.json"
SHORTCUTS="$ROOT_DIR/shortcuts.json"

usage() {
  cat <<'EOF'
CORE — unified task router

Usage:
  ./core-command.sh <request>
  ./core-command.sh status
  ./core-command.sh shortcuts
  ./core-command.sh route <request>
  ./core-command.sh help

CORE routes natural-language requests to a project area and emits a safe,
deterministic execution plan. It never grants authorization or bypasses guards.
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
  if [[ "$text" =~ (ctf|lab|scan|recon|vuln|target|allowlist|nmap|sqli|xss|security|cyber|phone|telephone|otp|sim-swap|هاتف|تليفون|موبايل|رقم|اختبار|اختراق|لاب|سكان|فحص|ثغرة|هدف|سيبر) ]]; then echo security; return; fi
  if [[ "$text" =~ (github|repo|commit|branch|pull request|workflow|code|bug|fix|build|test|برمج|كود|مشروع|جيت) ]]; then echo code; return; fi
  if [[ "$text" =~ (report|summary|document|docs|تقرير|ملخص|توثيق) ]]; then echo report; return; fi
  if [[ "$text" =~ (english|pronunciation|travel|انجليزي|إنجليزي|نطق|سفر) ]]; then echo english; return; fi
  if [[ "$text" =~ (football|soccer|match|player|league|كرة|مباراة|لاعب|دوري) ]]; then echo football; return; fi
  if [[ "$text" =~ (notion|airtable|coda|monday|canva|plugin|بلاجن|نوشن) ]]; then echo integrations; return; fi
  echo general
}

route() {
  local request="$1"
  local area
  area="$(classify "$request")"
  python3 - "$SHORTCUTS" "$area" "$request" <<'PY'
import json,sys
shortcuts_path, area, request = sys.argv[1:]
with open(shortcuts_path, encoding='utf-8') as f:
    data=json.load(f)
reverse={
 'security':'/sec','code':'/code','report':'/report','english':'/english',
 'football':'/football','integrations':'/plugins','general':'/core'
}
print(f'area={area}')
print(f'gateway={reverse.get(area,"/core")}')
print('request=' + request)
print('execution=authorized-tools-only')
print('validation=required')
print('retry=on-retryable-failure')
PY
}

if [[ $# -eq 0 ]]; then usage; exit 0; fi
case "${1,,}" in
  help|-h|--help) usage ;;
  status|doctor) status ;;
  shortcuts|shortcut|اختصارات) shortcuts ;;
  route|مسار)
    shift
    [[ $# -gt 0 ]] || { echo 'request is required' >&2; exit 2; }
    route "$*"
    ;;
  classify)
    shift; [[ $# -gt 0 ]] || { echo general; exit 0; }; classify "$*" ;;
  *) route "$*" ;;
esac
