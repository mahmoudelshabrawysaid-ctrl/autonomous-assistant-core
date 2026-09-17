#!/usr/bin/env bash
set -euo pipefail

# One-shot installer for the local ethical-security lab.
# It only prepares a controlled training environment; testing remains allowlist-gated.

TOOLS=(nmap python git curl wget netcat-openbsd tcpdump openssh hydra sqlmap)
for tool in "${TOOLS[@]}"; do
  command -v "$tool" >/dev/null 2>&1 || pkg install -y "$tool" || true
done

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
bash "$SCRIPT_DIR/lab-manager.sh"

printf '\nSetup complete. Start a new Termux shell or run: source ~/.bashrc\n'
printf 'Then use: scan, recon, vuln, allow, ctf, lab, report, doctor, help\n'
