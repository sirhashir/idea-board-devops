import os
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import text

import models
import schemas
from database import engine, get_db, Base

Base.metadata.create_all(bind=engine) #for tables if they dont exist

app = FastAPI(title="Idea Board API")

origins  = os.environ.get("CORS_ORIGINS", "*").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/ideas", response_model=list[schemas.IdeaResponse])
def get_ideas(db: Session=Depends(get_db)):
    return db.query(models.Idea).order_by(models.Idea.created_at.desc()).all()

@app.post("/api/ideas", response_model=schemas.IdeaResponse, status_code=201)
def create_idea(idea: schemas.IdeaCreate, db: Session = Depends(get_db)):
    db_idea = models.Idea(content = idea.content)
    db.add(db_idea)
    db.commit()
    db.refresh(db_idea)
    return db_idea
