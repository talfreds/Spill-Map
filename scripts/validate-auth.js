import { buildFirebaseConfig } from "../src/firebase/config.js";

const REQUIRED_TEST_ENV_VARS = ["FIREBASE_TEST_EMAIL", "FIREBASE_TEST_PASSWORD"];

function readRequiredEnv(name, env = process.env) {
  if (!env[name]) {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return env[name];
}

function assertLooksLikeJwt(token) {
  const parts = token.split(".");

  if (parts.length !== 3 || parts.some((part) => part.length === 0)) {
    throw new Error("Expected Firebase ID token to be a non-empty JWT.");
  }
}

async function authenticateWithEmailPassword(env = process.env) {
  const { apiKey } = buildFirebaseConfig(env);
  const email = readRequiredEnv("FIREBASE_TEST_EMAIL", env);
  const password = readRequiredEnv("FIREBASE_TEST_PASSWORD", env);
  const response = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${encodeURIComponent(apiKey)}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email,
        password,
        returnSecureToken: true,
      }),
    }
  );

  const payload = await response.json();

  if (!response.ok) {
    const message = payload?.error?.message ?? response.statusText;
    throw new Error(`Firebase email/password authentication failed: ${message}`);
  }

  return payload;
}

async function main() {
  REQUIRED_TEST_ENV_VARS.forEach((name) => readRequiredEnv(name));

  const authResult = await authenticateWithEmailPassword();
  assertLooksLikeJwt(authResult.idToken);

  console.log(
    JSON.stringify(
      {
        projectId: buildFirebaseConfig().projectId,
        email: authResult.email,
        localId: authResult.localId,
        expiresIn: authResult.expiresIn,
        idTokenPreview: `${authResult.idToken.slice(0, 24)}...`,
      },
      null,
      2
    )
  );
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
