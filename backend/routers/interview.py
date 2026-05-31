from fastapi import APIRouter, Depends

from agents.interview_agent import InterviewAgent
from database import User
from models.schemas import InterviewEvaluationRequest, InterviewEvaluationResult, InterviewQuestion, InterviewStartRequest
from routers.auth import get_current_user


router = APIRouter(prefix="/interview", tags=["Interview"])
agent = InterviewAgent()


@router.post("/start", response_model=list[InterviewQuestion])
def start_interview(payload: InterviewStartRequest, _: User = Depends(get_current_user)):
    return agent.start(payload)


@router.post("/evaluate", response_model=InterviewEvaluationResult)
def evaluate_answer(payload: InterviewEvaluationRequest, _: User = Depends(get_current_user)):
    return agent.evaluate(payload.question, payload.answer, payload.round)
