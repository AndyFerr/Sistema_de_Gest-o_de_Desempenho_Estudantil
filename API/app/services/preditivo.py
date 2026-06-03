from uuid import UUID
from typing import Literal
from sqlalchemy.orm import Session

from app.models import Avaliacao
from app.services.indicadores import calcular_media_ponderada, classificar_risco


def _media_por_periodo(avaliacoes: list[Avaliacao], periodo: str) -> float | None:
    subset = [a for a in avaliacoes if a.periodo == periodo]
    return calcular_media_ponderada(subset)


def prever_desempenho(
    aluno_id: UUID,
    nome: str,
    turma_id: UUID,
    db: Session,
) -> dict:
    avaliacoes = db.query(Avaliacao).filter(
        Avaliacao.aluno_id == aluno_id,
        Avaliacao.turma_id == turma_id,
    ).all()

    media_atual = calcular_media_ponderada(avaliacoes)

    # Separar periodos para detectar tendencia
    periodos = sorted({a.periodo for a in avaliacoes if a.periodo})
    tendencia: Literal["melhora", "estavel", "queda"] = "estavel"
    prob_aprovacao = 0.5

    if len(periodos) >= 2:
        media_anterior = _media_por_periodo(avaliacoes, periodos[-2])
        media_recente = _media_por_periodo(avaliacoes, periodos[-1])
        if media_anterior is not None and media_recente is not None:
            diff = media_recente - media_anterior
            if diff > 0.5:
                tendencia = "melhora"
            elif diff < -0.5:
                tendencia = "queda"
    elif media_atual is not None:
        # Sem historico suficiente: estima pela media atual
        tendencia = "estavel"

    # Probabilidade simples de aprovacao (nota minima = 5.0)
    if media_atual is None:
        prob_aprovacao = 0.5
    elif media_atual >= 7.0:
        prob_aprovacao = 0.95
    elif media_atual >= 5.0:
        base = 0.5 + (media_atual - 5.0) / 2.0 * 0.45
        ajuste = 0.05 if tendencia == "melhora" else (-0.05 if tendencia == "queda" else 0.0)
        prob_aprovacao = round(min(0.95, max(0.05, base + ajuste)), 2)
    else:
        base = max(0.05, media_atual / 5.0 * 0.45)
        ajuste = 0.05 if tendencia == "melhora" else (-0.05 if tendencia == "queda" else 0.0)
        prob_aprovacao = round(min(0.95, max(0.05, base + ajuste)), 2)

    nivel, _ = classificar_risco(media_atual, None, 0)

    recomendacoes = {
        "critico": "Intervencao imediata: contato com responsavel, plano de recuperacao urgente.",
        "alto": "Agendar atendimento individual e acompanhar semanalmente.",
        "medio": "Monitorar evolucao e oferecer suporte adicional nas disciplinas criticas.",
        "baixo": "Manter acompanhamento regular. Desempenho dentro do esperado.",
    }

    return {
        "aluno_id": aluno_id,
        "nome": nome,
        "media_atual": media_atual,
        "tendencia": tendencia,
        "probabilidade_aprovacao": prob_aprovacao,
        "nivel_risco_previsto": nivel,
        "recomendacao": recomendacoes[nivel],
    }
