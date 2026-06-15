# Spill-Map

PinChat phase 1 in this repository is limited to Firebase/GCP bootstrapping for authentication.

## Files added

- `/home/runner/work/Spill-Map/Spill-Map/talfreds/Spill-Map/src/firebase/config.js` – Firebase web app config loader
- `/home/runner/work/Spill-Map/Spill-Map/talfreds/Spill-Map/src/firebase/app.js` – idempotent Firebase app initialization
- `/home/runner/work/Spill-Map/Spill-Map/talfreds/Spill-Map/src/firebase/auth.js` – Google Sign-In provider plus email/password auth helpers
- `/home/runner/work/Spill-Map/Spill-Map/talfreds/Spill-Map/scripts/validate-auth.js` – email/password auth validation script that retrieves a Firebase ID token

## Install

```bash
npm install
```

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