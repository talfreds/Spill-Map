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

### Run backend + frontend together in dev

```bash
npm run dev
```

Runs both backend (port `8000`) and Flutter web (port `8080`) concurrently with labelled output.

### Flutter test command

```bash
npm run flutter:test
```

## Backend (FastAPI + Firestore)

FastAPI backend code is in `backend`.

**Environment requirement**: set `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env` to the path of your Firebase service account JSON key for Firestore writes and token verification.

### One-time setup

```bash
npm run backend:install
```

### Run API locally

```bash
npm run backend:run
```

The API provides `POST /spill/create` with payload:

```json
{
  "lat": 49.2827,
  "lng": -123.1207,
  "message": "Oil sheen near the seawall",
  "image_url": "https://..."
}
```

Write requests require a Firebase ID token:

```text
Authorization: Bearer <firebase-id-token>
```

Comment writes use `POST /spill/{spill_id}/comments` with payload:

```json
{
  "message": "Saw this too"
}
```

### Firestore collections

- `spills`: `lat`, `lng`, `user_id`, `timestamp`, `message`, `image_url`
- `spill_comments`: `spill_id`, `user_id`, `message`, `timestamp`

### Build ARM64 image for OCI Ampere

```bash
npm run backend:docker:arm64
```

## Stage 4 social flow (Flutter)

The map long-press flow now supports:

- entering a spill message
- selecting a photo from gallery (`image_picker`)
- uploading the photo to Firebase Storage
- attaching the uploaded public URL to the spill payload before calling `POST /spill/create`
- immediately rendering the new spill marker from the create response while Firestore listeners stay reactive
- opening a spill detail sheet from the map or feed with the original post and real-time comments
- submitting comments through the backend while the Firestore-backed comment list updates live

For web runtime initialization, pass Firebase values as `--dart-define` values:

- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_AUTH_DOMAIN`
- `FIREBASE_STORAGE_BUCKET`
- `BACKEND_BASE_URL`

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