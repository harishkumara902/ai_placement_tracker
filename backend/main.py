from contextlib import asynccontextmanager

from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware

from agents.company_agent import CompanyAgent
from database import User, create_tables
from models.schemas import ChatRequest, ChatResponse
from rag.retriever import get_store
from routers import auth, code, company, interview, predict, resume, roadmap
from routers.auth import get_current_user
from config import settings


@asynccontextmanager
async def lifespan(_: FastAPI):
    create_tables()
    get_store()
    yield


app = FastAPI(title=settings.app_name, version="1.0.0", lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.frontend_origin, "http://127.0.0.1:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api")
app.include_router(resume.router, prefix="/api")
app.include_router(roadmap.router, prefix="/api")
app.include_router(interview.router, prefix="/api")
app.include_router(code.router, prefix="/api")
app.include_router(company.router, prefix="/api")
app.include_router(predict.router, prefix="/api")


@app.get("/api/health")
def health():
    return {"status": "healthy", "ai_provider": settings.ai_provider, "ai_enabled": settings.ai_enabled}


@app.post("/api/chat", response_model=ChatResponse)
def chat(payload: ChatRequest, _: User = Depends(get_current_user)):
    query = payload.message.lower()
    if any(term in query for term in ("company", "tcs", "infosys", "zoho", "accenture")):
        matches = CompanyAgent().retriever.search(payload.message, limit=3)
        return ChatResponse(agent="company_agent", answer="Here are relevant interview patterns from the company knowledge base.", supporting_data={"matches": matches})
    if any(term in query for term in ("resume", "ats", "cv")):
        return ChatResponse(agent="resume_agent", answer="Share your resume text and target role in Resume Analyzer for a scored ATS audit.")
    if any(term in query for term in ("interview", "hr", "technical")):
        return ChatResponse(agent="interview_agent", answer="Start a mock round to receive scored feedback and an ideal answer after every response.")
    if any(term in query for term in ("roadmap", "learn", "prepare")):
        return ChatResponse(agent="roadmap_agent", answer="Generate a week-by-week roadmap based on your company, role, and available preparation time.")
    return ChatResponse(agent="master_router", answer="I can guide your resume, roadmap, mock interviews, coding practice, company preparation, or placement probability.")
