from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware
import os

from .middleware import FirebaseAuthMiddleware
from .routes.spill import router as spill_router

app = FastAPI(title="Spill Backend", version="0.1.0")

def get_cors_config():
    """Get CORS configuration from environment or defaults.
    
    Production: Set ALLOWED_ORIGINS env var (comma-separated list)
    Development: Auto-detect localhost and *.app.github.dev origins
    """
    allowed_origins_env = os.getenv('ALLOWED_ORIGINS', '')
    
    # Production: explicit allowed origins
    if allowed_origins_env.strip():
        return {
            'allow_origins': [o.strip() for o in allowed_origins_env.split(',')],
        }
    
    # Development: auto-detect with regex for localhost and Codespaces
    return {
        'allow_origin_regex': r'^https?://([a-zA-Z0-9\-]+\.app\.github\.dev|localhost|127\.0\.0\.1)(:\d+)?$',
    }

cors_config = get_cors_config()

# Add auth middleware first, then CORS so CORS wraps all responses,
# including early error responses returned by auth middleware.
app.add_middleware(FirebaseAuthMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    **cors_config,
)
app.include_router(spill_router)


@app.get("/health")
async def health_check() -> dict[str, str]:
    return {"status": "ok"}
