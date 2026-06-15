import { getApp, getApps, initializeApp } from "firebase/app";

import { buildFirebaseConfig } from "./config.js";

export function getFirebaseApp(env = process.env) {
  if (getApps().length > 0) {
    return getApp();
  }

  return initializeApp(buildFirebaseConfig(env));
}
