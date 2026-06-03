from sqlalchemy import (
    Column, String, Text, Numeric, Integer, Boolean, Date,
    DateTime, ForeignKey, UniqueConstraint, CheckConstraint, func
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid

from app.database import Base


class Turma(Base):
    __tablename__ = "turmas"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nome = Column(String, nullable=False)
    periodo = Column(String, nullable=False)
    ano = Column(Integer, nullable=False)
    curso = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    matriculas = relationship("Matricula", back_populates="turma")
    turma_disciplinas = relationship("TurmaDisciplina", back_populates="turma")


class Disciplina(Base):
    __tablename__ = "disciplinas"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nome = Column(String, nullable=False)
    codigo = Column(String, unique=True)
    carga_horaria = Column(Integer)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    turma_disciplinas = relationship("TurmaDisciplina", back_populates="disciplina")


class Aluno(Base):
    __tablename__ = "alunos"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nome = Column(String, nullable=False)
    matricula = Column(String, unique=True, nullable=False)
    email = Column(String)
    data_nascimento = Column(Date)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    matriculas = relationship("Matricula", back_populates="aluno")
    avaliacoes = relationship("Avaliacao", back_populates="aluno")
    frequencias = relationship("Frequencia", back_populates="aluno")
    entregas = relationship("EntregaAtividade", back_populates="aluno")


class TurmaDisciplina(Base):
    __tablename__ = "turma_disciplinas"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    turma_id = Column(UUID(as_uuid=True), ForeignKey("turmas.id", ondelete="CASCADE"), nullable=False)
    disciplina_id = Column(UUID(as_uuid=True), ForeignKey("disciplinas.id", ondelete="CASCADE"), nullable=False)
    professor_nome = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (UniqueConstraint("turma_id", "disciplina_id"),)

    turma = relationship("Turma", back_populates="turma_disciplinas")
    disciplina = relationship("Disciplina", back_populates="turma_disciplinas")


class Matricula(Base):
    __tablename__ = "matriculas"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    aluno_id = Column(UUID(as_uuid=True), ForeignKey("alunos.id", ondelete="CASCADE"), nullable=False)
    turma_id = Column(UUID(as_uuid=True), ForeignKey("turmas.id", ondelete="CASCADE"), nullable=False)
    data_matricula = Column(Date, server_default=func.current_date())
    status = Column(String, nullable=False, default="ativo")
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        UniqueConstraint("aluno_id", "turma_id"),
        CheckConstraint("status IN ('ativo', 'inativo', 'trancado')", name="status_check"),
    )

    aluno = relationship("Aluno", back_populates="matriculas")
    turma = relationship("Turma", back_populates="matriculas")


class Avaliacao(Base):
    __tablename__ = "avaliacoes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    aluno_id = Column(UUID(as_uuid=True), ForeignKey("alunos.id", ondelete="CASCADE"), nullable=False)
    disciplina_id = Column(UUID(as_uuid=True), ForeignKey("disciplinas.id", ondelete="CASCADE"), nullable=False)
    turma_id = Column(UUID(as_uuid=True), ForeignKey("turmas.id", ondelete="CASCADE"), nullable=False)
    tipo = Column(String, nullable=False, default="prova")
    descricao = Column(Text)
    nota = Column(Numeric(4, 2), nullable=False)
    peso = Column(Numeric(3, 2), nullable=False, default=1.0)
    periodo = Column(String)
    data_avaliacao = Column(Date, server_default=func.current_date())
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    aluno = relationship("Aluno", back_populates="avaliacoes")
    disciplina = relationship("Disciplina")
    turma = relationship("Turma")


class Frequencia(Base):
    __tablename__ = "frequencias"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    aluno_id = Column(UUID(as_uuid=True), ForeignKey("alunos.id", ondelete="CASCADE"), nullable=False)
    disciplina_id = Column(UUID(as_uuid=True), ForeignKey("disciplinas.id", ondelete="CASCADE"), nullable=False)
    turma_id = Column(UUID(as_uuid=True), ForeignKey("turmas.id", ondelete="CASCADE"), nullable=False)
    data_aula = Column(Date, nullable=False)
    presente = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (UniqueConstraint("aluno_id", "disciplina_id", "data_aula"),)

    aluno = relationship("Aluno", back_populates="frequencias")
    disciplina = relationship("Disciplina")
    turma = relationship("Turma")


class Atividade(Base):
    __tablename__ = "atividades"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    titulo = Column(String, nullable=False)
    descricao = Column(Text)
    disciplina_id = Column(UUID(as_uuid=True), ForeignKey("disciplinas.id", ondelete="CASCADE"), nullable=False)
    turma_id = Column(UUID(as_uuid=True), ForeignKey("turmas.id", ondelete="CASCADE"), nullable=False)
    data_entrega = Column(Date)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    disciplina = relationship("Disciplina")
    turma = relationship("Turma")
    entregas = relationship("EntregaAtividade", back_populates="atividade")


class EntregaAtividade(Base):
    __tablename__ = "entregas_atividades"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    atividade_id = Column(UUID(as_uuid=True), ForeignKey("atividades.id", ondelete="CASCADE"), nullable=False)
    aluno_id = Column(UUID(as_uuid=True), ForeignKey("alunos.id", ondelete="CASCADE"), nullable=False)
    entregue = Column(Boolean, nullable=False, default=False)
    data_entrega = Column(DateTime(timezone=True))
    nota = Column(Numeric(4, 2))
    observacao = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    __table_args__ = (UniqueConstraint("atividade_id", "aluno_id"),)

    atividade = relationship("Atividade", back_populates="entregas")
    aluno = relationship("Aluno", back_populates="entregas")


class HistoricoConsulta(Base):
    __tablename__ = "historico_consultas"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    tipo = Column(String, nullable=False)
    descricao = Column(Text)
    entidade = Column(String)
    entidade_id = Column(UUID(as_uuid=True))
    usuario = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
