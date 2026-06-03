from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Turma
from app.schemas import TurmaCreate, TurmaOut, TurmaUpdate

router = APIRouter(prefix="/turmas", tags=["Turmas"])


@router.get("/", response_model=list[TurmaOut])
def listar_turmas(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(Turma).offset(skip).limit(limit).all()


@router.get("/{turma_id}", response_model=TurmaOut)
def obter_turma(turma_id: UUID, db: Session = Depends(get_db)):
    turma = db.query(Turma).filter(Turma.id == turma_id).first()
    if not turma:
        raise HTTPException(status_code=404, detail="Turma nao encontrada")
    return turma


@router.post("/", response_model=TurmaOut, status_code=status.HTTP_201_CREATED)
def criar_turma(body: TurmaCreate, db: Session = Depends(get_db)):
    turma = Turma(**body.model_dump())
    db.add(turma)
    db.commit()
    db.refresh(turma)
    return turma


@router.put("/{turma_id}", response_model=TurmaOut)
def atualizar_turma(turma_id: UUID, body: TurmaUpdate, db: Session = Depends(get_db)):
    turma = db.query(Turma).filter(Turma.id == turma_id).first()
    if not turma:
        raise HTTPException(status_code=404, detail="Turma nao encontrada")
    for campo, valor in body.model_dump(exclude_none=True).items():
        setattr(turma, campo, valor)
    db.commit()
    db.refresh(turma)
    return turma


@router.delete("/{turma_id}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_turma(turma_id: UUID, db: Session = Depends(get_db)):
    turma = db.query(Turma).filter(Turma.id == turma_id).first()
    if not turma:
        raise HTTPException(status_code=404, detail="Turma nao encontrada")
    db.delete(turma)
    db.commit()
