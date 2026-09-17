#!/usr/bin/env bash
set -euo pipefail

# Authorized/local validation harness. Consumes evidence produced by scanners/tests.
# No network operations, exploitation, credential use, or target discovery.

usage(){ cat <<'EOF'
Vulnerability Validation Engine
Usage: vuln-validation.sh validate <evidence-file>
       vuln-validation.sh self-test
EOF
}

validate(){
  local file="$1" line finding proof repeatable status severity remediation
  [[ -f "$file" ]] || { echo 'status=error reason=input-not-found' >&2; return 2; }
  finding=''; proof=''; repeatable='no'; status='unverified'; severity='info'; remediation='Review and reproduce in the authorized lab target.'
  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      finding=*) finding="${line#finding=}";;
      proof=*) proof="${line#proof=}";;
      repeatable=*) repeatable="${line#repeatable=}";;
      status=*) status="${line#status=}";;
      severity=*) severity="${line#severity=}";;
      remediation=*) remediation="${line#remediation=}";;
    esac
  done < "$file"
  local verdict='NOT_CONFIRMED'
  if [[ -n "$finding" && -n "$proof" && "$repeatable" == 'yes' && "$status" == 'confirmed' ]]; then verdict='CONFIRMED'; fi
  printf 'engine=vulnerability-validation\nverdict=%s\nfinding=%s\nseverity=%s\nrepeatable=%s\nproof=%s\nremediation=%s\n' "$verdict" "$finding" "$severity" "$repeatable" "$proof" "$remediation"
}

self_test(){
  local tmp_file out
  tmp_file="$(mktemp)"
  printf '%s\n' 'finding=synthetic-vulnerability' 'proof=deterministic-test-evidence' 'repeatable=yes' 'status=confirmed' 'severity=medium' 'remediation=patch-fixture' > "$tmp_file"
  out="$(validate "$tmp_file")"
  rm -f -- "$tmp_file"
  grep -q '^verdict=CONFIRMED$' <<<"$out"
  grep -q '^severity=medium$' <<<"$out"
  echo 'vulnerability-validation self-test: PASS'
}

case "${1:-help}" in
 validate) [[ $# -eq 2 ]] || { usage >&2; exit 2; }; validate "$2";;
 self-test) self_test;;
 help|-h|--help) usage;;
 *) usage >&2; exit 2;;
esac
