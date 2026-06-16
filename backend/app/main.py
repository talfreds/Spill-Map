from fastapi import FastAPI, Request
from starlette.middleware.cors import CORSMiddleware
import re

from .middleware import FirebaseAuthMiddleware
from .routes.spill import router as spill_router

app = FastAPI(title="Spill Backend", version="0.1.0")

# CORS middleware: dynamically allow localhost and GitHub Codespaces origins
def get_allowed_origins():
    """Generate list of allowed origins for CORS."""
    allowed = [
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "http://localhost:8000",
        "http://127.0.0.1:8000",
    ]
    
    # For GitHub Codespaces: accept any *.app.github.dev origin
    # This supports any Codespace instance automatically
    return allowed

def is_origin_allowed(origin: str) -> bool:
    """Check if origin is allowed, including pattern matching for Codespaces."""
    allowed = get_allowed_origins()
    
    # Exact match
    if origin in allowed:
        return True
    
    # Pattern match for GitHub Codespaces (*.app.github.dev)
    if re.match(r'https?://[\w-]+\.app\.github\.dev(:\d+)?$', origin):
        return True
    
    return False

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r'(http|https)://(localhost|127\.0\.0\.1|[\w-]+\.app\.github\.dev)(:\d+)?',
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(FirebaseAuthMiddleware)
app.include_router(spill_router)


@app.get("/health")
async def health_check() -> dict[str, str]:
    return {"status": "ok"}
