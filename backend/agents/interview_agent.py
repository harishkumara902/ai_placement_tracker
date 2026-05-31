from agents.base import BaseAgent
from models.schemas import InterviewEvaluationResult, InterviewQuestion, InterviewStartRequest


class InterviewAgent(BaseAgent):
    system_prompt = (
        "You are a rigorous interview evaluator. Return JSON with numeric score out of 10, "
        "specific feedback, and an ideal answer."
    )
    questions = {
        "hr": [
            "Tell me about yourself and connect your experience to this role.",
            "Describe a conflict in a team and how you resolved it.",
            "Why should we hire you over other qualified candidates?",
        ],
        "system-design": [
            "Design a campus placement portal that supports applications and recruiter dashboards.",
            "Design a URL shortener with analytics and rate limiting.",
            "Design a notification system for job alerts across email and mobile.",
        ],
        "SQL": [
            "Write SQL to find the second highest salary in each department.",
            "How would you identify duplicate emails and retain the latest record?",
            "Explain indexes and when an index can slow down writes.",
        ],
        "DSA": [
            "Given an integer array, return the longest consecutive sequence in O(n) time.",
            "Find the first non-repeating character in a stream.",
            "Implement cycle detection in a directed graph.",
        ],
        "Aptitude": [
            "A train crosses a 300m platform in 30 seconds at 54 km/h. Find its length.",
            "A product gains 20% after a 10% discount on marked price. Relate cost and marked price.",
            "Find the next term: 3, 8, 18, 38, ?",
        ],
    }

    def start(self, request: InterviewStartRequest) -> list[InterviewQuestion]:
        key = request.category if request.round == "technical" else request.round
        prompts = self.questions.get(key or "DSA", self.questions["DSA"])
        return [
            InterviewQuestion(id=f"{key}-{index}", prompt=prompt, category=key or "DSA")
            for index, prompt in enumerate(prompts, start=1)
        ]

    def evaluate(self, question: str, answer: str, interview_round: str) -> InterviewEvaluationResult:
        result = self.ai_json(f"Round: {interview_round}\nQuestion: {question}\nAnswer: {answer}")
        if result:
            return InterviewEvaluationResult.model_validate(result)
        length_score = min(4, len(answer.split()) / 30 * 4)
        structure_terms = ("because", "result", "first", "then", "trade-off", "complexity", "learned")
        evidence_score = min(3, sum(term in answer.lower() for term in structure_terms))
        clarity_score = 2 if len(answer.split()) >= 25 else 1
        score = round(min(10, 1 + length_score + evidence_score + clarity_score), 1)
        feedback = (
            "Good direction. Strengthen this with a concrete outcome and an explicit trade-off."
            if score >= 6
            else "Build a structured answer: context, action or approach, reasoning, and measurable result."
        )
        ideal = (
            "Lead with a clear approach, state assumptions, walk through key decisions, "
            "mention trade-offs, and close with impact or validation."
        )
        return InterviewEvaluationResult(score=score, feedback=feedback, ideal_answer=ideal)
