from __future__ import annotations

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse

from .firebase import verify_id_token


class FirebaseAuthMiddleware(BaseHTTPMiddleware):
    """Validates Firebase ID tokens for write operations."""

    async def dispatch(self, request: Request, call_next):
        if request.method in {"POST", "PUT", "PATCH", "DELETE"}:
            auth_header = request.headers.get("Authorization", "")
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
                return JSONResponse(status_code=401, content={"detail": "Invalid Firebase ID token"})

        return await call_next(request)
