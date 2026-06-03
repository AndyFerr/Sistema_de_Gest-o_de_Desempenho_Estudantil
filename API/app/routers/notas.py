from uuid import UUID
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Avaliacao, Matricula, TurmaDisciplina
from app.schemas import AvaliacaoCreate, AvaliacaoOut, AvaliacaoUpdate

router = APIRouter(prefix="/notas", tags=["Notas"])


@router.get("/", response_model=list[AvaliacaoOut])
def listar_notas(
    aluno_id: Optional[UUID] = Query(None),
    turma_id: Optional[UUID] = Query(None),
    disciplina_id: Optional[UUID] = Query(None),
    periodo: Optional[str] = Query(None),
    skip: int = 0,
    limit: int = 200,
    db: Session = Depends(get_db),
):
    q = db.query(Avaliacao)
    if aluno_id:
        q = q.filter(Avaliacao.aluno_id == aluno_id)
    if turma_id:
        q = q.filter(Avaliacao.turma_id == turma_id)
    if disciplina_id:
        q = q.filter(Avaliacao.disciplina_id == disciplina_id)
    if periodo:
        q = q.filter(Avaliacao.periodo == periodo)
    return q.offset(skip).limit(limit).all()


@router.get("/{avaliacao_id}", response_model=AvaliacaoOut)
def obter_nota(avaliacao_id: UUID, db: Session = Depends(get_db)):
    av = db.query(Avaliacao).filter(Avaliacao.id == avaliacao_id).first()
    if not av:
        raise HTTPException(status_code=404, detail="Avaliacao nao encontrada")
    return av


@router.post("/", response_model=AvaliacaoOut, status_code=status.HTTP_201_CREATED)
def registrar_nota(body: AvaliacaoCreate, db: Session = Depends(get_db)):
    av = Avaliacao(**body.model_dump())
    db.add(av)
    db.commit()
    db.refresh(av)
    return av


@router.put("/{avaliacao_id}", response_model=AvaliacaoOut)
def atualizar_nota(avaliacao_id: UUID, body: AvaliacaoUpdate, db: Session = Depends(get_db)):
    av = db.query(Avaliacao).filter(Avaliacao.id == avaliacao_id).first()
    if not av:
        raise HTTPException(status_code=404, detail="Avaliacao nao encontrada")
    for campo, valor in body.model_dump(exclude_none=True).items():
        setattr(av, campo, valor)
    db.commit()
    db.refresh(av)
    return av


@router.delete("/{avaliacao_id}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_nota(avaliacao_id: UUID, db: Session = Depends(get_db)):
    av = db.query(Avaliacao).filter(Avaliacao.id == avaliacao_id).first()
    if not av:
        raise HTTPException(status_code=404, detail="Avaliacao nao encontrada")
    db.delete(av)
    db.commit()
