from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import (
    alunos, turmas, disciplinas, notas,
    frequencia, atividades, matriculas,
    dashboard, relatorios,
)

app = FastAPI(
    title="Sistema de Gestao do Desempenho Estudantil",
    description=(
        "API para acompanhamento academico com indicadores de desempenho, "
        "alertas de risco e previsoes preditivas para professores e gestores."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(turmas.router)
app.include_router(disciplinas.router)
app.include_router(alunos.router)
app.include_router(matriculas.router)
app.include_router(notas.router)
app.include_router(frequencia.router)
app.include_router(atividades.router)
app.include_router(dashboard.router)
app.include_router(relatorios.router)


@app.get("/", tags=["Status"])
def health_check():
    return {"status": "ok", "sistema": "Gestao do Desempenho Estudantil"}
