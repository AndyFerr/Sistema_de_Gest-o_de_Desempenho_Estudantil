# Sistema de Gestão do Desempenho Estudantil

Uma API REST desenvolvida em FastAPI para acompanhamento acadêmico com indicadores de desempenho, alertas de risco e previsões preditivas para professores e gestores.

## Visão Geral

O sistema centraliza informações acadêmicas (notas, frequência, atividades, participação) e apresenta:
- **Indicadores de desempenho** por aluno, turma e disciplina
- **Classificação de risco acadêmico** com 4 níveis (baixo, médio, alto, crítico)
- **Previsões de desempenho** e tendências
- **Relatórios consolidados** para tomada de decisão

Ideal para professores, coordenadores pedagógicos e gestores academicos identificarem antecipadamente estudantes com dificuldades e planejarem intervenções.

## Arquitetura

```
┌─────────────────────┐
│  Cliente (Browser)  │
└──────────┬──────────┘
           │
    ┌──────▼──────────────────────────┐
    │      FastAPI REST API           │
    │  ├─ Routers CRUD                │
    │  ├─ Serviços (Indicadores)      │
    │  └─ Modulo Preditivo            │
    └──────┬──────────────────────────┘
           │
    ┌──────▼──────────────────────────┐
    │  SQLAlchemy ORM                 │
    │  (Pydantic Schemas)             │
    └──────┬──────────────────────────┘
           │
    ┌──────▼──────────────────────────┐
    │      PostgreSQL/Supabase        │
    │  ├─ Turmas, Disciplinas, Alunos │
    │  ├─ Matriculas, Avaliacoes      │
    │  ├─ Frequencias, Atividades     │
    │  └─ Entregas, Historico         │
    └─────────────────────────────────┘
```

## Tecnologias

- **FastAPI** — Framework web assíncrono
- **SQLAlchemy** — ORM para banco de dados
- **Pydantic** — Validação de schemas
- **PostgreSQL** — Banco de dados (via Supabase)
- **Python 3.8+**

## Instalação

### 1. Clonar e instalar dependências

```bash
cd project
pip install -r requirements.txt
```

### 2. Configurar variáveis de ambiente

Criar arquivo `.env`:
```env
DATABASE_URL=postgresql://user:password@host:5432/database
# ou
SUPABASE_DB_URL=postgresql://user:password@db.supabase.co:5432/postgres
```

### 3. Executar o servidor

```bash
uvicorn app.main:app --reload
```

Servidor estará disponível em `http://localhost:8000`

**Documentação interativa:**
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

---

## Estrutura do Projeto

```
app/
├── __init__.py
├── main.py                  # Entrada FastAPI
├── database.py              # Conexão e sessão SQLAlchemy
├── models.py                # Modelos SQLAlchemy
├── schemas.py               # Schemas Pydantic
├── routers/
│   ├── alunos.py           # CRUD de alunos
│   ├── turmas.py           # CRUD de turmas
│   ├── disciplinas.py      # CRUD de disciplinas
│   ├── matriculas.py       # Matriculas e vinculos turma-disciplina
│   ├── notas.py            # Avaliações (notas)
│   ├── frequencia.py       # Registros de presença
│   ├── atividades.py       # Atividades e entregas
│   ├── dashboard.py        # Indicadores e métricas
│   └── relatorios.py       # Relatórios consolidados
└── services/
    ├── indicadores.py      # Cálculo de métricas
    └── preditivo.py        # Previsão e classificação de risco
```

---

## Endpoints

### Gerenciamento Base

#### Turmas
```
GET    /turmas                 # Listar turmas
POST   /turmas                 # Criar turma
GET    /turmas/{turma_id}      # Obter turma
PUT    /turmas/{turma_id}      # Atualizar turma
DELETE /turmas/{turma_id}      # Deletar turma
```

#### Disciplinas
```
GET    /disciplinas            # Listar disciplinas
POST   /disciplinas            # Criar disciplina
GET    /disciplinas/{id}       # Obter disciplina
PUT    /disciplinas/{id}       # Atualizar disciplina
DELETE /disciplinas/{id}       # Deletar disciplina
```

#### Alunos
```
GET    /alunos                 # Listar alunos
POST   /alunos                 # Cadastrar aluno
GET    /alunos/{aluno_id}      # Obter aluno
PUT    /alunos/{aluno_id}      # Atualizar aluno
DELETE /alunos/{aluno_id}      # Deletar aluno
```

### Acadêmico

#### Matriculas
```
GET    /matriculas                    # Listar com filtros
POST   /matriculas                    # Matricular aluno
PUT    /matriculas/{matricula_id}     # Atualizar status
DELETE /matriculas/{matricula_id}     # Cancelar matricula

GET    /turma-disciplinas             # Listar vinculos
POST   /turma-disciplinas             # Vincular disciplina a turma
DELETE /turma-disciplinas/{id}        # Desvincular
```

#### Notas (Avaliacoes)
```
GET    /notas                  # Listar com filtros
       ?aluno_id=...
       ?turma_id=...
       ?disciplina_id=...
       ?periodo=...
POST   /notas                  # Registrar nota
GET    /notas/{avaliacao_id}   # Obter nota
PUT    /notas/{avaliacao_id}   # Atualizar nota
DELETE /notas/{avaliacao_id}   # Deletar nota
```

#### Frequência
```
GET    /frequencia             # Listar com filtros
       ?aluno_id=...
       ?turma_id=...
       ?data_inicio=...
       ?data_fim=...
POST   /frequencia             # Registrar presença
POST   /frequencia/batch       # Registrar em lote
PUT    /frequencia/{id}        # Atualizar presença
DELETE /frequencia/{id}        # Deletar registro
```

#### Atividades
```
GET    /atividades             # Listar atividades
POST   /atividades             # Criar atividade
GET    /atividades/{id}        # Obter atividade
PUT    /atividades/{id}        # Atualizar atividade
DELETE /atividades/{id}        # Deletar atividade

GET    /entregas               # Listar entregas com filtros
POST   /entregas               # Registrar entrega
PUT    /entregas/{id}          # Atualizar entrega
DELETE /entregas/{id}          # Deletar entrega
```

### Dashboard e Indicadores

#### Indicadores por Contexto
```
GET /dashboard/turma/{turma_id}
    # Retorna:
    # - Total de alunos
    # - Média geral da turma
    # - Média de frequência
    # - Distribuição de risco (baixo/médio/alto/crítico)
    # - Alunos em risco alto/crítico

GET /dashboard/aluno/{aluno_id}?turma_id=...
    # Retorna:
    # - Nome, matrícula
    # - Média geral
    # - Percentual de frequência
    # - Atividades pendentes
    # - Nível de risco com justificativa

GET /dashboard/disciplina/{disciplina_id}?turma_id=...
    # Retorna:
    # - Média de notas
    # - Média de frequência
    # - Total de avaliações

GET /dashboard/risco?turma_id=...&nivel_minimo=alto
    # Retorna lista de alunos em risco (filtrável por nível)
```

#### Previsão de Desempenho
```
GET /dashboard/previsao/{aluno_id}?turma_id=...
    # Retorna:
    # - Média atual
    # - Tendência (melhora/estável/queda)
    # - Probabilidade de aprovação
    # - Nível de risco previsto
    # - Recomendação de intervenção

GET /dashboard/previsao/turma/{turma_id}
    # Retorna previsões para todos os alunos da turma
```

### Relatórios

```
GET /relatorios/turma/{turma_id}
    # Relatório consolidado com:
    # - Dados da turma
    # - Total de alunos
    # - Médias (geral e por aluno)
    # - Distribuição de risco
    # - Indicadores individuais

GET /relatorios/historico?tipo=...
    # Histórico de consultas e auditoria
```

---

## Exemplos de Uso

### 1. Criar turma e disciplina

```bash
# Criar turma
curl -X POST http://localhost:8000/turmas \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "2º Ano A",
    "periodo": "matutino",
    "ano": 2024,
    "curso": "Ensino Médio"
  }'

# Criar disciplina
curl -X POST http://localhost:8000/disciplinas \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Matemática",
    "codigo": "MAT001",
    "carga_horaria": 80
  }'
```

### 2. Matricular aluno

```bash
# Cadastrar aluno
ALUNO_ID=$(curl -X POST http://localhost:8000/alunos \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "matricula": "2024001",
    "email": "joao@escola.edu",
    "data_nascimento": "2006-05-15"
  }' | jq -r '.id')

# Matricular em turma
curl -X POST http://localhost:8000/matriculas \
  -H "Content-Type: application/json" \
  -d "{
    \"aluno_id\": \"$ALUNO_ID\",
    \"turma_id\": \"TURMA_UUID\",
    \"status\": \"ativo\"
  }"
```

### 3. Registrar avaliações

```bash
curl -X POST http://localhost:8000/notas \
  -H "Content-Type: application/json" \
  -d '{
    "aluno_id": "ALUNO_UUID",
    "disciplina_id": "DISCIPLINA_UUID",
    "turma_id": "TURMA_UUID",
    "tipo": "prova",
    "descricao": "Prova de Matemática - Bimestre 1",
    "nota": 8.5,
    "peso": 2.0,
    "periodo": "Bimestre 1",
    "data_avaliacao": "2024-05-10"
  }'
```

### 4. Consultar alunos em risco

```bash
curl "http://localhost:8000/dashboard/risco?turma_id=TURMA_UUID&nivel_minimo=alto"
```

Resposta (exemplo):
```json
[
  {
    "aluno_id": "...",
    "nome": "Maria Santos",
    "matricula": "2024015",
    "media_geral": 4.2,
    "percentual_frequencia": 65.0,
    "atividades_pendentes": 2,
    "nivel_risco": "critico",
    "justificativa_risco": "media 4.2 abaixo de 4.0; frequencia 65.0% abaixo de 60%"
  }
]
```

### 5. Gerar previsão

```bash
curl "http://localhost:8000/dashboard/previsao/ALUNO_UUID?turma_id=TURMA_UUID"
```

Resposta (exemplo):
```json
{
  "aluno_id": "...",
  "nome": "Pedro Costa",
  "media_atual": 5.8,
  "tendencia": "melhora",
  "probabilidade_aprovacao": 0.72,
  "nivel_risco_previsto": "medio",
  "recomendacao": "Monitorar evolução e oferecer suporte adicional nas disciplinas críticas."
}
```

---

## Lógica de Classificação de Risco

Baseada nas regras da Seção 23 do Plano de Projeto:

| Nível | Critério | Ação Sugerida |
|-------|----------|---------------|
| **CRÍTICO** | Média < 4.0 OU Frequência < 60% OU ≥3 atividades pendentes | Intervenção imediata; contato com responsável; plano de recuperação urgente |
| **ALTO** | Média < 5.0 OU Frequência 60-74% | Agendar atendimento individual; acompanhar semanalmente |
| **MÉDIO** | Média 5.0-6.9 OU atividades pendentes | Monitorar evolução; oferecer suporte adicional |
| **BAIXO** | Média ≥ 7.0 E Frequência ≥ 75% | Acompanhamento regular; desempenho esperado |

---

## Segurança

- **RLS (Row Level Security):** Habilitado em todas as tabelas
- **Políticas de Acesso:** Usuários autenticados podem acessar dados academicos
- **CORS:** Habilitado para todos os domínios (configurável)
- **Validação:** Schemas Pydantic validam toda entrada

**Para produção, recomenda-se:**
- Restringir CORS a domínios específicos
- Implementar autenticação JWT/OAuth
- Adicionar rate limiting
- Usar HTTPS obrigatoriamente

---

## Modelos de Dados

### Aluno
```python
{
  "id": "uuid",
  "nome": "string",
  "matricula": "string (único)",
  "email": "string",
  "data_nascimento": "date"
}
```

### Turma
```python
{
  "id": "uuid",
  "nome": "string",
  "periodo": "string",
  "ano": "integer",
  "curso": "string"
}
```

### Avaliacao (Nota)
```python
{
  "id": "uuid",
  "aluno_id": "uuid",
  "disciplina_id": "uuid",
  "turma_id": "uuid",
  "tipo": "prova | trabalho | participacao | outro",
  "nota": "0.00 - 10.00",
  "peso": "> 0",
  "periodo": "string",
  "data_avaliacao": "date"
}
```

### Frequencia
```python
{
  "id": "uuid",
  "aluno_id": "uuid",
  "disciplina_id": "uuid",
  "turma_id": "uuid",
  "data_aula": "date",
  "presente": "boolean"
}
```

---

## Contribuindo

1. Criar branch: `git checkout -b feature/nova-funcionalidade`
2. Fazer commit: `git commit -m "Adicionar nova funcionalidade"`
3. Fazer push: `git push origin feature/nova-funcionalidade`
4. Abrir Pull Request

---

## Licença

Projeto acadêmico — Equipe Sigma (2024)

---

## Suporte

Para dúvidas, abrir issue ou contatar a equipe de desenvolvimento.

**Status:** ✅ API funcional com testes em produção local
