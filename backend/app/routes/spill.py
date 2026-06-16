from __future__ import annotations

from datetime import UTC, datetime

from fastapi import APIRouter, HTTPException, Request
from firebase_admin.firestore import SERVER_TIMESTAMP

from ..firebase import get_firestore_client
from ..models import CreateSpillRequest, SpillResponse

router = APIRouter(prefix="/spill", tags=["spill"])

SPILLS_COLLECTION = "spills"
SPILL_COMMENTS_COLLECTION = "spill_comments"


@router.post("/create", response_model=SpillResponse)
async def create_spill(payload: CreateSpillRequest, request: Request) -> SpillResponse:
    user_id = getattr(request.state, "user_id", None)
    if not user_id:
        raise HTTPException(status_code=401, detail="Unauthenticated request")

    db = get_firestore_client()
    spill_ref = db.collection(SPILLS_COLLECTION).document()

    spill_doc = {
        "lat": payload.lat,
        "lng": payload.lng,
        "message": payload.message,
        "image_url": payload.image_url,
        "user_id": user_id,
        "timestamp": SERVER_TIMESTAMP,
    }

    spill_ref.set(spill_doc)

    return SpillResponse(
        spill_id=spill_ref.id,
        user_id=user_id,
        lat=payload.lat,
        lng=payload.lng,
        message=payload.message,
        image_url=payload.image_url,
        timestamp=datetime.now(tz=UTC),
    )
