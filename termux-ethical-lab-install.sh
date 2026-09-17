#!/usr/bin/env bash
set -euo pipefail

# Termux Ethical Hacking / Defensive Security Lab bootstrapper.
# Use security tools only against systems you own or are explicitly authorized to test.

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RED='\033[0;31m'
RESET='\033[0m'
SEC_DIR="${HOME}/sec_lab"
BIN_DIR="${HOME}/bin"
COMMAND_FILE="${BIN_DIR}/sec"

log() { printf '%b\n' "$1"; }

show_banner() {
  log "${CYAN}====================================================${RESET}"
  log "${GREEN}      🛡️ Cybersecurity Lab Automation - Termux     ${RESET}"
  log "${CYAN}====================================================${RESET}"
}

install_tools() {
  log "${YELLOW}[!] تحديث المستودعات والحزم...${RESET}"
  pkg update -y
  pkg upgrade -y

  local tools=(nmap python git curl wget netcat-openbsd tcpdump openssh hydra sqlmap)
  log "${YELLOW}[!] تثبيت الأدوات الأساسية...${RESET}"
  for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
      log "${GREEN}[✓] $tool مثبت بالفعل.${RESET}"
    else
      log "${BLUE}[+] تثبيت $tool...${RESET}"
      if pkg install -y "$tool"; then
        log "${GREEN}[✓] تم تثبيت $tool.${RESET}"
      else
        log "${RED}[-] تعذر تثبيت $tool؛ تم تخطيه.${RESET}"
      fi
    fi
  done
}

create_lab() {
  mkdir -p "$SEC_DIR" "$SEC_DIR/notes" "$SEC_DIR/cases" "$SEC_DIR/output" "$SEC_DIR/ctf"

  cat > "$SEC_DIR/README.md" <<'EOF'
# Cybersecurity & Ethical Hacking Lab

مختبر محلي للتعلم وCTF واختبارات الأمن المصرح بها.

## الأوامر ذات الكلمة الواحدة
- `scan`     فحص هدف يحدده المستخدم (مصرح به فقط).
- `recon`    جمع معلومات أساسية عن هدف يحدده المستخدم.
- `vuln`     تشغيل فحص ثغرات على هدف يحدده المستخدم.
- `ctf`      إدارة مساحة تمارين CTF محلية.
- `lab`      إنشاء/تحديث بيئة المختبر المحلية.
- `update`   تحديث الأدوات وملفات المختبر.
- `doctor`   فحص حالة الأدوات والاختصارات.
- `help`     عرض المساعدة.

## سيناريوهات التدريب
يُنشئ المختبر فهرسًا كبيرًا من حالات تدريبية اصطناعية قابلة للتوسع، بدل تنزيل أو نشر ثغرات حقيقية على أجهزة خارجية. يمكن إضافة حالات جديدة إلى `cases/`.

## الاستخدام المسؤول
استخدم الأدوات فقط على أنظمة تملكها أو لديك تصريح صريح لاختبارها. لا تفحص أو تستغل أهدافًا عامة دون تفويض.
EOF

  cat > "$SEC_DIR/cases/catalog.tsv" <<'EOF'
id	category	title	severity	training_scope
001	web	SQL injection fundamentals	high	local-lab
002	web	Cross-site scripting fundamentals	medium	local-lab
003	web	IDOR / authorization testing	high	local-lab
004	web	Server-side request forgery concepts	high	local-lab
005	web	File-upload validation	high	local-lab
006	web	SSTI detection concepts	high	local-lab
007	network	Service exposure and banner analysis	medium	local-lab
008	auth	Authentication/session testing	high	local-lab
009	config	Security-header validation	low	local-lab
010	crypto	Weak-hash identification	medium	local-lab
EOF

  # Generate an expanded synthetic training catalog automatically.
  python - "$SEC_DIR/cases/catalog.tsv" <<'PY'
import csv
import sys
from pathlib import Path

path = Path(sys.argv[1])
rows = list(csv.DictReader(path.open(encoding='utf-8'), delimiter='\t'))
base = [dict(r) for r in rows]
categories = [
    'web', 'api', 'auth', 'network', 'config', 'crypto', 'cloud',
    'container', 'mobile', 'forensics', 'logging', 'supply-chain'
]
patterns = [
    'input validation', 'access control', 'session handling', 'error handling',
    'configuration review', 'logging review', 'dependency review',
    'rate-limit testing', 'content-security-policy review', 'secret handling'
]
next_id = 11
while len(rows) < 1000:
    category = categories[(next_id - 11) % len(categories)]
    pattern = patterns[(next_id - 11) % len(patterns)]
    rows.append({
        'id': f'{next_id:04d}',
        'category': category,
        'title': f'{pattern} training case {next_id:04d}',
        'severity': ['low', 'medium', 'high'][(next_id - 11) % 3],
        'training_scope': 'local-lab'
    })
    next_id += 1
with path.open('w', encoding='utf-8', newline='') as f:
    w = csv.DictWriter(f, fieldnames=['id','category','title','severity','training_scope'], delimiter='\t')
    w.writeheader()
    w.writerows(rows)
print(f'Generated {len(rows)} local training cases.')
PY

  log "${GREEN}[✓] تم إنشاء المختبر: $SEC_DIR${RESET}"
  log "${GREEN}[✓] تم إنشاء 1000 حالة تدريبية اصطناعية محلية.${RESET}"
}

install_command() {
  mkdir -p "$BIN_DIR"
  cat > "$COMMAND_FILE" <<'CMD'
#!/usr/bin/env bash
set -euo pipefail

SEC_DIR="${HOME}/sec_lab"
TOOLS=(nmap python git curl wget nc tcpdump ssh hydra sqlmap)

usage() {
  cat <<'EOF'
Cybersecurity Lab - one-word commands

  scan [target]    Authorized Nmap scan. Prompts if target is missing.
  recon [target]   Basic authorized service discovery.
  vuln [target]    Nmap vulnerability-script scan; authorized targets only.
  ctf              Open the local CTF workspace.
  lab              Create/update the local training catalog.
  update           Update Termux packages and security tools.
  doctor           Check installed tools and lab health.
  help              Show this help.
EOF
}

need_target() {
  local target="${1:-}"
  if [[ -z "$target" ]]; then
    read -r -p 'Target (owned/authorized only): ' target
  fi
  if [[ -z "$target" ]]; then
    echo 'No target supplied.' >&2
    exit 2
  fi
  printf '%s' "$target"
}

case "${1:-help}" in
  scan)
    target="$(need_target "${2:-}")"
    nmap -sV -- "$target"
    ;;
  recon)
    target="$(need_target "${2:-}")"
    nmap -sV --top-ports 100 -- "$target"
    ;;
  vuln)
    target="$(need_target "${2:-}")"
    nmap -sV --script vuln -- "$target"
    ;;
  ctf)
    mkdir -p "$SEC_DIR/ctf"
    cd "$SEC_DIR/ctf"
    printf 'CTF workspace: %s\n' "$PWD"
    ;;
  lab)
    exec "$HOME/bin/sec-lab-setup"
    ;;
  update)
    exec "$HOME/bin/sec-lab-setup" --update-only
    ;;
  doctor)
    echo '== Tool status =='
    for tool in "${TOOLS[@]}"; do
      if command -v "$tool" >/dev/null 2>&1; then printf '[OK] %s\n' "$tool"; else printf '[--] %s\n' "$tool"; fi
    done
    [[ -f "$SEC_DIR/cases/catalog.tsv" ]] && echo '[OK] training catalog' || echo '[--] training catalog'
    ;;
  help|*)
    usage
    ;;
esac
CMD
  chmod +x "$COMMAND_FILE"

  cat > "$BIN_DIR/sec-lab-setup" <<'SETUP'
#!/usr/bin/env bash
set -euo pipefail
SEC_DIR="${HOME}/sec_lab"
BIN_DIR="${HOME}/bin"
TOOLS=(nmap python git curl wget netcat-openbsd tcpdump openssh hydra sqlmap)
if [[ "${1:-}" != "--update-only" ]]; then
  mkdir -p "$SEC_DIR/cases" "$SEC_DIR/ctf" "$SEC_DIR/output" "$BIN_DIR"
fi
pkg update -y
pkg upgrade -y
for tool in "${TOOLS[@]}"; do pkg install -y "$tool" >/dev/null 2>&1 || true; done
if [[ ! -f "$SEC_DIR/cases/catalog.tsv" ]]; then
  printf 'id\tcategory\ttitle\tseverity\ttraining_scope\n' > "$SEC_DIR/cases/catalog.tsv"
fi
printf 'Lab ready: %s\n' "$SEC_DIR"
SETUP
  chmod +x "$BIN_DIR/sec-lab-setup"

  # Make one-word commands available in future shells without overwriting user files.
  local rc="$HOME/.bashrc"
  touch "$rc"
  if ! grep -Fq 'export PATH="$HOME/bin:$PATH"' "$rc"; then
    printf '\n# Cybersecurity lab one-word commands\nexport PATH="$HOME/bin:$PATH"\n' >> "$rc"
  fi
  export PATH="$BIN_DIR:$PATH"

  log "${GREEN}[✓] تم تفعيل الأوامر: scan recon vuln ctf lab update doctor help${RESET}"
}

show_help() {
  cat <<'EOF'
الاستخدام:
  ./termux-ethical-lab-install.sh          تثبيت كل شيء تلقائيًا
  ./termux-ethical-lab-install.sh --help   عرض المساعدة
EOF
}

main() {
  show_banner
  case "${1:-install}" in
    --help|-h|help)
      show_help
      ;;
    install)
      install_tools
      create_lab
      install_command
      log "${GREEN}[✓] اكتمل الإعداد التلقائي بالكامل.${RESET}"
      log "${YELLOW}[!] افتح جلسة Termux جديدة أو نفّذ: source ~/.bashrc${RESET}"
      ;;
    *)
      log "${RED}خيار غير معروف: $1${RESET}"
      show_help
      exit 2
      ;;
  esac
}

main "$@"
