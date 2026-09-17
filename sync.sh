#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"

cd "$PROJECT_DIR"

if ! command -v git >/dev/null 2>&1; then
    echo "[!] Git is not installed."
    echo "    On Termux: pkg install git"
    exit 1
fi

if [ ! -d .git ]; then
    git init
    git branch -M main
fi

if ! git config user.name >/dev/null 2>&1; then
    git config user.name "Autonomous Assistant"
fi

if ! git config user.email >/dev/null 2>&1; then
    git config user.email "autonomous-assistant@users.noreply.github.com"
fi

git add .
if ! git diff --cached --quiet; then
    git commit -m "Initial project setup"
fi

echo "[✓] Local Git repository is ready."

if command -v gh >/dev/null 2>&1; then
    if gh auth status >/dev/null 2>&1; then
        if ! git remote get-url origin >/dev/null 2>&1; then
            echo "[i] Creating private GitHub repository: $PROJECT_NAME"
            gh repo create "$PROJECT_NAME" --private --source=. --remote=origin --push
        else
            echo "[i] GitHub remote already exists; pushing to main."
            git push -u origin main
        fi
        echo "[✓] GitHub synchronization completed."
    else
        echo "[!] GitHub CLI is installed but not authenticated."
        echo "    Run: gh auth login"
    fi
else
    echo "[i] GitHub CLI is not installed."
    echo "    To enable automatic GitHub creation/Push on Termux:"
    echo "    pkg install gh"
    echo "    gh auth login"
fi
