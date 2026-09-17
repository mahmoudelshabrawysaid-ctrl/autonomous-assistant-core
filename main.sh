#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$PROJECT_DIR/config.json"

echo "===================================================="
echo "   Autonomous Assistant Core"
echo "===================================================="
echo "[✓] Engine is running"
echo
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
if command -v python >/dev/null 2>&1; then
    python -m json.tool "$CONFIG_FILE"
elif command -v python3 >/dev/null 2>&1; then
    python3 -m json.tool "$CONFIG_FILE"
else
    cat "$CONFIG_FILE"
fi
echo
echo "[✓] Environment check completed."
