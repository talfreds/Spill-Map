#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEX_PATH="$ROOT_DIR/spill_flutter/web/index.html"
BACKUP_PATH="$ROOT_DIR/spill_flutter/web/index.html.bak"

cleanup() {
  if [[ -f "$BACKUP_PATH" ]]; then
    mv "$BACKUP_PATH" "$INDEX_PATH"
  fi
}

trap cleanup EXIT

cp "$INDEX_PATH" "$BACKUP_PATH"

node --env-file-if-exists="$ROOT_DIR/.env" "$ROOT_DIR/scripts/prepare-flutter-web-env.js" --inject

cd "$ROOT_DIR/spill_flutter"
../.tooling/flutter/bin/flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
