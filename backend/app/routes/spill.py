from __future__ import annotations

from datetime import UTC, datetime

from fastapi import APIRouter, HTTPException, Request
from firebase_admin.firestore import SERVER_TIMESTAMP

from ..firebase import get_firestore_client
from ..models import (
    CreateSpillCommentRequest,
    CreateSpillRequest,
    SpillCommentResponse,
    SpillResponse,
)

router = APIRouter(prefix="/spill", tags=["spill"])

SPILLS_COLLECTION = "spills"
SPILL_COMMENTS_COLLECTION = "spill_comments"


@router.post("/create", response_model=SpillResponse)
async def create_spill(payload: CreateSpillRequest, request: Request) -> SpillResponse:
    user_id = _resolve_user_id(request)

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


@router.post("/{spill_id}/comments", response_model=SpillCommentResponse)
async def create_spill_comment(
    spill_id: str,
    payload: CreateSpillCommentRequest,
    request: Request,
) -> SpillCommentResponse:
    user_id = _resolve_user_id(request)

    db = get_firestore_client()
    spill_ref = db.collection(SPILLS_COLLECTION).document(spill_id)

    if not spill_ref.get().exists:
        raise HTTPException(status_code=404, detail="Spill not found")

    comment_ref = db.collection(SPILL_COMMENTS_COLLECTION).document()
    comment_ref.set(
        {
            "spill_id": spill_id,
            "user_id": user_id,
            "message": payload.message,
            "timestamp": SERVER_TIMESTAMP,
        }
    )

    return SpillCommentResponse(
        comment_id=comment_ref.id,
        spill_id=spill_id,
        user_id=user_id,
        message=payload.message,
        timestamp=datetime.now(tz=UTC),
    )


def _resolve_user_id(request: Request) -> str:
    user_id = getattr(request.state, "user_id", None)
    if user_id:
        return user_id

    anonymous_user_id = getattr(request.state, "anonymous_user_id", None)
    if anonymous_user_id:
        return anonymous_user_id

    raise HTTPException(status_code=500, detail="Could not resolve request identity")
