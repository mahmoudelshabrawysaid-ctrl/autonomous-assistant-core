#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB_DIR="${SEC_LAB_DIR:-${HOME}/sec_lab}"
CATALOG="$LAB_DIR/cases/catalog.tsv"
TARGETS="$LAB_DIR/ctf/targets.tsv"

usage() {
  cat <<'EOF'
CTF Manager — local, authorized training catalog

Usage:
  ./tools/ctf-manager.sh init
  ./tools/ctf-manager.sh list [category]
  ./tools/ctf-manager.sh show <id>
  ./tools/ctf-manager.sh validate
  ./tools/ctf-manager.sh stats
EOF
}

init() {
  mkdir -p "$LAB_DIR/cases" "$LAB_DIR/ctf"
  [[ -f "$CATALOG" ]] || printf 'id\tcategory\ttitle\tseverity\tscope\n' > "$CATALOG"
  [[ -f "$TARGETS" ]] || printf 'id\tname\tcategory\tscope\tobjective\n' > "$TARGETS"
  echo "CTF catalog initialized: $LAB_DIR"
}

list_cases() {
  [[ -f "$CATALOG" ]] || { echo 'Catalog missing; run init.' >&2; return 2; }
  local category="${1:-}"
  awk -F '\t' -v c="$category" 'NR==1 || c=="" || $2==c {printf "%s\t%s\t%s\t%s\t%s\n",$1,$2,$3,$4,$5}' "$CATALOG"
}

show_case() {
  local id="${1:-}"
  [[ -n "$id" ]] || { echo 'Case ID required.' >&2; return 2; }
  awk -F '\t' -v id="$id" 'NR==1 || $1==id {print; found=1} END {if(!found) exit 1}' "$CATALOG" || { echo "Case not found: $id" >&2; return 1; }
}

validate() {
  [[ -f "$CATALOG" ]] || { echo 'FAIL: catalog missing'; return 1; }
  [[ -f "$TARGETS" ]] || { echo 'FAIL: targets missing'; return 1; }
  awk -F '\t' 'NR>1 {if(NF!=5 || $5=="" || $5!="local-only") bad=1} END {exit bad}' "$CATALOG" || { echo 'FAIL: invalid catalog scope/columns'; return 1; }
  awk -F '\t' 'NR>1 {if(NF!=5 || $4!="local-only") bad=1} END {exit bad}' "$TARGETS" || { echo 'FAIL: invalid target scope/columns'; return 1; }
  echo 'ctf catalog: PASS'
}

stats() {
  [[ -f "$CATALOG" ]] || { echo 'Catalog missing.' >&2; return 2; }
  awk -F '\t' 'NR>1 {count++; cat[$2]++} END {printf "cases=%d\n",count; for (c in cat) printf "category.%s=%d\n",c,cat[c]}' "$CATALOG" | sort
}

case "${1:-help}" in
  init) init ;;
  list) shift; list_cases "${1:-}" ;;
  show) shift; show_case "${1:-}" ;;
  validate) validate ;;
  stats) stats ;;
  help|-h|--help) usage ;;
  *) echo "unknown command: $1" >&2; usage >&2; exit 2 ;;
esac
