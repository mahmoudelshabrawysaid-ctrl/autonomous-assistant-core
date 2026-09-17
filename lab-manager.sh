#!/usr/bin/env bash
set -euo pipefail

SEC_DIR="${SEC_LAB_DIR:-${HOME}/sec_lab}"
BIN_DIR="${HOME}/bin"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$SEC_DIR" "$SEC_DIR/targets" "$SEC_DIR/reports" "$SEC_DIR/ctf" "$SEC_DIR/cases" "$SEC_DIR/tools" "$BIN_DIR"

# Preserve existing allowlist entries; never overwrite user-approved lab targets.
touch "$SEC_DIR/targets/allowlist.txt"
for t in 127.0.0.1 localhost ::1; do grep -Fxq "$t" "$SEC_DIR/targets/allowlist.txt" || echo "$t" >> "$SEC_DIR/targets/allowlist.txt"; done

# Copy lab-only engines into a stable installation path. Source files may lose their
# executable bit when checked out through some GitHub/CI paths, so test for -f here
# and enforce executability on the installed copies.
if [[ -f "$ROOT_DIR/tools/report-engine.sh" ]]; then
  cp "$ROOT_DIR/tools/report-engine.sh" "$SEC_DIR/tools/report-engine.sh"
  chmod +x "$SEC_DIR/tools/report-engine.sh"
fi
if [[ -f "$ROOT_DIR/tools/phone-osint.sh" ]]; then
  cp "$ROOT_DIR/tools/phone-osint.sh" "$SEC_DIR/tools/phone-osint.sh"
  chmod +x "$SEC_DIR/tools/phone-osint.sh"
fi

cat > "$SEC_DIR/ctf/targets.tsv" <<'EOF'
id	name	category	scope	objective
CTF001	Web Basics	web	local-only	Input validation and XSS concepts
CTF002	SQL Lab	web	local-only	SQL injection identification and remediation
CTF003	Auth Lab	auth	local-only	Session and authorization review
CTF004	API Lab	api	local-only	API validation and access-control review
CTF005	Network Lab	network	local-only	Service discovery and hardening
CTF006	Forensics Lab	forensics	local-only	Log and artifact analysis
CTF007	Phone OSINT Lab	privacy	local-only	Phone metadata, privacy-risk, and recovery-flow review using synthetic data
EOF

cat > "$SEC_DIR/cases/catalog.tsv" <<'EOF'
id	category	title	severity	scope
001	web	SQL injection fundamentals	high	local-only
002	web	Cross-site scripting fundamentals	medium	local-only
003	web	IDOR and authorization review	high	local-only
004	web	SSRF detection concepts	high	local-only
005	web	File-upload validation	high	local-only
006	web	SSTI detection concepts	high	local-only
007	network	Service exposure review	medium	local-only
008	auth	Authentication and session review	high	local-only
009	config	Security-header review	low	local-only
010	crypto	Weak-hash identification	medium	local-only
011	privacy	Phone OSINT and privacy audit	medium	local-only
EOF

python3 - "$SEC_DIR/cases/catalog.tsv" <<'PY'
import csv, sys
from pathlib import Path
p=Path(sys.argv[1]); rows=list(csv.DictReader(p.open(), delimiter='\t'))
cats=['web','api','auth','network','config','crypto','cloud','container','mobile','forensics','logging','supply-chain']
patterns=['input validation','access control','session handling','error handling','configuration review','logging review','dependency review','rate-limit testing','header review','secret handling']
for i in range(12,1001):
    rows.append({'id':f'{i:04d}','category':cats[(i-12)%len(cats)],'title':f'{patterns[(i-12)%len(patterns)]} training case {i:04d}','severity':['low','medium','high'][(i-12)%3],'scope':'local-only'})
with p.open('w', newline='') as f:
    w=csv.DictWriter(f, fieldnames=['id','category','title','severity','scope'], delimiter='\t'); w.writeheader(); w.writerows(rows)
PY

cat > "$BIN_DIR/guard" <<'GUARD'
#!/usr/bin/env bash
set -euo pipefail
SEC_DIR="${SEC_LAB_DIR:-${HOME}/sec_lab}"
target="${1:-}"
[[ -n "$target" ]] || { echo 'Target required.' >&2; exit 2; }
case "$target" in
  localhost|127.0.0.1|::1) : ;;
  10.*|192.168.*|172.1[6-9].*|172.2[0-9].*|172.3[0-1].*)
    grep -Fxq "$target" "$SEC_DIR/targets/allowlist.txt" || { echo 'BLOCKED: target is not allowlisted.' >&2; exit 10; } ;;
  *) echo 'BLOCKED: only localhost or explicitly allowlisted private targets are permitted.' >&2; exit 10;;
esac
echo "$target"
GUARD
chmod +x "$BIN_DIR/guard"

cat > "$BIN_DIR/report" <<'REPORT'
#!/usr/bin/env bash
set -euo pipefail
SEC_DIR="${SEC_LAB_DIR:-${HOME}/sec_lab}"
ENGINE="${SEC_LAB_ENGINE:-$SEC_DIR/tools/report-engine.sh}"
if [[ ! -x "$ENGINE" ]]; then
  echo "Report Engine not executable: $ENGINE" >&2
  exit 2
fi
if [[ -n "${REPORT_TYPE:-}" && -n "${TARGET:-}" && -n "${REPORT_TITLE:-}" ]]; then
  if [[ -n "${RESULT_FILE:-}" && -f "$RESULT_FILE" ]]; then
    exec "$ENGINE" from-file "$REPORT_TYPE" "$TARGET" "$REPORT_TITLE" "$RESULT_FILE" "${REPORT_STATUS:-completed}"
  fi
  exec "$ENGINE" new "$REPORT_TYPE" "$TARGET" "$REPORT_TITLE" "${REPORT_STATUS:-completed}"
fi
out="${1:-$SEC_DIR/reports/report-$(date +%Y%m%d-%H%M%S).md}"
mkdir -p "$(dirname "$out")"
cat > "$out" <<EOF
# Security Test Report

- Date: $(date -Is)
- Scope: authorized/local lab only
- Target: ${TARGET:-not specified}

## Findings

$(cat "${RESULT_FILE:-/dev/null}" 2>/dev/null || true)

## Evidence

Attach relevant command output, screenshots, logs, and remediation notes here.
EOF
echo "Report: $out"
REPORT
chmod +x "$BIN_DIR/report"

cat > "$BIN_DIR/sec" <<'CMD'
#!/usr/bin/env bash
set -euo pipefail
SEC_DIR="${SEC_LAB_DIR:-${HOME}/sec_lab}"
PHONE_TOOL="$SEC_DIR/tools/phone-osint.sh"
case "${1:-help}" in
  scan|recon|vuln)
    target="${2:-}"; [[ -n "$target" ]] || read -r -p 'Target: ' target
    target="$("$HOME/bin/guard" "$target")" || exit $?
    stamp="$(date +%Y%m%d-%H%M%S)"; result="$SEC_DIR/reports/$stamp-$1.txt"
    case "$1" in
      scan) nmap -sV -- "$target" ;;
      recon) nmap -sV --top-ports 100 -- "$target" ;;
      vuln) nmap -sV --script vuln -- "$target" ;;
    esac 2>&1 | tee "$result"
    REPORT_TYPE="$1" REPORT_TITLE="Security $1 result" TARGET="$target" RESULT_FILE="$result" "$HOME/bin/report"
    ;;
  phone)
    shift
    [[ -x "$PHONE_TOOL" ]] || { echo "Phone OSINT tool not installed: $PHONE_TOOL" >&2; exit 2; }
    exec "$PHONE_TOOL" "$@"
    ;;
  allow)
    target="${2:-}"; [[ -n "$target" ]] || { echo 'Usage: sec allow PRIVATE_IP'; exit 2; }
    case "$target" in
      10.*|192.168.*|172.1[6-9].*|172.2[0-9].*|172.3[0-1].*) : ;;
      *) echo 'Only RFC1918 private IPv4 targets can be allowlisted.' >&2; exit 10 ;;
    esac
    grep -Fxq "$target" "$SEC_DIR/targets/allowlist.txt" || printf '%s\n' "$target" >> "$SEC_DIR/targets/allowlist.txt"
    echo "Allowlisted: $target"
    ;;
  ctf) printf 'CTF catalog: %s\n' "$SEC_DIR/ctf/targets.tsv"; column -t -s $'\t' "$SEC_DIR/ctf/targets.tsv" 2>/dev/null || cat "$SEC_DIR/ctf/targets.tsv" ;;
  lab) exec "$HOME/bin/lab" ;;
  report) exec "$HOME/bin/report" "${2:-}" ;
  doctor) "$HOME/bin/lab" --doctor ;
  help|*) cat <<'EOF'
Commands:
  scan [target]    authorized scan + automatic report
  recon [target]   service discovery + report
  vuln [target]    vulnerability checks + report
  phone <action>   offline phone metadata/privacy audit or synthetic CTF fixture
  allow PRIVATE_IP add an exact RFC1918 private lab target to the allowlist
  ctf              show local CTF targets
  lab              rebuild lab assets
  report [file]    create a report
  doctor           health check
EOF
  ;;
esac
CMD
chmod +x "$BIN_DIR/sec"

cat > "$BIN_DIR/lab" <<'LAB'
#!/usr/bin/env bash
set -euo pipefail
SEC_DIR="${SEC_LAB_DIR:-${HOME}/sec_lab}"
if [[ "${1:-}" == "--doctor" ]]; then
  echo '== Lab health =='
  for x in nmap python3 git curl wget nc tcpdump ssh hydra sqlmap; do command -v "$x" >/dev/null 2>&1 && echo "[OK] $x" || echo "[--] $x"; done
  [[ -s "$SEC_DIR/targets/allowlist.txt" ]] && echo '[OK] safety allowlist' || echo '[--] safety allowlist'
  [[ -s "$SEC_DIR/cases/catalog.tsv" ]] && echo '[OK] CTF/training catalog' || echo '[--] CTF/training catalog'
  [[ -x "$SEC_DIR/../bin/report" ]] && echo '[OK] report command' || true
  [[ -x "$SEC_DIR/tools/phone-osint.sh" ]] && echo '[OK] phone OSINT tool' || echo '[--] phone OSINT tool'
  [[ -x "$SEC_DIR/tools/report-engine.sh" ]] && echo '[OK] report engine' || echo '[--] report engine'
  grep -q $'CTF007\tPhone OSINT Lab' "$SEC_DIR/ctf/targets.tsv" && echo '[OK] phone CTF target' || echo '[--] phone CTF target'
  exit 0
fi
mkdir -p "$SEC_DIR" "$SEC_DIR/targets" "$SEC_DIR/reports" "$SEC_DIR/ctf" "$SEC_DIR/cases"
touch "$SEC_DIR/targets/allowlist.txt"
for t in localhost 127.0.0.1 ::1; do grep -Fxq "$t" "$SEC_DIR/targets/allowlist.txt" || echo "$t" >> "$SEC_DIR/targets/allowlist.txt"; done
printf 'Lab ready: %s\n' "$SEC_DIR"
printf 'Safety mode: localhost/private allowlist only\n'
printf 'Training cases: '; wc -l < "$SEC_DIR/cases/catalog.tsv" 2>/dev/null || true
LAB
chmod +x "$BIN_DIR/lab"

if ! grep -Fq 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# Cybersecurity lab commands\nexport PATH="$HOME/bin:$PATH"\n' >> "$HOME/.bashrc"
fi

echo 'Enhanced lab installed.'
echo 'Commands: scan recon vuln phone allow ctf lab report doctor help'
echo 'Phone OSINT: metadata + defensive privacy audit + synthetic CTF fixture only.'
echo 'Safety guard: localhost by default; private IPs require allowlisting.'
