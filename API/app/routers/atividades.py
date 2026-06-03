from uuid import UUID
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Atividade, EntregaAtividade
from app.schemas import (
    AtividadeCreate, AtividadeOut, AtividadeUpdate,
    EntregaCreate, EntregaOut, EntregaUpdate,
)

router = APIRouter(tags=["Atividades"])


# ── Atividades ─────────────────────────────────────────────────────────────────

@router.get("/atividades", response_model=list[AtividadeOut])
def listar_atividades(
    turma_id: Optional[UUID] = Query(None),
    disciplina_id: Optional[UUID] = Query(None),
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
):
    q = db.query(Atividade)
    if turma_id:
        q = q.filter(Atividade.turma_id == turma_id)
    if disciplina_id:
        q = q.filter(Atividade.disciplina_id == disciplina_id)
    return q.offset(skip).limit(limit).all()


@router.get("/atividades/{atividade_id}", response_model=AtividadeOut)
def obter_atividade(atividade_id: UUID, db: Session = Depends(get_db)):
    a = db.query(Atividade).filter(Atividade.id == atividade_id).first()
    if not a:
        raise HTTPException(status_code=404, detail="Atividade nao encontrada")
    return a


@router.post("/atividades", response_model=AtividadeOut, status_code=status.HTTP_201_CREATED)
def criar_atividade(body: AtividadeCreate, db: Session = Depends(get_db)):
    a = Atividade(**body.model_dump())
    db.add(a)
    db.commit()
    db.refresh(a)
    return a


@router.put("/atividades/{atividade_id}", response_model=AtividadeOut)
def atualizar_atividade(atividade_id: UUID, body: AtividadeUpdate, db: Session = Depends(get_db)):
    a = db.query(Atividade).filter(Atividade.id == atividade_id).first()
    if not a:
        raise HTTPException(status_code=404, detail="Atividade nao encontrada")
    for campo, valor in body.model_dump(exclude_none=True).items():
        setattr(a, campo, valor)
    db.commit()
    db.refresh(a)
    return a


@router.delete("/atividades/{atividade_id}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_atividade(atividade_id: UUID, db: Session = Depends(get_db)):
    a = db.query(Atividade).filter(Atividade.id == atividade_id).first()
    if not a:
        raise HTTPException(status_code=404, detail="Atividade nao encontrada")
    db.delete(a)
    db.commit()


# ── Entregas ───────────────────────────────────────────────────────────────────

@router.get("/entregas", response_model=list[EntregaOut])
def listar_entregas(
    aluno_id: Optional[UUID] = Query(None),
    atividade_id: Optional[UUID] = Query(None),
    skip: int = 0,
    limit: int = 200,
    db: Session = Depends(get_db),
):
    q = db.query(EntregaAtividade)
    if aluno_id:
        q = q.filter(EntregaAtividade.aluno_id == aluno_id)
    if atividade_id:
        q = q.filter(EntregaAtividade.atividade_id == atividade_id)
    return q.offset(skip).limit(limit).all()


@router.post("/entregas", response_model=EntregaOut, status_code=status.HTTP_201_CREATED)
def registrar_entrega(body: EntregaCreate, db: Session = Depends(get_db)):
    existente = db.query(EntregaAtividade).filter(
        EntregaAtividade.atividade_id == body.atividade_id,
        EntregaAtividade.aluno_id == body.aluno_id,
    ).first()
    if existente:
        raise HTTPException(status_code=409, detail="Entrega ja registrada para este aluno")
    e = EntregaAtividade(**body.model_dump())
    db.add(e)
    db.commit()
    db.refresh(e)
    return e


@router.put("/entregas/{entrega_id}", response_model=EntregaOut)
def atualizar_entrega(entrega_id: UUID, body: EntregaUpdate, db: Session = Depends(get_db)):
    e = db.query(EntregaAtividade).filter(EntregaAtividade.id == entrega_id).first()
    if not e:
        raise HTTPException(status_code=404, detail="Entrega nao encontrada")
    for campo, valor in body.model_dump(exclude_none=True).items():
        setattr(e, campo, valor)
    db.commit()
    db.refresh(e)
    return e


@router.delete("/entregas/{entrega_id}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_entrega(entrega_id: UUID, db: Session = Depends(get_db)):
    e = db.query(EntregaAtividade).filter(EntregaAtividade.id == entrega_id).first()
    if not e:
        raise HTTPException(status_code=404, detail="Entrega nao encontrada")
    db.delete(e)
    db.commit()
