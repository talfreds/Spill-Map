from __future__ import annotations

import re
import time
from dataclasses import dataclass
from urllib.parse import quote

import boto3
from botocore.client import BaseClient
from fastapi import HTTPException

from .config import settings


@dataclass
class PresignedUpload:
    upload_url: str
    public_url: str
    object_key: str
    expires_in_seconds: int


def build_presigned_upload_for_user(*, user_id: str, file_name: str, content_type: str) -> PresignedUpload:
    if not content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image uploads are allowed")

    _validate_oci_config()

    safe_file_name = _sanitize_filename(file_name)
    object_key = f"spill_images/{user_id}/{int(time.time() * 1000)}_{safe_file_name}"

    client = _build_s3_client()
    expires_in = settings.oci_object_storage_url_expiry_seconds

    upload_url = client.generate_presigned_url(
        ClientMethod="put_object",
        Params={
            "Bucket": settings.oci_object_storage_bucket,
            "Key": object_key,
            "ContentType": content_type,
        },
        ExpiresIn=expires_in,
    )

    public_url = _build_public_url(object_key)
    return PresignedUpload(
        upload_url=upload_url,
        public_url=public_url,
        object_key=object_key,
        expires_in_seconds=expires_in,
    )


def _validate_oci_config() -> None:
    required = {
        "OCI_OBJECT_STORAGE_NAMESPACE": settings.oci_object_storage_namespace,
        "OCI_OBJECT_STORAGE_BUCKET": settings.oci_object_storage_bucket,
        "OCI_OBJECT_STORAGE_REGION": settings.oci_object_storage_region,
        "OCI_OBJECT_STORAGE_ACCESS_KEY": settings.oci_object_storage_access_key,
        "OCI_OBJECT_STORAGE_SECRET_KEY": settings.oci_object_storage_secret_key,
    }

    missing = [name for name, value in required.items() if not value]
    if missing:
        raise HTTPException(
            status_code=503,
            detail=(
                "OCI Object Storage is not configured. Missing: "
                + ", ".join(missing)
            ),
        )


def _build_s3_client() -> BaseClient:
    endpoint = _oci_endpoint_url()
    return boto3.client(
        "s3",
        endpoint_url=endpoint,
        aws_access_key_id=settings.oci_object_storage_access_key,
        aws_secret_access_key=settings.oci_object_storage_secret_key,
        region_name=settings.oci_object_storage_region,
    )


def _oci_endpoint_url() -> str:
    return (
        f"https://{settings.oci_object_storage_namespace}.compat.objectstorage."
        f"{settings.oci_object_storage_region}.oraclecloud.com"
    )


def _build_public_url(object_key: str) -> str:
    quoted_key = quote(object_key, safe="/")

    if settings.oci_object_storage_public_base_url:
        base = settings.oci_object_storage_public_base_url.rstrip("/")
        return f"{base}/{quoted_key}"

    endpoint = _oci_endpoint_url()
    bucket = settings.oci_object_storage_bucket
    return f"{endpoint}/{bucket}/{quoted_key}"


def _sanitize_filename(file_name: str) -> str:
    normalized = file_name.strip().replace(" ", "_")
    normalized = re.sub(r"[^A-Za-z0-9._-]", "", normalized)
    if not normalized:
        return "upload.jpg"
    return normalized[:120]
