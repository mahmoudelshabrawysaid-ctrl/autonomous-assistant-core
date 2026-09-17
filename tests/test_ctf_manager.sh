#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP"
mkdir -p "$HOME/sec_lab/cases" "$HOME/sec_lab/ctf"
printf 'id\tcategory\ttitle\tseverity\tscope\n001\tweb\tDemo\tmedium\tlocal-only\n' > "$HOME/sec_lab/cases/catalog.tsv"
printf 'id\tname\tcategory\tscope\tobjective\nCTF001\tDemo\tweb\tlocal-only\ttraining\n' > "$HOME/sec_lab/ctf/targets.tsv"
bash -n "$ROOT/tools/ctf-manager.sh"
"$ROOT/tools/ctf-manager.sh" validate >/dev/null
"$ROOT/tools/ctf-manager.sh" show 001 >/dev/null
"$ROOT/tools/ctf-manager.sh" stats | grep -q '^cases=1$'
echo 'ctf manager tests: PASS'
