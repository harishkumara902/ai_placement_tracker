from fastapi import APIRouter, Depends

from agents.company_agent import CompanyAgent
from database import User
from routers.auth import get_current_user


router = APIRouter(prefix="/company", tags=["Company Preparation"])
agent = CompanyAgent()


@router.get("")
def companies(_: User = Depends(get_current_user)):
    return agent.list_companies()


@router.get("/{company}")
def detail(company: str, _: User = Depends(get_current_user)):
    return agent.details(company)
