from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class CreateSpillRequest(BaseModel):
    lat: float = Field(ge=-90, le=90)
    lng: float = Field(ge=-180, le=180)
    message: str = Field(min_length=1, max_length=2000)
    image_url: str | None = None


class SpillResponse(BaseModel):
    spill_id: str
    user_id: str
    lat: float
    lng: float
    message: str
    image_url: str | None = None
    timestamp: datetime | None


class CreateSpillCommentRequest(BaseModel):
    message: str = Field(min_length=1, max_length=2000)


class SpillCommentResponse(BaseModel):
    comment_id: str
    spill_id: str
    user_id: str
    message: str
    timestamp: datetime | None
