import {
  GoogleAuthProvider,
  createUserWithEmailAndPassword,
  getAuth,
  signInWithEmailAndPassword,
  signOut,
} from "firebase/auth";

import { getFirebaseApp } from "./app.js";

export function getFirebaseAuth(env = process.env) {
  return getAuth(getFirebaseApp(env));
}

export function createGoogleSignInProvider() {
  const provider = new GoogleAuthProvider();
  provider.addScope("email");
  provider.addScope("profile");
  provider.setCustomParameters({ prompt: "select_account" });
  return provider;
}

export function registerWithEmailPassword(email, password, env = process.env) {
  return createUserWithEmailAndPassword(getFirebaseAuth(env), email, password);
}

export function signInWithEmailPassword(email, password, env = process.env) {
  return signInWithEmailAndPassword(getFirebaseAuth(env), email, password);
}

export async function getCurrentUserIdToken(forceRefresh = false, env = process.env) {
  const auth = getFirebaseAuth(env);

  if (!auth.currentUser) {
    throw new Error("No authenticated Firebase user is available.");
  }

  return auth.currentUser.getIdToken(forceRefresh);
}

export function signOutFirebaseUser(env = process.env) {
  return signOut(getFirebaseAuth(env));
}
