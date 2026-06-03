from uuid import UUID
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Turma, Matricula, HistoricoConsulta
from app.schemas import RelatorioTurma, TurmaOut, HistoricoOut
from app.services.indicadores import calcular_indicador_aluno
from app.schemas import IndicadorAluno

router = APIRouter(prefix="/relatorios", tags=["Relatorios"])


@router.get("/turma/{turma_id}", response_model=RelatorioTurma)
def relatorio_turma(
    turma_id: UUID,
    disciplina_id: Optional[UUID] = Query(None),
    db: Session = Depends(get_db),
):
    turma = db.query(Turma).filter(Turma.id == turma_id).first()
    if not turma:
        raise HTTPException(status_code=404, detail="Turma nao encontrada")

    matriculas = db.query(Matricula).filter(
        Matricula.turma_id == turma_id,
        Matricula.status == "ativo",
    ).all()

    indicadores = [
        IndicadorAluno(**calcular_indicador_aluno(m.aluno, turma_id, disciplina_id, db))
        for m in matriculas
        if m.aluno
    ]

    medias = [i.media_geral for i in indicadores if i.media_geral is not None]
    freqs = [i.percentual_frequencia for i in indicadores if i.percentual_frequencia is not None]
    dist_risco = {"baixo": 0, "medio": 0, "alto": 0, "critico": 0}
    for i in indicadores:
        dist_risco[i.nivel_risco] += 1

    historico = HistoricoConsulta(
        tipo="relatorio_turma",
        descricao=f"Relatorio gerado para turma {turma.nome}",
        entidade="turmas",
        entidade_id=turma_id,
    )
    db.add(historico)
    db.commit()

    return RelatorioTurma(
        turma=TurmaOut.model_validate(turma),
        total_alunos=len(matriculas),
        media_geral=round(sum(medias) / len(medias), 2) if medias else None,
        media_frequencia=round(sum(freqs) / len(freqs), 2) if freqs else None,
        indicadores_alunos=indicadores,
        distribuicao_risco=dist_risco,
    )


@router.get("/historico", response_model=list[HistoricoOut])
def listar_historico(
    tipo: Optional[str] = Query(None),
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
):
    q = db.query(HistoricoConsulta).order_by(HistoricoConsulta.created_at.desc())
    if tipo:
        q = q.filter(HistoricoConsulta.tipo == tipo)
    return q.offset(skip).limit(limit).all()
