from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Aluno
from app.schemas import AlunoCreate, AlunoOut, AlunoUpdate

router = APIRouter(prefix="/alunos", tags=["Alunos"])


@router.get("/", response_model=list[AlunoOut])
def listar_alunos(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(Aluno).offset(skip).limit(limit).all()


@router.get("/{aluno_id}", response_model=AlunoOut)
def obter_aluno(aluno_id: UUID, db: Session = Depends(get_db)):
    aluno = db.query(Aluno).filter(Aluno.id == aluno_id).first()
    if not aluno:
        raise HTTPException(status_code=404, detail="Aluno nao encontrado")
    return aluno


@router.post("/", response_model=AlunoOut, status_code=status.HTTP_201_CREATED)
def criar_aluno(body: AlunoCreate, db: Session = Depends(get_db)):
    existente = db.query(Aluno).filter(Aluno.matricula == body.matricula).first()
    if existente:
        raise HTTPException(status_code=409, detail="Matricula ja cadastrada")
    aluno = Aluno(**body.model_dump())
    db.add(aluno)
    db.commit()
    db.refresh(aluno)
    return aluno


@router.put("/{aluno_id}", response_model=AlunoOut)
def atualizar_aluno(aluno_id: UUID, body: AlunoUpdate, db: Session = Depends(get_db)):
    aluno = db.query(Aluno).filter(Aluno.id == aluno_id).first()
    if not aluno:
        raise HTTPException(status_code=404, detail="Aluno nao encontrado")
    for campo, valor in body.model_dump(exclude_none=True).items():
        setattr(aluno, campo, valor)
    db.commit()
    db.refresh(aluno)
    return aluno


@router.delete("/{aluno_id}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_aluno(aluno_id: UUID, db: Session = Depends(get_db)):
    aluno = db.query(Aluno).filter(Aluno.id == aluno_id).first()
    if not aluno:
        raise HTTPException(status_code=404, detail="Aluno nao encontrado")
    db.delete(aluno)
    db.commit()
