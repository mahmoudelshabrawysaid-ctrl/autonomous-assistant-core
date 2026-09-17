#!/usr/bin/env bash
set -euo pipefail

LAB_DIR="${SEC_LAB_DIR:-${HOME}/sec_lab}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_ENGINE="${REPORT_ENGINE:-$ROOT_DIR/tools/report-engine.sh}"
FIXTURE_DIR="$LAB_DIR/ctf/phone-osint"

usage() {
  cat <<'EOF'
Phone OSINT / Privacy Audit — offline, authorized lab workflow

Usage:
  ./tools/phone-osint.sh inspect <phone>
  ./tools/phone-osint.sh audit <phone>
  ./tools/phone-osint.sh report <phone>
  ./tools/phone-osint.sh ctf-fixture

The tool does not identify real people, enumerate private accounts, send OTPs,
or contact telecom/social services. It only normalizes phone metadata and
produces a defensive checklist for numbers you own or are authorized to test.
EOF
}

normalize() {
  local raw="$1" n
  n="${raw//[() .-]/}"
  n="${n//+/+}"
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

audit() {
  local n="$1"
  inspect "$n"
  cat <<'EOF'

public-data-that-may-exist=
- country/numbering-plan metadata
- carrier or line-type information from legitimate public services
- user-published business contact information
- breach exposure indicators when lawfully available to the account owner

privacy-risk-checks=
- SIM-swap / unauthorized porting risk
- SMS OTP dependency and fallback channels
- account-recovery exposure
- phone-number reuse and stale account associations
- public disclosure in websites, PDFs, profiles, or business listings
- data-broker / breach exposure (check only with lawful access)

lab-only-account-checks=
- test accounts explicitly mapped to this number in the local fixture
- recovery-flow behavior in the local CTF target
- OTP handling and rate limiting in the local CTF target
- authorization boundaries around phone-number lookup

not-performed=
- identity resolution
- private address/profile discovery
- password-reset requests against real services
- OTP interception or SIM manipulation
- exploitation of real systems
EOF
}

report() {
  local n="$1" safe raw report_file
  safe="$(normalize "$n")" || return 1
  raw="$(mktemp)"
  trap 'rm -f "$raw"' RETURN
  audit "$safe" > "$raw"
  [[ -x "$REPORT_ENGINE" ]] || { echo "Report Engine not executable: $REPORT_ENGINE" >&2; return 2; }
  report_file="$(bash "$REPORT_ENGINE" from-file phone-osint "$safe" 'Phone OSINT / Privacy Audit' "$raw" completed | tail -n 1)"
  echo "$report_file"
}

ctf_fixture() {
  mkdir -p "$FIXTURE_DIR"
  cat > "$FIXTURE_DIR/README.md" <<'EOF'
# Phone OSINT CTF Fixture

Synthetic target only. Number: `+201001234567`.

Objectives:
1. Normalize the number and identify its country code.
2. Inspect the local fixture for a synthetic account association.
3. Document the simulated recovery/OTP weaknesses.
4. Produce a Report Engine report with evidence, risk, and remediation.

No real service, person, credential, or telecom operation is involved.
EOF
  cat > "$FIXTURE_DIR/target.json" <<'EOF'
{
  "phone": "+201001234567",
  "owner": "CTF Synthetic User",
  "accounts": ["training-mail@example.invalid", "lab-chat-user"],
  "sim_swap": "simulated-risk",
  "otp": {"channel": "sms", "rate_limit": "missing", "attempt_window": "unbounded-simulation"},
  "recovery": {"phone_only": true, "secondary_factor": false},
  "leak": {"source": "synthetic-fixture", "data": ["display_name", "test_email"]}
}
EOF
  echo "$FIXTURE_DIR"
}

case "${1:-help}" in
  inspect) shift; [[ $# -eq 1 ]] || { echo 'one phone number required' >&2; exit 2; }; inspect "$1" ;;
  audit) shift; [[ $# -eq 1 ]] || { echo 'one phone number required' >&2; exit 2; }; audit "$1" ;;
  report) shift; [[ $# -eq 1 ]] || { echo 'one phone number required' >&2; exit 2; }; report "$1" ;;
  ctf-fixture) ctf_fixture ;;
  help|-h|--help) usage ;;
  *) echo "unknown command: $1" >&2; usage >&2; exit 2 ;;
esac
