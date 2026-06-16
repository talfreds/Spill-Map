# Copilot Instructions for Spill-Map

## Project context

- This repository contains two app layers:
  - Node/Firebase bootstrap code in src/firebase, validation in scripts/validate-auth.js.
  - Flutter frontend shell in spill_flutter.
- Use repository root package.json scripts as the source of truth for setup, run, and test workflows.

## Root-first tooling rule

- Always perform tooling setup from repository root.
- Prefer root npm scripts over direct nested commands.
- If a tool is needed, add or update a root script in package.json instead of asking users to manually run setup inside subfolders.

## Supported root commands

- Install Node dependencies: npm install
- Validate Firebase auth: npm run validate:auth
- Install Flutter SDK locally: npm run flutter:install
- Validate Maps env and template: npm run flutter:web:prepare-env
- Get Flutter packages: npm run flutter:pub:get
- Run Flutter web in Codespaces: npm run flutter:web:run
- Run Flutter tests: npm run flutter:test

## Environment and key handling

- Load environment values from root .env.
- GOOGLE_API_KEY is for Maps SDK for Android, Maps SDK for iOS, Maps JavaScript API, and Places API.
- FIREBASE_API_KEY remains for Firebase web SDK and auth usage.
- Never hardcode real API keys in tracked files.
- TODO before production: split dev and prod keys, apply strict API and referrer or app restrictions, and rotate any key used during development.

## Flutter-specific guidance

- Keep Flutter code under spill_flutter.
- spill_flutter/web/index.html must keep the __MAPS_API_KEY__ placeholder in git.
- scripts/flutter-web-run.sh injects GOOGLE_API_KEY at runtime and restores the placeholder on exit.
- Use Riverpod providers for map and pin state updates.

## Testing expectations

- For Node auth changes, run npm test and npm run validate:auth when relevant.
- For Flutter changes, run npm run flutter:test.
- For map interaction changes, verify long-press updates pin state and opens the spill bottom sheet.

## Editing conventions

- Keep changes minimal and focused.
- Do not revert unrelated local changes.
- Update docs (README.md and or this file) when workflow commands or setup behavior change.
