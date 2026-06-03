from __future__ import annotations
from datetime import date, datetime
from decimal import Decimal
from typing import Literal, Optional
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


# ── Turma ──────────────────────────────────────────────────────────────────────

class TurmaCreate(BaseModel):
    nome: str
    periodo: str
    ano: int = Field(default_factory=lambda: datetime.now().year)
    curso: Optional[str] = None


class TurmaUpdate(BaseModel):
    nome: Optional[str] = None
    periodo: Optional[str] = None
    ano: Optional[int] = None
    curso: Optional[str] = None


class TurmaOut(BaseModel):
    id: UUID
    nome: str
    periodo: str
    ano: int
    curso: Optional[str]
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


# ── Disciplina ─────────────────────────────────────────────────────────────────

class DisciplinaCreate(BaseModel):
    nome: str
    codigo: Optional[str] = None
    carga_horaria: Optional[int] = None


class DisciplinaUpdate(BaseModel):
    nome: Optional[str] = None
    codigo: Optional[str] = None
    carga_horaria: Optional[int] = None


class DisciplinaOut(BaseModel):
    id: UUID
    nome: str
    codigo: Optional[str]
    carga_horaria: Optional[int]
    created_at: datetime

    model_config = {"from_attributes": True}


# ── Aluno ──────────────────────────────────────────────────────────────────────

class AlunoCreate(BaseModel):
    nome: str
    matricula: str
    email: Optional[str] = None
    data_nascimento: Optional[date] = None


class AlunoUpdate(BaseModel):
    nome: Optional[str] = None
    email: Optional[str] = None
    data_nascimento: Optional[date] = None


class AlunoOut(BaseModel):
    id: UUID
    nome: str
    matricula: str
    email: Optional[str]
    data_nascimento: Optional[date]
    created_at: datetime

    model_config = {"from_attributes": True}


# ── TurmaDisciplina ────────────────────────────────────────────────────────────

class TurmaDisciplinaCreate(BaseModel):
    turma_id: UUID
    disciplina_id: UUID
    professor_nome: Optional[str] = None


class TurmaDisciplinaOut(BaseModel):
    id: UUID
    turma_id: UUID
    disciplina_id: UUID
    professor_nome: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}


# ── Matricula ──────────────────────────────────────────────────────────────────

class MatriculaCreate(BaseModel):
    aluno_id: UUID
    turma_id: UUID
    data_matricula: Optional[date] = None
    status: Literal["ativo", "inativo", "trancado"] = "ativo"


class MatriculaUpdate(BaseModel):
    status: Literal["ativo", "inativo", "trancado"]


class MatriculaOut(BaseModel):
    id: UUID
    aluno_id: UUID
    turma_id: UUID
    data_matricula: Optional[date]
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}


# ── Avaliacao ──────────────────────────────────────────────────────────────────

class AvaliacaoCreate(BaseModel):
    aluno_id: UUID
    disciplina_id: UUID
    turma_id: UUID
    tipo: Literal["prova", "trabalho", "participacao", "outro"] = "prova"
    descricao: Optional[str] = None
    nota: Decimal = Field(ge=0, le=10)
    peso: Decimal = Field(default=Decimal("1.0"), gt=0)
    periodo: Optional[str] = None
    data_avaliacao: Optional[date] = None


class AvaliacaoUpdate(BaseModel):
    nota: Optional[Decimal] = Field(default=None, ge=0, le=10)
    peso: Optional[Decimal] = Field(default=None, gt=0)
    descricao: Optional[str] = None
    periodo: Optional[str] = None


class AvaliacaoOut(BaseModel):
    id: UUID
    aluno_id: UUID
    disciplina_id: UUID
    turma_id: UUID
    tipo: str
    descricao: Optional[str]
    nota: Decimal
    peso: Decimal
    periodo: Optional[str]
    data_avaliacao: Optional[date]
    created_at: datetime

    model_config = {"from_attributes": True}


# ── Frequencia ─────────────────────────────────────────────────────────────────

class FrequenciaCreate(BaseModel):
    aluno_id: UUID
    disciplina_id: UUID
    turma_id: UUID
    data_aula: date
    presente: bool = True


class FrequenciaUpdate(BaseModel):
    presente: bool


class FrequenciaOut(BaseModel):
    id: UUID
    aluno_id: UUID
    disciplina_id: UUID
    turma_id: UUID
    data_aula: date
    presente: bool
    created_at: datetime

    model_config = {"from_attributes": True}


# ── Atividade ──────────────────────────────────────────────────────────────────

class AtividadeCreate(BaseModel):
    titulo: str
    descricao: Optional[str] = None
    disciplina_id: UUID
    turma_id: UUID
    data_entrega: Optional[date] = None


class AtividadeUpdate(BaseModel):
    titulo: Optional[str] = None
    descricao: Optional[str] = None
    data_entrega: Optional[date] = None


class AtividadeOut(BaseModel):
    id: UUID
    titulo: str
    descricao: Optional[str]
    disciplina_id: UUID
    turma_id: UUID
    data_entrega: Optional[date]
    created_at: datetime

    model_config = {"from_attributes": True}


# ── EntregaAtividade ───────────────────────────────────────────────────────────

class EntregaCreate(BaseModel):
    atividade_id: UUID
    aluno_id: UUID
    entregue: bool = False
    data_entrega: Optional[datetime] = None
    nota: Optional[Decimal] = Field(default=None, ge=0, le=10)
    observacao: Optional[str] = None


class EntregaUpdate(BaseModel):
    entregue: Optional[bool] = None
    data_entrega: Optional[datetime] = None
    nota: Optional[Decimal] = Field(default=None, ge=0, le=10)
    observacao: Optional[str] = None


class EntregaOut(BaseModel):
    id: UUID
    atividade_id: UUID
    aluno_id: UUID
    entregue: bool
    data_entrega: Optional[datetime]
    nota: Optional[Decimal]
    observacao: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}


# ── Historico ──────────────────────────────────────────────────────────────────

class HistoricoOut(BaseModel):
    id: UUID
    tipo: str
    descricao: Optional[str]
    entidade: Optional[str]
    entidade_id: Optional[UUID]
    usuario: Optional[str]
    created_at: datetime

    model_config = {"from_attributes": True}


# ── Dashboard / Indicadores ────────────────────────────────────────────────────

class IndicadorAluno(BaseModel):
    aluno_id: UUID
    nome: str
    matricula: str
    media_geral: Optional[float]
    percentual_frequencia: Optional[float]
    atividades_pendentes: int
    nivel_risco: Literal["baixo", "medio", "alto", "critico"]
    justificativa_risco: str


class IndicadorTurma(BaseModel):
    turma_id: UUID
    nome_turma: str
    total_alunos: int
    media_turma: Optional[float]
    media_frequencia: Optional[float]
    alunos_risco_alto: int
    alunos_risco_critico: int
    distribuicao_risco: dict


class IndicadorDisciplina(BaseModel):
    disciplina_id: UUID
    nome_disciplina: str
    media_notas: Optional[float]
    media_frequencia: Optional[float]
    total_avaliacoes: int


class PrevisaoDesempenho(BaseModel):
    aluno_id: UUID
    nome: str
    media_atual: Optional[float]
    tendencia: Literal["melhora", "estavel", "queda"]
    probabilidade_aprovacao: float
    nivel_risco_previsto: Literal["baixo", "medio", "alto", "critico"]
    recomendacao: str


class RelatorioTurma(BaseModel):
    turma: TurmaOut
    total_alunos: int
    media_geral: Optional[float]
    media_frequencia: Optional[float]
    indicadores_alunos: list[IndicadorAluno]
    distribuicao_risco: dict
