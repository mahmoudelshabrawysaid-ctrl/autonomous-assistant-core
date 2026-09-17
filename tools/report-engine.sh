#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${SEC_LAB_DIR:-${HOME}/sec_lab}"
REPORT_DIR="$LAB_DIR/reports"

usage() {
  cat <<'EOF'
Report Engine — unified local lab reporting

Usage:
  ./tools/report-engine.sh init
  ./tools/report-engine.sh new <type> <target> <title> [status]
  ./tools/report-engine.sh from-file <type> <target> <title> <input-file> [status]
  ./tools/report-engine.sh list
  ./tools/report-engine.sh validate
  ./tools/report-engine.sh stats
EOF
}

safe_name() {
  printf '%s' "$1" | tr -cs 'A-Za-z0-9._-' '_' | sed 's/^_*//; s/_*$//'
}

init() {
  mkdir -p "$REPORT_DIR"
  echo "Report directory: $REPORT_DIR"
}

new_report() {
  local type="${1:-}" target="${2:-}" title="${3:-}" status="${4:-completed}"
  [[ -n "$type" && -n "$target" && -n "$title" ]] || { echo 'type, target and title are required.' >&2; return 2; }
  init >/dev/null
  local stamp id file
  stamp="$(date -u +%Y%m%dT%H%M%SZ)"
  id="${stamp}_$(safe_name "$type")_$(safe_name "$target")"
  file="$REPORT_DIR/${id}.md"
  cat > "$file" <<EOF
# Security Lab Report

- **Report ID:** $id
- **Type:** $type
- **Target:** $target
- **Scope:** local-only
- **Status:** $status
- **Created (UTC):** $stamp

## Summary

$title

## Findings

No findings were supplied. Add evidence and findings below.

## Evidence

- Evidence path: not supplied

## Remediation / Next Steps

- Review the result within the authorized local lab scope.

EOF
  echo "$file"
}

from_file() {
  local type="${1:-}" target="${2:-}" title="${3:-}" input="${4:-}" status="${5:-completed}"
  [[ -n "$input" && -f "$input" ]] || { echo "Input file not found: $input" >&2; return 2; }
  local file
  file="$(new_report "$type" "$target" "$title" "$status")"
  {
    printf '\n## Raw Result\n\n'
    printf '```text\n'
    cat "$input"
    printf '\n```\n'
    printf '\n## Evidence\n\n- Source file: `%s`\n' "$input"
  } >> "$file"
  echo "$file"
}

list_reports() {
  init >/dev/null
  find "$REPORT_DIR" -maxdepth 1 -type f -name '*.md' -printf '%f\n' | sort
}

validate() {
  init >/dev/null
  local bad=0 f
  while IFS= read -r f; do
    grep -q '^# Security Lab Report$' "$f" || { echo "FAIL: missing header: $f"; bad=1; }
    grep -q '\*\*Scope:\*\* local-only' "$f" || { echo "FAIL: non-local scope: $f"; bad=1; }
  done < <(find "$REPORT_DIR" -maxdepth 1 -type f -name '*.md')
  (( bad == 0 )) && echo 'report-engine: PASS' || return 1
}

stats() {
  init >/dev/null
  local count
  count="$(find "$REPORT_DIR" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')"
  echo "reports=$count"
}

case "${1:-help}" in
  init) init ;;
  new) shift; new_report "$@" ;;
  from-file) shift; from_file "$@" ;;
  list) list_reports ;;
  validate) validate ;;
  stats) stats ;;
  help|-h|--help) usage ;;
  *) echo "unknown command: $1" >&2; usage >&2; exit 2 ;;
esac
