/*
  # Sistema de Gestao do Desempenho Estudantil - Schema Inicial

  ## Descricao
  Cria todas as tabelas necessarias para o sistema de acompanhamento academico,
  incluindo alunos, turmas, disciplinas, notas, frequencia, atividades e historico.

  ## Novas Tabelas
  1. `turmas` - Turmas/grupos de estudantes (nome, periodo, ano, curso)
  2. `disciplinas` - Disciplinas/materias (nome, codigo, carga_horaria)
  3. `alunos` - Cadastro de estudantes (nome, matricula, email, data_nascimento)
  4. `turma_disciplinas` - Relacao turma x disciplina com professor responsavel
  5. `matriculas` - Vinculo aluno x turma (status: ativo/inativo/trancado)
  6. `avaliacoes` - Notas dos alunos por disciplina (nota 0-10, tipo, peso)
  7. `frequencias` - Registros de presenca por aula
  8. `atividades` - Atividades/tarefas da disciplina com prazo
  9. `entregas_atividades` - Entregas dos alunos (entregue, nota, data)
  10. `historico_consultas` - Log de auditoria do sistema

  ## Seguranca
  - RLS habilitado em todas as tabelas
  - Politicas de leitura e escrita para usuarios autenticados
*/

-- Turmas
CREATE TABLE IF NOT EXISTS turmas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  periodo text NOT NULL,
  ano integer NOT NULL DEFAULT EXTRACT(YEAR FROM now()),
  curso text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE turmas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read turmas"
  ON turmas FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert turmas"
  ON turmas FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update turmas"
  ON turmas FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete turmas"
  ON turmas FOR DELETE
  TO authenticated
  USING (true);

-- Disciplinas
CREATE TABLE IF NOT EXISTS disciplinas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  codigo text UNIQUE,
  carga_horaria integer,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE disciplinas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read disciplinas"
  ON disciplinas FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert disciplinas"
  ON disciplinas FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update disciplinas"
  ON disciplinas FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete disciplinas"
  ON disciplinas FOR DELETE
  TO authenticated
  USING (true);

-- Alunos
CREATE TABLE IF NOT EXISTS alunos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  matricula text UNIQUE NOT NULL,
  email text,
  data_nascimento date,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE alunos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read alunos"
  ON alunos FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert alunos"
  ON alunos FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update alunos"
  ON alunos FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete alunos"
  ON alunos FOR DELETE
  TO authenticated
  USING (true);

-- Relacao Turma x Disciplina
CREATE TABLE IF NOT EXISTS turma_disciplinas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  turma_id uuid NOT NULL REFERENCES turmas(id) ON DELETE CASCADE,
  disciplina_id uuid NOT NULL REFERENCES disciplinas(id) ON DELETE CASCADE,
  professor_nome text,
  created_at timestamptz DEFAULT now(),
  UNIQUE(turma_id, disciplina_id)
);

ALTER TABLE turma_disciplinas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read turma_disciplinas"
  ON turma_disciplinas FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert turma_disciplinas"
  ON turma_disciplinas FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update turma_disciplinas"
  ON turma_disciplinas FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete turma_disciplinas"
  ON turma_disciplinas FOR DELETE
  TO authenticated
  USING (true);

-- Matriculas
CREATE TABLE IF NOT EXISTS matriculas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  aluno_id uuid NOT NULL REFERENCES alunos(id) ON DELETE CASCADE,
  turma_id uuid NOT NULL REFERENCES turmas(id) ON DELETE CASCADE,
  data_matricula date DEFAULT CURRENT_DATE,
  status text NOT NULL DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo', 'trancado')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(aluno_id, turma_id)
);

ALTER TABLE matriculas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read matriculas"
  ON matriculas FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert matriculas"
  ON matriculas FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update matriculas"
  ON matriculas FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete matriculas"
  ON matriculas FOR DELETE
  TO authenticated
  USING (true);

-- Avaliacoes (Notas)
CREATE TABLE IF NOT EXISTS avaliacoes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  aluno_id uuid NOT NULL REFERENCES alunos(id) ON DELETE CASCADE,
  disciplina_id uuid NOT NULL REFERENCES disciplinas(id) ON DELETE CASCADE,
  turma_id uuid NOT NULL REFERENCES turmas(id) ON DELETE CASCADE,
  tipo text NOT NULL DEFAULT 'prova' CHECK (tipo IN ('prova', 'trabalho', 'participacao', 'outro')),
  descricao text,
  nota numeric(4,2) NOT NULL CHECK (nota >= 0 AND nota <= 10),
  peso numeric(3,2) NOT NULL DEFAULT 1.0 CHECK (peso > 0),
  periodo text,
  data_avaliacao date DEFAULT CURRENT_DATE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE avaliacoes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read avaliacoes"
  ON avaliacoes FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert avaliacoes"
  ON avaliacoes FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update avaliacoes"
  ON avaliacoes FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete avaliacoes"
  ON avaliacoes FOR DELETE
  TO authenticated
  USING (true);

-- Frequencias
CREATE TABLE IF NOT EXISTS frequencias (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  aluno_id uuid NOT NULL REFERENCES alunos(id) ON DELETE CASCADE,
  disciplina_id uuid NOT NULL REFERENCES disciplinas(id) ON DELETE CASCADE,
  turma_id uuid NOT NULL REFERENCES turmas(id) ON DELETE CASCADE,
  data_aula date NOT NULL,
  presente boolean NOT NULL DEFAULT true,
  created_at timestamptz DEFAULT now(),
  UNIQUE(aluno_id, disciplina_id, data_aula)
);

ALTER TABLE frequencias ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read frequencias"
  ON frequencias FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert frequencias"
  ON frequencias FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update frequencias"
  ON frequencias FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete frequencias"
  ON frequencias FOR DELETE
  TO authenticated
  USING (true);

-- Atividades
CREATE TABLE IF NOT EXISTS atividades (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  titulo text NOT NULL,
  descricao text,
  disciplina_id uuid NOT NULL REFERENCES disciplinas(id) ON DELETE CASCADE,
  turma_id uuid NOT NULL REFERENCES turmas(id) ON DELETE CASCADE,
  data_entrega date,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE atividades ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read atividades"
  ON atividades FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert atividades"
  ON atividades FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update atividades"
  ON atividades FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete atividades"
  ON atividades FOR DELETE
  TO authenticated
  USING (true);

-- Entregas de Atividades
CREATE TABLE IF NOT EXISTS entregas_atividades (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  atividade_id uuid NOT NULL REFERENCES atividades(id) ON DELETE CASCADE,
  aluno_id uuid NOT NULL REFERENCES alunos(id) ON DELETE CASCADE,
  entregue boolean NOT NULL DEFAULT false,
  data_entrega timestamptz,
  nota numeric(4,2) CHECK (nota >= 0 AND nota <= 10),
  observacao text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(atividade_id, aluno_id)
);

ALTER TABLE entregas_atividades ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read entregas_atividades"
  ON entregas_atividades FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert entregas_atividades"
  ON entregas_atividades FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update entregas_atividades"
  ON entregas_atividades FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete entregas_atividades"
  ON entregas_atividades FOR DELETE
  TO authenticated
  USING (true);

-- Historico de Consultas (Auditoria)
CREATE TABLE IF NOT EXISTS historico_consultas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tipo text NOT NULL,
  descricao text,
  entidade text,
  entidade_id uuid,
  usuario text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE historico_consultas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read historico_consultas"
  ON historico_consultas FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert historico_consultas"
  ON historico_consultas FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Indexes para performance
CREATE INDEX IF NOT EXISTS idx_avaliacoes_aluno ON avaliacoes(aluno_id);
CREATE INDEX IF NOT EXISTS idx_avaliacoes_disciplina ON avaliacoes(disciplina_id);
CREATE INDEX IF NOT EXISTS idx_avaliacoes_turma ON avaliacoes(turma_id);
CREATE INDEX IF NOT EXISTS idx_frequencias_aluno ON frequencias(aluno_id);
CREATE INDEX IF NOT EXISTS idx_frequencias_disciplina ON frequencias(disciplina_id);
CREATE INDEX IF NOT EXISTS idx_matriculas_aluno ON matriculas(aluno_id);
CREATE INDEX IF NOT EXISTS idx_matriculas_turma ON matriculas(turma_id);
CREATE INDEX IF NOT EXISTS idx_entregas_aluno ON entregas_atividades(aluno_id);
CREATE INDEX IF NOT EXISTS idx_entregas_atividade ON entregas_atividades(atividade_id);
