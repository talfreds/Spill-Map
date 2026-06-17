from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


ROOT_ENV_FILE = str(Path(__file__).resolve().parents[2] / ".env")


class Settings(BaseSettings):
    firebase_service_account_path: str | None = Field(
        default=None,
        alias="FIREBASE_SERVICE_ACCOUNT_PATH",
    )
    firestore_database_id: str = Field(default="(default)", alias="FIRESTORE_DATABASE_ID")
    anonymous_user_salt: str = Field(default="spill-anon", alias="ANONYMOUS_USER_SALT")
    oci_object_storage_namespace: str | None = Field(
        default=None,
        alias="OCI_OBJECT_STORAGE_NAMESPACE",
    )
    oci_object_storage_bucket: str | None = Field(
        default=None,
        alias="OCI_OBJECT_STORAGE_BUCKET",
    )
    oci_object_storage_region: str | None = Field(
        default=None,
        alias="OCI_OBJECT_STORAGE_REGION",
    )
    oci_object_storage_access_key: str | None = Field(
        default=None,
        alias="OCI_OBJECT_STORAGE_ACCESS_KEY",
    )
    oci_object_storage_secret_key: str | None = Field(
        default=None,
        alias="OCI_OBJECT_STORAGE_SECRET_KEY",
    )
    oci_object_storage_public_base_url: str | None = Field(
        default=None,
        alias="OCI_OBJECT_STORAGE_PUBLIC_BASE_URL",
    )
    oci_object_storage_url_expiry_seconds: int = Field(
        default=900,
        alias="OCI_OBJECT_STORAGE_URL_EXPIRY_SECONDS",
    )

    model_config = SettingsConfigDict(
        env_file=ROOT_ENV_FILE,
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
