"""Firebase configuration validation for the backend."""

import os
from typing import Dict, Optional


REQUIRED_FIREBASE_ENV_VARS = [
    "FIREBASE_API_KEY",
    "FIREBASE_PROJECT_ID",
    "FIREBASE_APP_ID",
    "FIREBASE_MESSAGING_SENDER_ID",
]


def build_firebase_config(env: Optional[Dict[str, str]] = None) -> Dict[str, str]:
    """
    Build Firebase config from environment variables.
    
    Args:
        env: Environment dict (defaults to os.environ)
        
    Returns:
        Dictionary with Firebase configuration
        
    Raises:
        ValueError: If required Firebase configuration is missing
    """
    if env is None:
        env = os.environ
    
    missing = [name for name in REQUIRED_FIREBASE_ENV_VARS if name not in env]
    
    if missing:
        raise ValueError(
            f"Missing required Firebase configuration: {', '.join(missing)}"
        )
    
    project_id = env["FIREBASE_PROJECT_ID"]
    
    return {
        "apiKey": env["FIREBASE_API_KEY"],
        "authDomain": env.get("FIREBASE_AUTH_DOMAIN", f"{project_id}.firebaseapp.com"),
        "projectId": project_id,
        "storageBucket": env.get("FIREBASE_STORAGE_BUCKET", f"{project_id}.firebasestorage.app"),
        "messagingSenderId": env["FIREBASE_MESSAGING_SENDER_ID"],
        "appId": env["FIREBASE_APP_ID"],
        "measurementId": env.get("FIREBASE_MEASUREMENT_ID"),
    }


def validate_firebase_config(env: Optional[Dict[str, str]] = None) -> Dict[str, str]:
    """Validate and return Firebase configuration. Raises on validation failure."""
    return build_firebase_config(env)
