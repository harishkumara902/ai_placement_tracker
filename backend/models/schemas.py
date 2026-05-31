from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserCreate(BaseModel):
    full_name: str = Field(min_length=2, max_length=120)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    full_name: str
    email: EmailStr
    target_role: str
    target_company: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut


class ResumeRequest(BaseModel):
    resume_text: str = Field(min_length=20)
    dream_company: str = Field(min_length=2)
    target_role: str = Field(min_length=2)


class ResumeResult(BaseModel):
    ats_score: int
    strengths: list[str]
    missing_skills: list[str]
    suggestions: list[str]


class RoadmapRequest(BaseModel):
    company: str
    role: str
    weeks: int = Field(ge=2, le=24)


class RoadmapWeek(BaseModel):
    number: int
    title: str
    topics: list[str]
    resources: list[str]
    daily_tasks: int
    complete: bool = False


class RoadmapResult(BaseModel):
    roadmap_key: str
    company: str
    role: str
    weeks: list[RoadmapWeek]


class RoadmapProgressRequest(BaseModel):
    roadmap_key: str
    week_number: int
    complete: bool


class InterviewStartRequest(BaseModel):
    round: Literal["hr", "technical", "system-design"]
    difficulty: Literal["Easy", "Medium", "Hard"] = "Medium"
    category: str | None = None


class InterviewQuestion(BaseModel):
    id: str
    prompt: str
    category: str
    code: str | None = None


class InterviewEvaluationRequest(BaseModel):
    question: str
    answer: str = Field(min_length=1)
    round: str


class InterviewEvaluationResult(BaseModel):
    score: float
    feedback: str
    ideal_answer: str


class CodeRunRequest(BaseModel):
    problem_id: str
    language: str
    source: str = Field(min_length=1)


class CodeExplanationRequest(BaseModel):
    problem_id: str


class PredictionRequest(BaseModel):
    cgpa: float = Field(ge=0, le=10)
    projects: int = Field(ge=0, le=10)
    internships: int = Field(ge=0, le=3)
    skills: list[str]
    certifications: list[str]
    backlogs: bool
    domain: str


class PredictionResult(BaseModel):
    probability: float
    weak_areas: list[str]
    actions: list[dict[str, str]]
    feature_importances: dict[str, float]


class ChatRequest(BaseModel):
    message: str = Field(min_length=2)


class ChatResponse(BaseModel):
    agent: str
    answer: str
    supporting_data: dict[str, Any] = {}
