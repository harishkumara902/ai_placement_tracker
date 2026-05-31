import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv


BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")
load_dotenv(BASE_DIR.parent / ".env")


def safe_print(message: str) -> None:
    try:
        print(message)
    except UnicodeEncodeError:
        print(message.encode("ascii", errors="ignore").decode("ascii"))


@dataclass(frozen=True)
class Settings:
    app_name: str = "AI Placement Mentor API"
    version: str = "1.0.0"
    database_url: str = os.getenv("DATABASE_URL", f"sqlite+aiosqlite:///{BASE_DIR / 'placement.db'}")
    secret_key: str = os.getenv("SECRET_KEY", "change-this-secret-before-production")
    algorithm: str = "HS256"
    access_token_minutes: int = int(os.getenv("ACCESS_TOKEN_MINUTES", "1440"))
    ai_provider: str = os.getenv("AI_PROVIDER", "gemini").lower()
    openai_api_key: str | None = os.getenv("OPENAI_API_KEY")
    gemini_api_key: str | None = os.getenv("GEMINI_API_KEY")
    enable_chroma: bool = os.getenv("ENABLE_CHROMA", "true").lower() == "true"

    @property
    def ai_enabled(self) -> bool:
        return bool(self.openai_api_key if self.ai_provider == "openai" else self.gemini_api_key)

    @property
    def use_mock(self) -> bool:
        return not self.ai_enabled

    def print_startup_warnings(self) -> None:
        if self.use_mock:
            safe_print(f"⚠️ Missing {self.ai_provider.upper()} API key. Smart mock AI responses are enabled.")
        if "change-this-secret" in self.secret_key:
            safe_print("⚠️ SECRET_KEY is using the development default. Set a strong value in production.")


settings = Settings()
