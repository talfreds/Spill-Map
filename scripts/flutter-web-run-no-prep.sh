#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load environment for --dart-define flags
if [[ -f "$ROOT_DIR/.env" ]]; then
  set -a
  source "$ROOT_DIR/.env"
  set +a
fi

DART_DEFINES=""
for var in FIREBASE_API_KEY FIREBASE_APP_ID FIREBASE_MESSAGING_SENDER_ID FIREBASE_PROJECT_ID FIREBASE_AUTH_DOMAIN FIREBASE_STORAGE_BUCKET BACKEND_BASE_URL; do
  if [[ -n "${!var:-}" ]]; then
    DART_DEFINES="$DART_DEFINES --dart-define=$var=${!var}"
  fi
done

cd "$ROOT_DIR/spill_flutter"
../.tooling/flutter/bin/flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 $DART_DEFINES
