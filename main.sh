#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$PROJECT_DIR/config.json"

printf '%s\n' "====================================================" "   Autonomous Assistant Core" "===================================================="
echo "[✓] Engine is running"
echo "[i] Project: $PROJECT_DIR"
echo "[i] Time: $(date)"
echo
echo "[i] System status:"
uptime || true

echo
echo "[i] Memory:"
if command -v free >/dev/null 2>&1; then
    free -h
else
    echo "free command is unavailable on this system."
fi

echo
echo "[i] Configuration:"
if command -v python3 >/dev/null 2>&1; then
    python3 -m json.tool "$CONFIG_FILE"
elif command -v python >/dev/null 2>&1; then
    python -m json.tool "$CONFIG_FILE"
else
    cat "$CONFIG_FILE"
fi

echo
echo "[i] OpenAI API:"
if [[ -n "${OPENAI_API_KEY:-}" ]]; then
    echo "[✓] OPENAI_API_KEY is configured in the environment."
else
    echo "[!] OPENAI_API_KEY is not configured."
    echo "    Set it in your local Termux environment; never put it in GitHub files."
fi

echo
echo "[✓] Environment check completed."
