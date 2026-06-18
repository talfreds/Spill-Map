"""Test Firebase authentication and configuration validation."""

import unittest
import json
from unittest.mock import patch, MagicMock
from app.firebase_config import build_firebase_config, validate_firebase_config


class TestFirebaseConfig(unittest.TestCase):
    """Test Firebase configuration building."""

    def test_build_firebase_config_with_required_vars(self):
        """Test building config with all required environment variables."""
        env = {
            "FIREBASE_API_KEY": "api-key",
            "FIREBASE_PROJECT_ID": "pinchat-dev",
            "FIREBASE_APP_ID": "1:123:web:456",
            "FIREBASE_MESSAGING_SENDER_ID": "123",
        }
        
        config = build_firebase_config(env)
        
        self.assertEqual(config["apiKey"], "api-key")
        self.assertEqual(config["projectId"], "pinchat-dev")
        self.assertEqual(config["authDomain"], "pinchat-dev.firebaseapp.com")
        self.assertEqual(config["storageBucket"], "pinchat-dev.firebasestorage.app")
        self.assertEqual(config["messagingSenderId"], "123")
        self.assertEqual(config["appId"], "1:123:web:456")
        self.assertIsNone(config["measurementId"])

    def test_build_firebase_config_with_optional_vars(self):
        """Test building config with optional environment variables."""
        env = {
            "FIREBASE_API_KEY": "api-key",
            "FIREBASE_PROJECT_ID": "pinchat-dev",
            "FIREBASE_APP_ID": "1:123:web:456",
            "FIREBASE_MESSAGING_SENDER_ID": "123",
            "FIREBASE_AUTH_DOMAIN": "custom-auth.example.com",
            "FIREBASE_STORAGE_BUCKET": "custom-storage.example.com",
            "FIREBASE_MEASUREMENT_ID": "G-12345",
        }
        
        config = build_firebase_config(env)
        
        self.assertEqual(config["authDomain"], "custom-auth.example.com")
        self.assertEqual(config["storageBucket"], "custom-storage.example.com")
        self.assertEqual(config["measurementId"], "G-12345")

    def test_build_firebase_config_missing_required_var(self):
        """Test that missing required config raises ValueError."""
        env = {
            "FIREBASE_API_KEY": "api-key",
            "FIREBASE_PROJECT_ID": "pinchat-dev",
            # Missing FIREBASE_APP_ID and FIREBASE_MESSAGING_SENDER_ID
        }
        
        with self.assertRaises(ValueError) as context:
            build_firebase_config(env)
        
        self.assertIn("Missing required Firebase configuration", str(context.exception))
        self.assertIn("FIREBASE_APP_ID", str(context.exception))

    def test_validate_firebase_config_delegates_to_build(self):
        """Test that validate function uses build_firebase_config."""
        env = {
            "FIREBASE_API_KEY": "api-key",
            "FIREBASE_PROJECT_ID": "pinchat-dev",
            "FIREBASE_APP_ID": "1:123:web:456",
            "FIREBASE_MESSAGING_SENDER_ID": "123",
        }
        
        config = validate_firebase_config(env)
        self.assertIsNotNone(config)
        self.assertEqual(config["projectId"], "pinchat-dev")


if __name__ == "__main__":
    unittest.main()
