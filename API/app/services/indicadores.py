from uuid import UUID
from typing import Literal
from sqlalchemy.orm import Session

from app.models import Aluno, Avaliacao, Frequencia, Atividade, EntregaAtividade


def calcular_media_ponderada(avaliacoes: list[Avaliacao]) -> float | None:
    if not avaliacoes:
        return None
    total_peso = sum(float(a.peso) for a in avaliacoes)
    if total_peso == 0:
        return None
    return round(sum(float(a.nota) * float(a.peso) for a in avaliacoes) / total_peso, 2)


def calcular_percentual_frequencia(frequencias: list[Frequencia]) -> float | None:
    if not frequencias:
        return None
    total = len(frequencias)
    presentes = sum(1 for f in frequencias if f.presente)
    return round((presentes / total) * 100, 2)


def contar_atividades_pendentes(
    aluno_id: UUID,
    turma_id: UUID,
    db: Session,
) -> int:
    atividades = db.query(Atividade).filter(Atividade.turma_id == turma_id).all()
    pendentes = 0
    for at in atividades:
        entrega = db.query(EntregaAtividade).filter(
            EntregaAtividade.atividade_id == at.id,
            EntregaAtividade.aluno_id == aluno_id,
        ).first()
        if not entrega or not entrega.entregue:
            pendentes += 1
    return pendentes


def classificar_risco(
    media: float | None,
    frequencia: float | None,
    atividades_pendentes: int,
) -> tuple[Literal["baixo", "medio", "alto", "critico"], str]:
    """
    Regras conforme secao 23 do plano de projeto:
    - Critico:  media < 4.0, frequencia < 60% ou muitas atividades pendentes
    - Alto:     media < 5.0 ou frequencia entre 60-74%
    - Medio:    media entre 5.0 e 6.9 ou queda recente
    - Baixo:    media >= 7.0 e frequencia >= 75%
    """
    motivos = []

    if media is None and frequencia is None:
        return "baixo", "Sem dados suficientes para classificacao"

    # Critico
    if (media is not None and media < 4.0) or \
       (frequencia is not None and frequencia < 60.0) or \
       atividades_pendentes >= 3:
        if media is not None and media < 4.0:
            motivos.append(f"media {media:.1f} abaixo de 4.0")
        if frequencia is not None and frequencia < 60.0:
            motivos.append(f"frequencia {frequencia:.0f}% abaixo de 60%")
        if atividades_pendentes >= 3:
            motivos.append(f"{atividades_pendentes} atividades pendentes")
        return "critico", "; ".join(motivos)

    # Alto
    if (media is not None and media < 5.0) or \
       (frequencia is not None and 60.0 <= frequencia < 75.0):
        if media is not None and media < 5.0:
            motivos.append(f"media {media:.1f} abaixo de 5.0")
        if frequencia is not None and frequencia < 75.0:
            motivos.append(f"frequencia {frequencia:.0f}% abaixo de 75%")
        return "alto", "; ".join(motivos)

    # Medio
    if (media is not None and 5.0 <= media < 7.0) or atividades_pendentes >= 1:
        if media is not None and media < 7.0:
            motivos.append(f"media {media:.1f} entre 5.0 e 6.9")
        if atividades_pendentes >= 1:
            motivos.append(f"{atividades_pendentes} atividade(s) pendente(s)")
        return "medio", "; ".join(motivos)

    return "baixo", "Media >= 7.0 e frequencia >= 75%"


def calcular_indicador_aluno(
    aluno: Aluno,
    turma_id: UUID,
    disciplina_id: UUID | None,
    db: Session,
) -> dict:
    filtro_av = [Avaliacao.aluno_id == aluno.id, Avaliacao.turma_id == turma_id]
    filtro_fr = [Frequencia.aluno_id == aluno.id, Frequencia.turma_id == turma_id]
    if disciplina_id:
        filtro_av.append(Avaliacao.disciplina_id == disciplina_id)
        filtro_fr.append(Frequencia.disciplina_id == disciplina_id)

    avaliacoes = db.query(Avaliacao).filter(*filtro_av).all()
    frequencias = db.query(Frequencia).filter(*filtro_fr).all()

    media = calcular_media_ponderada(avaliacoes)
    freq = calcular_percentual_frequencia(frequencias)
    pendentes = contar_atividades_pendentes(aluno.id, turma_id, db)
    nivel, justificativa = classificar_risco(media, freq, pendentes)

    return {
        "aluno_id": aluno.id,
        "nome": aluno.nome,
        "matricula": aluno.matricula,
        "media_geral": media,
        "percentual_frequencia": freq,
        "atividades_pendentes": pendentes,
        "nivel_risco": nivel,
        "justificativa_risco": justificativa,
    }
