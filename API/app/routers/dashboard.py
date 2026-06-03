from uuid import UUID
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import Aluno, Turma, Disciplina, Matricula, Avaliacao, Frequencia
from app.schemas import (
    IndicadorAluno, IndicadorTurma, IndicadorDisciplina, PrevisaoDesempenho,
)
from app.services.indicadores import (
    calcular_indicador_aluno,
    calcular_media_ponderada,
    calcular_percentual_frequencia,
)
from app.services.preditivo import prever_desempenho

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])


@router.get("/turma/{turma_id}", response_model=IndicadorTurma)
def dashboard_turma(
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
        calcular_indicador_aluno(m.aluno, turma_id, disciplina_id, db)
        for m in matriculas
        if m.aluno
    ]

    medias = [i["media_geral"] for i in indicadores if i["media_geral"] is not None]
    freqs = [i["percentual_frequencia"] for i in indicadores if i["percentual_frequencia"] is not None]

    dist_risco = {"baixo": 0, "medio": 0, "alto": 0, "critico": 0}
    for i in indicadores:
        dist_risco[i["nivel_risco"]] += 1

    return IndicadorTurma(
        turma_id=turma_id,
        nome_turma=turma.nome,
        total_alunos=len(matriculas),
        media_turma=round(sum(medias) / len(medias), 2) if medias else None,
        media_frequencia=round(sum(freqs) / len(freqs), 2) if freqs else None,
        alunos_risco_alto=dist_risco["alto"],
        alunos_risco_critico=dist_risco["critico"],
        distribuicao_risco=dist_risco,
    )


@router.get("/aluno/{aluno_id}", response_model=IndicadorAluno)
def dashboard_aluno(
    aluno_id: UUID,
    turma_id: UUID = Query(..., description="ID da turma do aluno"),
    disciplina_id: Optional[UUID] = Query(None),
    db: Session = Depends(get_db),
):
    aluno = db.query(Aluno).filter(Aluno.id == aluno_id).first()
    if not aluno:
        raise HTTPException(status_code=404, detail="Aluno nao encontrado")

    dados = calcular_indicador_aluno(aluno, turma_id, disciplina_id, db)
    return IndicadorAluno(**dados)


@router.get("/disciplina/{disciplina_id}", response_model=IndicadorDisciplina)
def dashboard_disciplina(
    disciplina_id: UUID,
    turma_id: Optional[UUID] = Query(None),
    db: Session = Depends(get_db),
):
    disciplina = db.query(Disciplina).filter(Disciplina.id == disciplina_id).first()
    if not disciplina:
        raise HTTPException(status_code=404, detail="Disciplina nao encontrada")

    filtro_av = [Avaliacao.disciplina_id == disciplina_id]
    filtro_fr = [Frequencia.disciplina_id == disciplina_id]
    if turma_id:
        filtro_av.append(Avaliacao.turma_id == turma_id)
        filtro_fr.append(Frequencia.turma_id == turma_id)

    avaliacoes = db.query(Avaliacao).filter(*filtro_av).all()
    frequencias = db.query(Frequencia).filter(*filtro_fr).all()

    return IndicadorDisciplina(
        disciplina_id=disciplina_id,
        nome_disciplina=disciplina.nome,
        media_notas=calcular_media_ponderada(avaliacoes),
        media_frequencia=calcular_percentual_frequencia(frequencias),
        total_avaliacoes=len(avaliacoes),
    )


@router.get("/risco", response_model=list[IndicadorAluno])
def alunos_em_risco(
    turma_id: UUID = Query(...),
    nivel_minimo: str = Query("alto", description="Nivel minimo: baixo, medio, alto, critico"),
    db: Session = Depends(get_db),
):
    niveis_ordem = ["baixo", "medio", "alto", "critico"]
    if nivel_minimo not in niveis_ordem:
        raise HTTPException(status_code=400, detail="nivel_minimo invalido")

    idx_minimo = niveis_ordem.index(nivel_minimo)

    matriculas = db.query(Matricula).filter(
        Matricula.turma_id == turma_id,
        Matricula.status == "ativo",
    ).all()

    resultado = []
    for m in matriculas:
        if not m.aluno:
            continue
        dados = calcular_indicador_aluno(m.aluno, turma_id, None, db)
        if niveis_ordem.index(dados["nivel_risco"]) >= idx_minimo:
            resultado.append(IndicadorAluno(**dados))

    resultado.sort(key=lambda x: niveis_ordem.index(x.nivel_risco), reverse=True)
    return resultado


@router.get("/previsao/{aluno_id}", response_model=PrevisaoDesempenho)
def previsao_aluno(
    aluno_id: UUID,
    turma_id: UUID = Query(...),
    db: Session = Depends(get_db),
):
    aluno = db.query(Aluno).filter(Aluno.id == aluno_id).first()
    if not aluno:
        raise HTTPException(status_code=404, detail="Aluno nao encontrado")

    dados = prever_desempenho(aluno_id, aluno.nome, turma_id, db)
    return PrevisaoDesempenho(**dados)


@router.get("/previsao/turma/{turma_id}", response_model=list[PrevisaoDesempenho])
def previsao_turma(turma_id: UUID, db: Session = Depends(get_db)):
    matriculas = db.query(Matricula).filter(
        Matricula.turma_id == turma_id,
        Matricula.status == "ativo",
    ).all()

    return [
        PrevisaoDesempenho(**prever_desempenho(m.aluno.id, m.aluno.nome, turma_id, db))
        for m in matriculas
        if m.aluno
    ]
