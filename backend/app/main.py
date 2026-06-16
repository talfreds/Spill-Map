from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware

from .middleware import FirebaseAuthMiddleware
from .routes.spill import router as spill_router

app = FastAPI(title="Spill Backend", version="0.1.0")

# CORS middleware: allow requests from localhost (dev) and production origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:8080",
        "http://127.0.0.1:8080",
        "http://localhost:8000",
        "http://127.0.0.1:8000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(FirebaseAuthMiddleware)
app.include_router(spill_router)


@app.get("/health")
async def health_check() -> dict[str, str]:
    return {"status": "ok"}
