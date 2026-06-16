#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="$ROOT_DIR/.tooling"
SDK_DIR="$TOOLS_DIR/flutter"
FLUTTER_VERSION="3.44.2"
ARCHIVE="$TOOLS_DIR/flutter_linux_stable.tar.xz"
URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

mkdir -p "$TOOLS_DIR"

if [[ -x "$SDK_DIR/bin/flutter" ]]; then
  echo "Flutter SDK already installed at $SDK_DIR"
  "$SDK_DIR/bin/flutter" --version
  exit 0
fi

echo "Downloading Flutter SDK $FLUTTER_VERSION..."
curl -fL "$URL" -o "$ARCHIVE"

echo "Extracting Flutter SDK..."
tar -xJf "$ARCHIVE" -C "$TOOLS_DIR"

# Archive extracts to $TOOLS_DIR/flutter
"$SDK_DIR/bin/flutter" --version

echo "Flutter installed at $SDK_DIR"
echo "Use $SDK_DIR/bin/flutter or run npm scripts from repo root."
