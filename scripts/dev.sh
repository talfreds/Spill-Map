#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INDEX_PATH="$ROOT_DIR/spill_flutter/web/index.html"
BACKUP_PATH="$ROOT_DIR/spill_flutter/web/index.html.bak"
FLUTTER="$ROOT_DIR/.tooling/flutter/bin/flutter"

cleanup() {
  if [[ -f "$BACKUP_PATH" ]]; then
    mv "$BACKUP_PATH" "$INDEX_PATH"
    echo "Restored index.html placeholder"
  fi
}

trap cleanup EXIT

# ── 0. Root dependencies ──────────────────────────────────────────────────────
if [[ ! -d "$ROOT_DIR/node_modules" ]]; then
  echo "Root dependencies not found — installing..."
  npm --prefix "$ROOT_DIR" install --yes
fi

# ── 1. Flutter SDK ────────────────────────────────────────────────────────────
if [[ ! -x "$FLUTTER" ]]; then
  echo "Flutter SDK not found — installing..."
  npm --prefix "$ROOT_DIR" run flutter:install
fi

# ── 2. Flutter pub dependencies ───────────────────────────────────────────────
PUBSPEC="$ROOT_DIR/spill_flutter/pubspec.yaml"
PKG_CONFIG="$ROOT_DIR/spill_flutter/.dart_tool/package_config.json"
if [[ ! -f "$PKG_CONFIG" ]] || [[ "$PUBSPEC" -nt "$PKG_CONFIG" ]]; then
  echo "Flutter packages out of date — running pub get..."
  npm --prefix "$ROOT_DIR" run flutter:pub:get
fi

# ── 3. Backend Python virtualenv + pip dependencies ──────────────────────────
# Ensure python3-venv is installed
if ! python3 -m venv --help &>/dev/null; then
  echo "python3-venv not found — installing..."
  sudo apt-get update && sudo apt-get install -y python3-venv
fi

VENV="$ROOT_DIR/.venv-backend"
REQUIREMENTS="$ROOT_DIR/backend/requirements.txt"
VENV_STAMP="$VENV/.installed.stamp"
if [[ ! -f "$VENV_STAMP" ]] || [[ "$REQUIREMENTS" -nt "$VENV_STAMP" ]]; then
  echo "Backend dependencies out of date — installing..."
  npm --prefix "$ROOT_DIR" run backend:install
  touch "$VENV_STAMP"
fi

# ── 4. Inject Maps API key into index.html ────────────────────────────────────
cp "$INDEX_PATH" "$BACKUP_PATH"
node --env-file-if-exists="$ROOT_DIR/.env" "$ROOT_DIR/scripts/prepare-flutter-web-env.js" --inject

# ── 5. Run backend and Flutter web concurrently ───────────────────────────────
cd "$ROOT_DIR"
npx concurrently --names "backend,flutter" --prefix-colors "cyan,magenta" "npm run backend:run" "bash scripts/flutter-web-run-no-prep.sh"
