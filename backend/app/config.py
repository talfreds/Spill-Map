from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    firebase_service_account_path: str | None = Field(
        default=None,
        alias="FIREBASE_SERVICE_ACCOUNT_PATH",
    )
    firestore_database_id: str = Field(default="(default)", alias="FIRESTORE_DATABASE_ID")
    anonymous_user_salt: str = Field(default="spill-anon", alias="ANONYMOUS_USER_SALT")

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()
