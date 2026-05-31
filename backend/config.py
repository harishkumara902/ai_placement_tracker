import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv


BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR.parent / ".env")


@dataclass(frozen=True)
class Settings:
    app_name: str = "AI Placement Mentor API"
    database_url: str = os.getenv("DATABASE_URL", f"sqlite:///{BASE_DIR / 'placement_mentor.db'}")
    secret_key: str = os.getenv("SECRET_KEY", "change-this-secret-before-production")
    algorithm: str = "HS256"
    access_token_minutes: int = int(os.getenv("ACCESS_TOKEN_MINUTES", "1440"))
    ai_provider: str = os.getenv("AI_PROVIDER", "openai").lower()
    openai_api_key: str | None = os.getenv("OPENAI_API_KEY")
    gemini_api_key: str | None = os.getenv("GEMINI_API_KEY")
    frontend_origin: str = os.getenv("FRONTEND_ORIGIN", "http://localhost:5173")

    @property
    def ai_enabled(self) -> bool:
        return bool(self.openai_api_key if self.ai_provider == "openai" else self.gemini_api_key)


settings = Settings()
