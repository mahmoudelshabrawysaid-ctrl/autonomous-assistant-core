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

printf "%b\n" "${CYAN}====================================================${RESET}"
printf "%b\n" "${GREEN}      🛡️ تثبيت حزمة الأمن السيبراني لـ Termux      ${RESET}"
printf "%b\n" "${CYAN}====================================================${RESET}"

# 1. Update Termux packages
printf "%b\n" "${YELLOW}[!] تحديث المستودعات والحزم...${RESET}"
pkg update -y
pkg upgrade -y

# 2. Install core security/diagnostic tools
TOOLS=(
  nmap
  python
  git
  curl
  wget
  netcat-openbsd
  tcpdump
  openssh
  hydra
  sqlmap
)

printf "%b\n" "${YELLOW}[!] جاري تثبيت الأدوات...${RESET}"
for tool in "${TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf "%b\n" "${GREEN}[✓] $tool مثبت بالفعل.${RESET}"
  else
    printf "%b\n" "${BLUE}[+] جاري تثبيت $tool...${RESET}"
    if pkg install -y "$tool"; then
      printf "%b\n" "${GREEN}[✓] تم تثبيت $tool.${RESET}"
    else
      printf "%b\n" "${RED}[-] تعذر تثبيت $tool تلقائياً؛ تم الانتقال للأداة التالية.${RESET}"
    fi
  fi
done

# 3. Create local lab workspace
SEC_DIR="$HOME/sec_lab"
mkdir -p "$SEC_DIR"

cat <<'EOF' > "$SEC_DIR/README.md"
# Cybersecurity & Ethical Hacking Lab

بيئة محلية للتعلم، وCTF، واختبارات الأمن المصرح بها.

## الأدوات
- Nmap
- SQLmap
- Hydra
- Netcat
- tcpdump
- OpenSSH
- Python 3
- Git / curl / wget

## الاستخدام المسؤول
استخدم هذه الأدوات فقط على أنظمة تملكها أو لديك تصريح صريح لاختبارها. لا تستخدمها لمسح أو استغلال أهداف عامة دون تفويض.
EOF

printf "%b\n" "${GREEN}====================================================${RESET}"
printf "%b\n" "${GREEN}[✓] اكتمل الإعداد. مجلد المختبر: $SEC_DIR${RESET}"
printf "%b\n" "${GREEN}[✓] تذكير: اختبر فقط الأنظمة المملوكة لك أو المصرح بها.${RESET}"
printf "%b\n" "${CYAN}====================================================${RESET}"
