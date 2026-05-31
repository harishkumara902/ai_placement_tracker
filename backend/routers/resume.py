from io import BytesIO

from docx import Document
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from pypdf import PdfReader

from agents.resume_agent import ResumeAgent
from database import User
from models.schemas import ResumeRequest, ResumeResult
from routers.auth import get_current_user


router = APIRouter(prefix="/resume", tags=["Resume"])
agent = ResumeAgent()


def extract_resume_text(raw: bytes, content_type: str) -> str:
    try:
        if content_type == "application/pdf":
            return "\n".join(page.extract_text() or "" for page in PdfReader(BytesIO(raw)).pages)
        if content_type == "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
            return "\n".join(paragraph.text for paragraph in Document(BytesIO(raw)).paragraphs)
        return raw.decode("utf-8", errors="ignore")
    except Exception as exc:
        raise HTTPException(status_code=400, detail="The uploaded document could not be read") from exc


@router.post("/analyze", response_model=ResumeResult)
def analyze_resume(payload: ResumeRequest, _: User = Depends(get_current_user)):
    return agent.analyze(payload)


@router.post("/analyze-file", response_model=ResumeResult)
async def analyze_resume_file(
    dream_company: str = Form(...),
    target_role: str = Form(...),
    file: UploadFile = File(...),
    _: User = Depends(get_current_user),
):
    if file.content_type not in {"application/pdf", "application/vnd.openxmlformats-officedocument.wordprocessingml.document", "text/plain"}:
        raise HTTPException(status_code=400, detail="Upload a PDF, DOCX, or TXT resume")
    raw = await file.read()
    extracted = extract_resume_text(raw, file.content_type)
    if len(extracted.strip()) < 20:
        raise HTTPException(status_code=400, detail="No readable resume text was found in this document")
    return agent.analyze(ResumeRequest(resume_text=extracted, dream_company=dream_company, target_role=target_role))
