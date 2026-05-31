from functools import lru_cache

from rag.vector_store import VectorStore


@lru_cache(maxsize=1)
def get_store() -> VectorStore:
    return VectorStore()


class Retriever:
    def search(self, query: str, limit: int = 5) -> list[str]:
        return get_store().search(query, limit)
