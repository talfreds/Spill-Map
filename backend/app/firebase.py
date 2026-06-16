from __future__ import annotations

import firebase_admin
from firebase_admin import auth, credentials, firestore

from .config import settings


def initialize_firebase() -> firebase_admin.App:
    if firebase_admin._apps:
        return firebase_admin.get_app()

    if settings.firebase_service_account_path:
        cred = credentials.Certificate(settings.firebase_service_account_path)
        return firebase_admin.initialize_app(cred)

    cred = credentials.ApplicationDefault()
    return firebase_admin.initialize_app(cred)


def get_firestore_client() -> firestore.Client:
    initialize_firebase()
    return firestore.client(database_id=settings.firestore_database_id)


def verify_id_token(id_token: str) -> dict:
    initialize_firebase()
    return auth.verify_id_token(id_token)
