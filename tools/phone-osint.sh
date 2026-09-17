#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${SEC_LAB_DIR:-${HOME}/sec_lab}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_ENGINE="${REPORT_ENGINE:-$ROOT_DIR/tools/report-engine.sh}"
FIXTURE_DIR="$LAB_DIR/ctf/phone-osint"
CACHE_DIR="$LAB_DIR/phone-intel/cache"
CONFIG_FILE="${PHONE_INTEL_CONFIG:-$LAB_DIR/phone-intel/providers.conf}"

usage() {
  cat <<'EOF'
Public Phone Intelligence — authorized/public-data lab workflow

Usage:
  phone-osint.sh inspect <phone>
  phone-osint.sh intel <phone>
  phone-osint.sh audit <phone>
  phone-osint.sh report <phone>
  phone-osint.sh ctf-fixture

Modes:
  inspect   Local numbering/format metadata only.
  intel     Public-data intelligence using explicitly configured providers.
  audit     Defensive privacy-exposure checklist plus local metadata.
  report    Create a Report Engine report from the audit/intel result.

Provider model:
  Providers are opt-in and configured in providers.conf. The default provider
  set is offline. Network providers must be lawful public sources or APIs you
  are authorized to use and must return public/business metadata only.

This module never performs OTP/reset flows, telecom manipulation, credential
checks, private-account enumeration, identity resolution, address discovery,
or attempts to bypass provider access controls.
EOF
}

normalize() {
  local raw="$1" n
  n="${raw//[() .-]/}"
  n="${n//+/+}"
  if [[ "$n" =~ ^0[0-9]{7,14}$ ]]; then n="+20${n#0}"; fi
  [[ "$n" =~ ^\+[0-9]{7,15}$ ]] || { echo 'invalid-format'; return 1; }
  printf '%s\n' "$n"
}

country_info() {
  local n="$1"
  case "$n" in
    +20[0-9]*) printf 'Egypt\t+20\tEG\n' ;;
    +1[0-9]*) printf 'North America (NANP)\t+1\tNANP\n' ;;
    +44[0-9]*) printf 'United Kingdom\t+44\tGB\n' ;;
    +49[0-9]*) printf 'Germany\t+49\tDE\n' ;;
    +33[0-9]*) printf 'France\t+33\tFR\n' ;;
    +971[0-9]*) printf 'United Arab Emirates\t+971\tAE\n' ;;
    +966[0-9]*) printf 'Saudi Arabia\t+966\tSA\n' ;;
    +974[0-9]*) printf 'Qatar\t+974\tQA\n' ;;
    +90[0-9]*) printf 'Türkiye\t+90\tTR\n' ;;
    +91[0-9]*) printf 'India\t+91\tIN\n' ;;
    +81[0-9]*) printf 'Japan\t+81\tJP\n' ;;
    +61[0-9]*) printf 'Australia\t+61\tAU\n' ;;
    +86[0-9]*) printf 'China\t+86\tCN\n' ;;
    *) printf 'Unknown\tunknown\tunknown\n' ;;
  esac
}

inspect() {
  local n country code region
  n="$(normalize "$1")" || { echo 'status=invalid'; return 1; }
  IFS=$'\t' read -r country code region <<<"$(country_info "$n")"
  printf 'status=valid\nnormalized=%s\ncountry=%s\ncountry_code=%s\nregion=%s\nsubscriber_digits=%d\n' \
    "$n" "$country" "$code" "$region" "$(( ${#n} - ${#code} - 1 ))"
}

load_config() {
  mkdir -p "$(dirname "$CONFIG_FILE")"
  if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" <<'EOF'
# Public Phone Intelligence providers
# Disabled by default. One provider per line:
# name|command|scope
# command receives the normalized phone as $1 and must print key=value lines.
# Allowed scope values: metadata, business, public-web
# Never configure commands that enumerate private accounts or bypass access controls.
EOF
  fi
}

run_providers() {
  local phone="$1" line name command scope output
  load_config
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    IFS='|' read -r name command scope <<<"$line"
    [[ -n "${name:-}" && -n "${command:-}" ]] || continue
    case "$scope" in metadata|business|public-web) ;; *) printf 'provider=%s status=blocked reason=invalid-scope\n' "$name"; continue ;; esac
    if output="$(bash -c "$command" -- "$phone" 2>/dev/null)"; then
      printf 'provider=%s status=ok scope=%s\n' "$name" "$scope"
      printf '%s\n' "$output" | sed 's/[^[:print:]	]//g' | head -n 80
    else
      printf 'provider=%s status=error scope=%s\n' "$name" "$scope"
    fi
  done < "$CONFIG_FILE"
}

intel() {
  local n="$1"
  n="$(normalize "$n")" || return 1
  printf 'intel_status=started\n'
  inspect "$n"
  printf '\npublic_provider_results=\n'
  run_providers "$n"
  printf '\ncorrelation_rules=\n'
  printf '%s\n' '- Prefer agreement across independent public sources.' '- Treat names/labels as unverified unless published by the owner or a business entity.' '- Record source and timestamp for every external result.' '- Do not infer identity from weak matches or shared numbers.'
}

audit() {
  local n="$1"
  inspect "$n"
  printf '\npublic-intelligence-scope=\n'
  printf '%s\n' '- country/numbering-plan metadata' '- carrier or line-type data from lawful public APIs' '- owner-published business contact information' '- public web mentions and indexed business documents' '- lawful breach-exposure indicators for the account owner'
  printf '\nprivacy-risk-checks=\n'
  printf '%s\n' '- public disclosure and search-engine exposure' '- stale/reused number exposure' '- business-vs-personal publication mismatch' '- excessive recovery dependence on the phone number'
  printf '\nnot-performed=\n'
  printf '%s\n' '- identity resolution of a private person' '- private address/profile discovery' '- private-account enumeration' '- password-reset or OTP actions' '- SIM manipulation or telecom access' '- exploitation or bypass of public-service controls'
}

report() {
  local n="$1" safe raw report_file
  safe="$(normalize "$n")" || return 1
  raw="$(mktemp)"
  trap 'rm -f "$raw"' RETURN
  { audit "$safe"; printf '\npublic-intelligence-results=\n'; run_providers "$safe"; } > "$raw"
  [[ -x "$REPORT_ENGINE" ]] || { echo "Report Engine not executable: $REPORT_ENGINE" >&2; return 2; }
  report_file="$(bash "$REPORT_ENGINE" from-file phone-intel "$safe" 'Public Phone Intelligence / Privacy Audit' "$raw" completed | tail -n 1)"
  echo "$report_file"
}

ctf_fixture() {
  mkdir -p "$FIXTURE_DIR"
  cat > "$FIXTURE_DIR/README.md" <<'EOF'
# Public Phone Intelligence CTF Fixture

Synthetic target only. Number: `+201001234567`.

Objectives:
1. Normalize and classify the numbering metadata.
2. Correlate two synthetic public/business sources.
3. Identify a stale public listing and document its privacy risk.
4. Produce a Report Engine report with source/evidence timestamps.

No real person, credential, telecom operation, or private account is involved.
EOF
  cat > "$FIXTURE_DIR/target.json" <<'EOF'
{
  "phone": "+201001234567",
  "owner": "CTF Synthetic User",
  "public_sources": [
    {"source":"synthetic-business-directory","type":"business","label":"Example Repair Lab","status":"published"},
    {"source":"synthetic-archive","type":"public-web","label":"Old listing","status":"stale"}
  ],
  "finding":"stale-public-listing",
  "risk":"medium",
  "remediation":"remove or update the obsolete public listing"
}
EOF
  echo "$FIXTURE_DIR"
}

case "${1:-help}" in
  inspect) shift; [[ $# -eq 1 ]] || { echo 'one phone number required' >&2; exit 2; }; inspect "$1" ;;
  intel) shift; [[ $# -eq 1 ]] || { echo 'one phone number required' >&2; exit 2; }; intel "$1" ;;
  audit) shift; [[ $# -eq 1 ]] || { echo 'one phone number required' >&2; exit 2; }; audit "$1" ;;
  report) shift; [[ $# -eq 1 ]] || { echo 'one phone number required' >&2; exit 2; }; report "$1" ;;
  ctf-fixture) ctf_fixture ;;
  help|-h|--help) usage ;;
  *) echo "unknown command: $1" >&2; usage >&2; exit 2 ;;
esac
