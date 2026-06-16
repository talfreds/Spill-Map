# Copilot Instructions for Spill-Map

## Project context

- This repository contains a Flutter/FastAPI stack:
  - FastAPI backend in `backend/` with Firebase admin SDK integration for Firestore and token verification
  - Flutter frontend shell in `spill_flutter` for web and mobile platforms
- Use repository root package.json scripts as the source of truth for setup, run, and test workflows.

## Root-first tooling rule

- Always perform tooling setup from repository root.
- Prefer root npm scripts over direct nested commands.
- If a tool is needed, add or update a root script in package.json instead of asking users to manually run setup inside subfolders.

## Supported root commands

- Install Node dependencies: npm install
- Install Flutter SDK locally: npm run flutter:install
- Validate Maps env and template: npm run flutter:web:prepare-env
- Get Flutter packages: npm run flutter:pub:get
- Run Flutter web in Codespaces: npm run flutter:web:run
- Run Flutter tests: npm run flutter:test
- Install backend dependencies: npm run backend:install
- Run backend (FastAPI): npm run backend:run
- Run backend tests: npm run backend:test
- Run dev (backend + Flutter web): npm run dev

## Environment and key handling

- Load environment values from root .env.
- GOOGLE_API_KEY is for Maps SDK for Android, Maps SDK for iOS, Maps JavaScript API, and Places API.
- FIREBASE_SERVICE_ACCOUNT_PATH points to the Firebase admin SDK service account JSON key for backend Firestore and token verification.
- Never hardcode real API keys or service account paths in tracked files.
- TODO before production: split dev and prod keys, apply strict API and referrer or app restrictions, and rotate any key used during development.

## Flutter-specific guidance

- Keep Flutter code under spill_flutter.
- spill_flutter/web/index.html must keep the __MAPS_API_KEY__ placeholder in git.
- scripts/flutter-web-run.sh injects GOOGLE_API_KEY at runtime and restores the placeholder on exit.
- Use Riverpod providers for map and pin state updates.
- **API Key Configuration**: Use `String.fromEnvironment('MAPS_API_KEY')` in Dart for all platforms (Web, Android, iOS).
  - Web: Injected by prepare-flutter-web-env.js script into index.html
  - Android: Add to AndroidManifest.xml after running `npm run flutter:android:setup`
  - iOS: Add to build configuration after running `npm run flutter:ios:setup`

## Dashboard UI

- SpillDashboard: Main layout widget with 30% feed (left) and 70% map (right) on desktop
- SpillFeed: Scrollable list of spill cards with floating action button for "New Spill"
- Uses ArchivoBlack font for headings and SpaceMono for body text
- Responsive: Stacks vertically on mobile, splits horizontally on desktop (≥800px width)

## Testing expectations

- For backend auth changes, run npm run backend:test when relevant.
- For Flutter changes, run npm run flutter:test.
- For map interaction changes, verify long-press updates pin state and opens the spill bottom sheet.

## Editing conventions

- Keep changes minimal and focused.
- Do not revert unrelated local changes.
- Update docs (README.md and or this file) when workflow commands or setup behavior change.
