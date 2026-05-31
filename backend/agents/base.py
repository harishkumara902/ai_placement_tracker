import json
from typing import Any

from config import settings


class BaseAgent:
    system_prompt = "You are a helpful placement coach."

    def ai_json(self, prompt: str) -> dict[str, Any] | None:
        if not settings.ai_enabled:
            return None
        try:
            if settings.ai_provider == "openai":
                from openai import OpenAI

                result = OpenAI(api_key=settings.openai_api_key).chat.completions.create(
                    model="gpt-4o-mini",
                    response_format={"type": "json_object"},
                    messages=[
                        {"role": "system", "content": self.system_prompt},
                        {"role": "user", "content": prompt},
                    ],
                    temperature=0.35,
                )
                return json.loads(result.choices[0].message.content or "{}")
            import google.generativeai as genai

            genai.configure(api_key=settings.gemini_api_key)
            model = genai.GenerativeModel(
                "gemini-1.5-flash",
                system_instruction=self.system_prompt,
            )
            response = model.generate_content(f"Return valid JSON only. {prompt}")
            text = response.text.strip().removeprefix("```json").removesuffix("```").strip()
            return json.loads(text)
        except Exception:
            return None
