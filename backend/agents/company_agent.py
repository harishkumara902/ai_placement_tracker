from rag.retriever import Retriever


class CompanyAgent:
    companies = {
        "TCS": ("3.3 - 9 LPA", "Usually 12 months for select roles", ["NQT", "Technical", "HR"]),
        "Infosys": ("3.6 - 9.5 LPA", "Role dependent", ["InfyTQ/Written", "Technical", "HR"]),
        "Wipro": ("3.5 - 8 LPA", "Service agreement may apply", ["Written", "Technical", "HR"]),
        "Zoho": ("5 - 14 LPA", "No standard bond", ["Aptitude/Coding", "Technical", "HR"]),
        "Kaar Tech": ("4 - 10 LPA", "Role dependent", ["Aptitude", "Technical", "HR"]),
        "Accenture": ("4.5 - 12 LPA", "No standard bond", ["Assessment", "Technical", "HR"]),
        "Cognizant": ("4 - 10 LPA", "Role dependent", ["Assessment", "Technical", "HR"]),
        "HCL": ("3.5 - 10 LPA", "Program dependent", ["Written", "Technical", "HR"]),
    }

    def __init__(self) -> None:
        self.retriever = Retriever()

    def list_companies(self) -> list[dict]:
        return [{"name": name, "salary_range": data[0], "rounds": data[2]} for name, data in self.companies.items()]

    def details(self, company: str) -> dict:
        selected = next((name for name in self.companies if name.lower() == company.lower()), "TCS")
        salary, bond, rounds = self.companies[selected]
        return {
            "name": selected,
            "salary_range": salary,
            "bond_details": bond,
            "role_types": ["Software Engineer", "Data Analyst", "Cloud Associate"],
            "hiring_process": [{"round": item, "focus": self._focus(item)} for item in rounds],
            "previous_questions": self.retriever.search(f"{selected} interview", limit=5),
        }

    @staticmethod
    def _focus(round_name: str) -> str:
        if "HR" in round_name:
            return "Communication, motivation, culture and relocation readiness."
        if "Technical" in round_name:
            return "Projects, core CS fundamentals, coding and role skills."
        return "Aptitude, communication, logical reasoning and coding fundamentals."
