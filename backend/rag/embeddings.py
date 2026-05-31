import os
from functools import lru_cache


@lru_cache(maxsize=1)
def embedding_model():
    if os.getenv("ENABLE_CHROMA", "false").lower() != "true":
        return None
    try:
        from sentence_transformers import SentenceTransformer

        return SentenceTransformer("all-MiniLM-L6-v2")
    except Exception:
        return None


def embed(texts: list[str]) -> list[list[float]] | None:
    model = embedding_model()
    return model.encode(texts).tolist() if model else None
