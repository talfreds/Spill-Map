#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Load .env file if it exists
if [[ -f "$ROOT_DIR/.env" ]]; then
  export $(grep -v '^#' "$ROOT_DIR/.env" | xargs)
fi

# Check if GOOGLE_API_KEY is set
if [[ -z "${GOOGLE_API_KEY:-}" ]]; then
  echo "Error: GOOGLE_API_KEY not found in .env file"
  exit 1
fi

# Get device ID from first argument, or prompt user
DEVICE_ID="${1:-}"

if [[ -z "$DEVICE_ID" ]]; then
  echo "Available devices:"
  cd "$ROOT_DIR/spill_flutter"
  ../.tooling/flutter/bin/flutter devices
  echo ""
  read -p "Enter device ID (or emulator name): " DEVICE_ID
fi

# Run Flutter on Android device with API key
cd "$ROOT_DIR/spill_flutter"
../.tooling/flutter/bin/flutter run -d "$DEVICE_ID" --dart-define=MAPS_API_KEY="$GOOGLE_API_KEY"
