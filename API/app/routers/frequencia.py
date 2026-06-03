from uuid import UUID
from typing import Optional
from datetime import date
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Frequencia
from app.schemas import FrequenciaCreate, FrequenciaOut, FrequenciaUpdate

router = APIRouter(prefix="/frequencia", tags=["Frequencia"])


@router.get("/", response_model=list[FrequenciaOut])
def listar_frequencias(
    aluno_id: Optional[UUID] = Query(None),
    turma_id: Optional[UUID] = Query(None),
    disciplina_id: Optional[UUID] = Query(None),
    data_inicio: Optional[date] = Query(None),
    data_fim: Optional[date] = Query(None),
    skip: int = 0,
    limit: int = 500,
    db: Session = Depends(get_db),
):
    q = db.query(Frequencia)
    if aluno_id:
        q = q.filter(Frequencia.aluno_id == aluno_id)
    if turma_id:
        q = q.filter(Frequencia.turma_id == turma_id)
    if disciplina_id:
        q = q.filter(Frequencia.disciplina_id == disciplina_id)
    if data_inicio:
        q = q.filter(Frequencia.data_aula >= data_inicio)
    if data_fim:
        q = q.filter(Frequencia.data_aula <= data_fim)
    return q.offset(skip).limit(limit).all()


@router.get("/{frequencia_id}", response_model=FrequenciaOut)
def obter_frequencia(frequencia_id: UUID, db: Session = Depends(get_db)):
    f = db.query(Frequencia).filter(Frequencia.id == frequencia_id).first()
    if not f:
        raise HTTPException(status_code=404, detail="Registro de frequencia nao encontrado")
    return f


@router.post("/", response_model=FrequenciaOut, status_code=status.HTTP_201_CREATED)
def registrar_frequencia(body: FrequenciaCreate, db: Session = Depends(get_db)):
    existente = db.query(Frequencia).filter(
        Frequencia.aluno_id == body.aluno_id,
        Frequencia.disciplina_id == body.disciplina_id,
        Frequencia.data_aula == body.data_aula,
    ).first()
    if existente:
        raise HTTPException(status_code=409, detail="Frequencia ja registrada para este aluno nesta data")
    f = Frequencia(**body.model_dump())
    db.add(f)
    db.commit()
    db.refresh(f)
    return f


@router.post("/batch", response_model=list[FrequenciaOut], status_code=status.HTTP_201_CREATED)
def registrar_frequencias_batch(registros: list[FrequenciaCreate], db: Session = Depends(get_db)):
    criados = []
    for body in registros:
        existente = db.query(Frequencia).filter(
            Frequencia.aluno_id == body.aluno_id,
            Frequencia.disciplina_id == body.disciplina_id,
            Frequencia.data_aula == body.data_aula,
        ).first()
        if existente:
            existente.presente = body.presente
            criados.append(existente)
        else:
            f = Frequencia(**body.model_dump())
            db.add(f)
            criados.append(f)
    db.commit()
    for f in criados:
        db.refresh(f)
    return criados


@router.put("/{frequencia_id}", response_model=FrequenciaOut)
def atualizar_frequencia(frequencia_id: UUID, body: FrequenciaUpdate, db: Session = Depends(get_db)):
    f = db.query(Frequencia).filter(Frequencia.id == frequencia_id).first()
    if not f:
        raise HTTPException(status_code=404, detail="Registro de frequencia nao encontrado")
    f.presente = body.presente
    db.commit()
    db.refresh(f)
    return f


@router.delete("/{frequencia_id}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_frequencia(frequencia_id: UUID, db: Session = Depends(get_db)):
    f = db.query(Frequencia).filter(Frequencia.id == frequencia_id).first()
    if not f:
        raise HTTPException(status_code=404, detail="Registro de frequencia nao encontrado")
    db.delete(f)
    db.commit()
