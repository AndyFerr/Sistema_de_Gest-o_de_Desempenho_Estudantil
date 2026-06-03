from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Disciplina
from app.schemas import DisciplinaCreate, DisciplinaOut, DisciplinaUpdate

router = APIRouter(prefix="/disciplinas", tags=["Disciplinas"])


@router.get("/", response_model=list[DisciplinaOut])
def listar_disciplinas(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return db.query(Disciplina).offset(skip).limit(limit).all()


@router.get("/{disciplina_id}", response_model=DisciplinaOut)
def obter_disciplina(disciplina_id: UUID, db: Session = Depends(get_db)):
    d = db.query(Disciplina).filter(Disciplina.id == disciplina_id).first()
    if not d:
        raise HTTPException(status_code=404, detail="Disciplina nao encontrada")
    return d


@router.post("/", response_model=DisciplinaOut, status_code=status.HTTP_201_CREATED)
def criar_disciplina(body: DisciplinaCreate, db: Session = Depends(get_db)):
    if body.codigo:
        existente = db.query(Disciplina).filter(Disciplina.codigo == body.codigo).first()
        if existente:
            raise HTTPException(status_code=409, detail="Codigo de disciplina ja cadastrado")
    d = Disciplina(**body.model_dump())
    db.add(d)
    db.commit()
    db.refresh(d)
    return d


@router.put("/{disciplina_id}", response_model=DisciplinaOut)
def atualizar_disciplina(disciplina_id: UUID, body: DisciplinaUpdate, db: Session = Depends(get_db)):
    d = db.query(Disciplina).filter(Disciplina.id == disciplina_id).first()
    if not d:
        raise HTTPException(status_code=404, detail="Disciplina nao encontrada")
    for campo, valor in body.model_dump(exclude_none=True).items():
        setattr(d, campo, valor)
    db.commit()
    db.refresh(d)
    return d


@router.delete("/{disciplina_id}", status_code=status.HTTP_204_NO_CONTENT)
def deletar_disciplina(disciplina_id: UUID, db: Session = Depends(get_db)):
    d = db.query(Disciplina).filter(Disciplina.id == disciplina_id).first()
    if not d:
        raise HTTPException(status_code=404, detail="Disciplina nao encontrada")
    db.delete(d)
    db.commit()
