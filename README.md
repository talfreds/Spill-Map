# Spill-Map

PinChat phase 1 in this repository is limited to Firebase/GCP bootstrapping for authentication.

This repository now also includes a Flutter frontend shell in `spill_flutter` for web preview in Codespaces and future native mobile builds.

## Files added

- `/home/runner/work/Spill-Map/Spill-Map/talfreds/Spill-Map/src/firebase/config.js` – Firebase web app config loader
- `/home/runner/work/Spill-Map/Spill-Map/talfreds/Spill-Map/src/firebase/app.js` – idempotent Firebase app initialization
- `/home/runner/work/Spill-Map/Spill-Map/talfreds/Spill-Map/src/firebase/auth.js` – Google Sign-In provider plus email/password auth helpers
- `/home/runner/work/Spill-Map/Spill-Map/talfreds/Spill-Map/scripts/validate-auth.js` – email/password auth validation script that retrieves a Firebase ID token

## Install

```bash
npm install
```

## Flutter frontend shell (Codespaces + mobile-ready)

The Flutter app lives in `spill_flutter` and is managed from repository root scripts.

### One-time setup

```bash
npm run flutter:install
npm run flutter:pub:get
```

### Run web preview in Codespaces

```bash
npm run flutter:web:run
```

Then open port `8080` in Codespaces preview.

### Flutter test command

```bash
npm run flutter:test
```

### Maps key behavior

- Flutter web map script uses `GOOGLE_API_KEY` only.
- `spill_flutter/web/index.html` is committed with a placeholder token (`__MAPS_API_KEY__`) only.
- `scripts/flutter-web-run.sh` injects `GOOGLE_API_KEY` at runtime and restores the placeholder when the process exits.
- `npm run flutter:web:prepare-env` validates env and template state without writing secrets to tracked files.
- Keep `FIREBASE_API_KEY` for Firebase web SDK usage and auth flows.

TODO before production:
- Create separate Google Maps keys for `dev` and `prod`.
- Restrict the web key by HTTP referrers to only approved domains.
- Restrict enabled APIs on the key to only required Maps and Places APIs.
- Rotate any key used during early development before shipping.

## Firebase initialization

1. Create or select a GCP project and attach Firebase to it.
2. Add a Firebase Web app in the Firebase console.
3. Copy `.env.example` to `.env` and fill in the Firebase web config values for your project.
4. In **Firebase Console → Authentication → Sign-in method**, enable:
   - **Google**
   - **Email/Password**

### Example initialization usage

```js
import { getFirebaseApp } from "./src/firebase/app.js";
import {
  createGoogleSignInProvider,
  getFirebaseAuth,
  signInWithEmailPassword,
} from "./src/firebase/auth.js";

const app = getFirebaseApp();
const auth = getFirebaseAuth();
const googleProvider = createGoogleSignInProvider();

await signInWithEmailPassword("tester@example.com", "change-me");
```

## Exact `gcloud` commands to enable required APIs

Replace `YOUR_GCP_PROJECT_ID` before running:

```bash
export PROJECT_ID="YOUR_GCP_PROJECT_ID"
gcloud config set project "$PROJECT_ID"

gcloud services enable firebase.googleapis.com --project="$PROJECT_ID"
gcloud services enable identitytoolkit.googleapis.com --project="$PROJECT_ID"
gcloud services enable maps-android-backend.googleapis.com --project="$PROJECT_ID"
gcloud services enable maps-ios-backend.googleapis.com --project="$PROJECT_ID"
gcloud services enable maps-backend.googleapis.com --project="$PROJECT_ID"
gcloud services enable places.googleapis.com --project="$PROJECT_ID"
```

## Auth validation

After enabling **Email/Password** and creating a test user, set:

- `FIREBASE_TEST_EMAIL`
- `FIREBASE_TEST_PASSWORD`

Then run (the command auto-loads `.env` when present):

```bash
npm run validate:auth
```

On success, the script signs in with Firebase Auth over the Identity Toolkit API and prints a preview of a valid Firebase ID token.