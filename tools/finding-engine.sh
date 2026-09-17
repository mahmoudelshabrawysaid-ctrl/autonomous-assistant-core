#!/usr/bin/env bash
set -euo pipefail

# Deterministic Evidence -> Correlation -> Finding -> Risk -> Remediation engine.
# It consumes scanner/test output; it never performs network activity.

usage() {
  cat <<'EOF'
Finding Engine — authorized/local lab only

Usage:
  finding-engine.sh from-file <source> <target> <input-file>
  finding-engine.sh self-test

Input: key=value evidence lines. Recognized keys include:
  finding, evidence, source, status, severity, remediation

Output: stable key=value records suitable for Report Engine.
EOF
}

from_file() {
  local source="$1" target="$2" file="$3"
  [[ -f "$file" ]] || { echo 'status=error reason=input-not-found' >&2; return 2; }
  local finding='' evidence='' sources='' status=''
  local severity='info' remediation='Review evidence and reproduce locally.'
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      finding=*) finding="${line#finding=}" ;;
      evidence=*) evidence="${line#evidence=}" ;;
      source=*) sources="${sources}${sources:+,}${line#source=}" ;;
      status=*) status="${line#status=}" ;;
      severity=*) severity="${line#severity=}" ;;
      remediation=*) remediation="${line#remediation=}" ;;
    esac
  done < "$file"

  local confidence='none' verdict='insufficient-evidence'
  if [[ -n "$finding" && -n "$evidence" ]]; then
    confidence='single-source'
    verdict='unconfirmed'
    [[ "$sources" == *,* ]] && { confidence='multi-source'; verdict='corroboration-available'; }
    [[ "$status" == 'confirmed' ]] && { confidence='confirmed'; verdict='confirmed'; }
  fi

  printf 'engine=finding-engine\nsource=%s\ntarget=%s\nfinding=%s\nconfidence=%s\nverdict=%s\nseverity=%s\nevidence=%s\nsources=%s\nremediation=%s\n' \
    "$source" "$target" "$finding" "$confidence" "$verdict" "$severity" "$evidence" "$sources" "$remediation"
}

self_test() {
  local f out
  f="$(mktemp)"
  trap 'rm -f "$f"' EXIT
  cat > "$f" <<'EOF'
finding=test-finding
evidence=synthetic-proof
source=fixture-a
source=fixture-b
status=confirmed
severity=low
remediation=fix-test-control
EOF
  out="$(from_file ctf synthetic-target "$f")"
  grep -q '^confidence=confirmed$' <<<"$out"
  grep -q '^verdict=confirmed$' <<<"$out"
  grep -q '^severity=low$' <<<"$out"
  echo 'finding-engine self-test: PASS'
}

case "${1:-help}" in
  from-file) [[ $# -eq 4 ]] || { usage >&2; exit 2; }; from_file "$2" "$3" "$4" ;;
  self-test) self_test ;;
  help|-h|--help) usage ;;
  *) usage >&2; exit 2 ;;
esac
