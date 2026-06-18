from __future__ import annotations

import hashlib

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse

from .config import settings
from .firebase import verify_id_token


class FirebaseAuthMiddleware(BaseHTTPMiddleware):
    """Attaches Firebase or anonymous identities to write operations."""

    async def dispatch(self, request: Request, call_next):
        if request.method in {"POST", "PUT", "PATCH", "DELETE"}:
            auth_header = request.headers.get("Authorization", "")
            if auth_header:
                if not auth_header.startswith("Bearer "):
                    return JSONResponse(
                        status_code=401,
                        content={"detail": "Missing or invalid Authorization header"},
                    )

                id_token = auth_header.split(" ", 1)[1].strip()
                if not id_token:
                    return JSONResponse(status_code=401, content={"detail": "Missing ID token"})

                try:
                    decoded = verify_id_token(id_token)
                    request.state.user_id = decoded.get("uid")
                except Exception:
                    return JSONResponse(
                        status_code=401,
                        content={"detail": "Invalid Firebase ID token"},
                    )

            request.state.anonymous_user_id = _build_anonymous_user_id(request)

        return await call_next(request)


def _build_anonymous_user_id(request: Request) -> str:
    forwarded_for = request.headers.get("x-forwarded-for", "")
    if forwarded_for:
        client_ip = forwarded_for.split(",", 1)[0].strip()
    else:
        client_ip = request.client.host if request.client else "unknown"

    digest = hashlib.sha256(
        f"{settings.anonymous_user_salt}:{client_ip}".encode("utf-8")
    ).hexdigest()[:12]
    return f"anonymous-{digest}"
