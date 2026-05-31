from fastapi import APIRouter, Depends

from agents.technical_agent import TechnicalAgent
from database import User
from models.schemas import CodeExplanationRequest, CodeRunRequest
from routers.auth import get_current_user


router = APIRouter(prefix="/code", tags=["Coding Arena"])
agent = TechnicalAgent()


@router.get("/problems")
def problems(_: User = Depends(get_current_user)):
    return agent.problems


@router.post("/run")
def run_code(payload: CodeRunRequest, _: User = Depends(get_current_user)):
    return agent.run_code(payload.problem_id, payload.source)


@router.post("/explain")
def explain(payload: CodeExplanationRequest, _: User = Depends(get_current_user)):
    return agent.explain(payload.problem_id)
