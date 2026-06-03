from uuid import UUID
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Matricula, TurmaDisciplina
from app.schemas import MatriculaCreate, MatriculaOut, MatriculaUpdate, TurmaDisciplinaCreate, TurmaDisciplinaOut

router = APIRouter(tags=["Matriculas e Vinculos"])


# ── Matriculas ─────────────────────────────────────────────────────────────────

@router.get("/matriculas", response_model=list[MatriculaOut])
def listar_matriculas(
    aluno_id: Optional[UUID] = Query(None),
    turma_id: Optional[UUID] = Query(None),
    status: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    q = db.query(Matricula)
    if aluno_id:
        q = q.filter(Matricula.aluno_id == aluno_id)
    if turma_id:
        q = q.filter(Matricula.turma_id == turma_id)
    if status:
        q = q.filter(Matricula.status == status)
    return q.all()


@router.post("/matriculas", response_model=MatriculaOut, status_code=201)
def matricular_aluno(body: MatriculaCreate, db: Session = Depends(get_db)):
    existente = db.query(Matricula).filter(
        Matricula.aluno_id == body.aluno_id,
        Matricula.turma_id == body.turma_id,
    ).first()
    if existente:
        raise HTTPException(status_code=409, detail="Aluno ja matriculado nesta turma")
    m = Matricula(**body.model_dump())
    db.add(m)
    db.commit()
    db.refresh(m)
    return m


@router.put("/matriculas/{matricula_id}", response_model=MatriculaOut)
def atualizar_matricula(matricula_id: UUID, body: MatriculaUpdate, db: Session = Depends(get_db)):
    m = db.query(Matricula).filter(Matricula.id == matricula_id).first()
    if not m:
        raise HTTPException(status_code=404, detail="Matricula nao encontrada")
    m.status = body.status
    db.commit()
    db.refresh(m)
    return m


@router.delete("/matriculas/{matricula_id}", status_code=204)
def cancelar_matricula(matricula_id: UUID, db: Session = Depends(get_db)):
    m = db.query(Matricula).filter(Matricula.id == matricula_id).first()
    if not m:
        raise HTTPException(status_code=404, detail="Matricula nao encontrada")
    db.delete(m)
    db.commit()


# ── Turma x Disciplina ─────────────────────────────────────────────────────────

@router.get("/turma-disciplinas", response_model=list[TurmaDisciplinaOut])
def listar_turma_disciplinas(
    turma_id: Optional[UUID] = Query(None),
    disciplina_id: Optional[UUID] = Query(None),
    db: Session = Depends(get_db),
):
    q = db.query(TurmaDisciplina)
    if turma_id:
        q = q.filter(TurmaDisciplina.turma_id == turma_id)
    if disciplina_id:
        q = q.filter(TurmaDisciplina.disciplina_id == disciplina_id)
    return q.all()


@router.post("/turma-disciplinas", response_model=TurmaDisciplinaOut, status_code=201)
def vincular_disciplina(body: TurmaDisciplinaCreate, db: Session = Depends(get_db)):
    existente = db.query(TurmaDisciplina).filter(
        TurmaDisciplina.turma_id == body.turma_id,
        TurmaDisciplina.disciplina_id == body.disciplina_id,
    ).first()
    if existente:
        raise HTTPException(status_code=409, detail="Disciplina ja vinculada a esta turma")
    td = TurmaDisciplina(**body.model_dump())
    db.add(td)
    db.commit()
    db.refresh(td)
    return td


@router.delete("/turma-disciplinas/{td_id}", status_code=204)
def desvincular_disciplina(td_id: UUID, db: Session = Depends(get_db)):
    td = db.query(TurmaDisciplina).filter(TurmaDisciplina.id == td_id).first()
    if not td:
        raise HTTPException(status_code=404, detail="Vinculo nao encontrado")
    db.delete(td)
    db.commit()
