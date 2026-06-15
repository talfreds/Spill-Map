const REQUIRED_FIREBASE_ENV_VARS = [
  "FIREBASE_API_KEY",
  "FIREBASE_PROJECT_ID",
  "FIREBASE_APP_ID",
  "FIREBASE_MESSAGING_SENDER_ID",
];

export function buildFirebaseConfig(env = process.env) {
  const missing = REQUIRED_FIREBASE_ENV_VARS.filter((name) => !env[name]);

  if (missing.length > 0) {
    throw new Error(
      `Missing required Firebase configuration: ${missing.join(", ")}`
    );
  }

  const projectId = env.FIREBASE_PROJECT_ID;

  return {
    apiKey: env.FIREBASE_API_KEY,
    authDomain: env.FIREBASE_AUTH_DOMAIN ?? `${projectId}.firebaseapp.com`,
    projectId,
    storageBucket:
      env.FIREBASE_STORAGE_BUCKET ?? `${projectId}.firebasestorage.app`,
    messagingSenderId: env.FIREBASE_MESSAGING_SENDER_ID,
    appId: env.FIREBASE_APP_ID,
    measurementId: env.FIREBASE_MEASUREMENT_ID,
  };
}
