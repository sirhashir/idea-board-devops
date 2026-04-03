from datetime import datetime
from pydantic import BaseModel, field_validator


class IdeaCreate(BaseModel):
    content: str

    @field_validator("content")
    @classmethod
    def content_must_not_be_empty(cls, v):
        if not v.strip():
            raise ValueError("Content cannot be empty or whitespace")
        if len(v.strip()) > 1000:
            raise ValueError("Content cannot exceed 1000 characters")
        return v.strip()


class IdeaResponse(BaseModel):
    id: int
    content: str
    created_at: datetime

    model_config = {"from_attributes": True}