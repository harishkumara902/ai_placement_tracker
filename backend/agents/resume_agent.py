import re

from agents.base import BaseAgent
from models.schemas import ResumeRequest, ResumeResult


class ResumeAgent(BaseAgent):
    system_prompt = (
        "You are an ATS and placement resume reviewer. Return concise JSON with ats_score, "
        "strengths, missing_skills and suggestions tailored to the target role and company."
    )
    role_skills = {
        "data": ["Python", "SQL", "Power BI", "Statistics", "Machine Learning"],
        "software": ["DSA", "REST APIs", "Git", "Testing", "System Design"],
        "devops": ["Docker", "CI/CD", "Cloud", "Linux", "Monitoring"],
        "marketing": ["SEO", "Analytics", "Campaign Strategy", "Communication"],
    }

    def analyze(self, request: ResumeRequest) -> ResumeResult:
        ai_result = self.ai_json(request.model_dump_json())
        if ai_result:
            return ResumeResult.model_validate(ai_result)
        text = request.resume_text.lower()
        role_key = next((key for key in self.role_skills if key in request.target_role.lower()), "software")
        required = self.role_skills[role_key]
        matched = [skill for skill in required if skill.lower() in text]
        missing = [skill for skill in required if skill not in matched]
        measurable = bool(re.search(r"\b\d+(?:%|\+|k| users| ms| projects?)", text))
        sections = sum(term in text for term in ("education", "experience", "skills", "project"))
        score = min(96, 42 + len(matched) * 9 + sections * 5 + (9 if measurable else 0))
        strengths = [
            f"Evidence of {skill} aligns with the {request.target_role} role." for skill in matched[:3]
        ] or ["Your profile states a clear professional direction."]
        if measurable:
            strengths.append("Uses measurable outcomes that help ATS ranking and recruiter scanning.")
        suggestions = [
            f"Add a project bullet demonstrating {skill} with a measurable result." for skill in missing[:3]
        ]
        suggestions.append(f"Mirror relevant keywords from {request.dream_company}'s {request.target_role} job description.")
        if not measurable:
            suggestions.append("Quantify project impact, performance improvements, or scale in bullet points.")
        return ResumeResult(ats_score=score, strengths=strengths, missing_skills=missing, suggestions=suggestions)
