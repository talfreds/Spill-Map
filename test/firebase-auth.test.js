import test from "node:test";
import assert from "node:assert/strict";

import { createGoogleSignInProvider } from "../src/firebase/auth.js";
import { buildFirebaseConfig } from "../src/firebase/config.js";

test("buildFirebaseConfig maps environment variables into Firebase config", () => {
  const config = buildFirebaseConfig({
    FIREBASE_API_KEY: "api-key",
    FIREBASE_PROJECT_ID: "pinchat-dev",
    FIREBASE_APP_ID: "1:123:web:456",
    FIREBASE_MESSAGING_SENDER_ID: "123",
  });

  assert.deepEqual(config, {
    apiKey: "api-key",
    authDomain: "pinchat-dev.firebaseapp.com",
    projectId: "pinchat-dev",
    storageBucket: "pinchat-dev.firebasestorage.app",
    messagingSenderId: "123",
    appId: "1:123:web:456",
    measurementId: undefined,
  });
});

test("buildFirebaseConfig rejects missing required values", () => {
  assert.throws(() => buildFirebaseConfig({}), /Missing required Firebase configuration/);
});

test("createGoogleSignInProvider configures the Google provider", () => {
  const provider = createGoogleSignInProvider();

  assert.equal(provider.providerId, "google.com");
});
