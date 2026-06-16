#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEX_PATH="$ROOT_DIR/spill_flutter/web/index.html"
BACKUP_PATH="$ROOT_DIR/spill_flutter/web/index.html.bak"

cleanup() {
  if [[ -f "$BACKUP_PATH" ]]; then
    mv "$BACKUP_PATH" "$INDEX_PATH"
    echo "Restored index.html placeholder"
  fi
}

trap cleanup EXIT

# Backup and prepare environment
cp "$INDEX_PATH" "$BACKUP_PATH"
node --env-file-if-exists="$ROOT_DIR/.env" "$ROOT_DIR/scripts/prepare-flutter-web-env.js" --inject

# Run backend and Flutter web concurrently
cd "$ROOT_DIR"
npx concurrently --names "backend,flutter" --prefix-colors "cyan,magenta" "npm run backend:run" "bash scripts/flutter-web-run-no-prep.sh"
