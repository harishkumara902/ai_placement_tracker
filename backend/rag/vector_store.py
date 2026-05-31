from pathlib import Path

from config import safe_print, settings
from rag.embeddings import embed


COLLECTIONS = {
    "DSA": "dsa_questions",
    "SQL": "sql_questions",
    "HR": "hr_questions",
    "Company": "company_experiences",
}


def seeded_documents() -> list[dict[str, str]]:
    documents: list[dict[str, str]] = []
    companies = ["TCS", "Infosys", "Wipro", "Zoho", "Accenture"]
    dsa_patterns = [
        "array hashing and two sum",
        "sliding window longest substring",
        "binary search on sorted data",
        "dynamic programming coin change",
        "graph traversal and cycle detection",
    ]
    sql_patterns = [
        "joins and aggregation",
        "window functions for ranking",
        "CTEs and duplicate cleanup",
        "indexes and query optimization",
        "second highest salary",
    ]
    hr_patterns = [
        "introduce yourself with project impact",
        "describe conflict resolution using STAR",
        "explain relocation and career goals",
        "handle failure and learning",
    ]
    for index in range(50):
        topic = dsa_patterns[index % len(dsa_patterns)]
        documents.append({"id": f"dsa-{index}", "text": f"DSA question {index + 1}: Solve {topic}; explain complexity and edge cases.", "category": "DSA"})
    for index in range(30):
        topic = sql_patterns[index % len(sql_patterns)]
        documents.append({"id": f"sql-{index}", "text": f"SQL question {index + 1}: Demonstrate {topic} with a query and explanation.", "category": "SQL"})
    for index in range(20):
        topic = hr_patterns[index % len(hr_patterns)]
        documents.append({"id": f"hr-{index}", "text": f"HR question {index + 1}: How would you {topic}?", "category": "HR"})
    for index in range(10):
        company = companies[index % len(companies)]
        documents.append(
            {
                "id": f"company-{index}",
                "text": f"{company} company-specific question {index + 1}: discuss projects, aptitude, SQL, DSA, role fit, and confident communication.",
                "category": "Company",
            }
        )
    return documents


class VectorStore:
    def __init__(self) -> None:
        self.documents = seeded_documents()
        self.collections = {}
        if settings.enable_chroma:
            self._start_chroma()

    def _start_chroma(self) -> None:
        try:
            import chromadb

            client = chromadb.PersistentClient(path=str(Path("./chroma_db").resolve()))
            for category, collection_name in COLLECTIONS.items():
                collection = client.get_or_create_collection(collection_name)
                self.collections[category] = collection
                category_docs = [doc for doc in self.documents if doc["category"] == category]
                if collection.count() == 0 and category_docs:
                    texts = [doc["text"] for doc in category_docs]
                    vectors = embed(texts)
                    kwargs = {
                        "ids": [doc["id"] for doc in category_docs],
                        "documents": texts,
                        "metadatas": [{"category": doc["category"]} for doc in category_docs],
                    }
                    if vectors:
                        kwargs["embeddings"] = vectors
                    collection.add(**kwargs)
        except Exception as exc:
            safe_print(f"⚠️ ChromaDB unavailable, using keyword retrieval fallback: {exc}")
            self.collections = {}

    def search(self, query: str, limit: int) -> list[str]:
        if self.collections:
            vectors = embed([query])
            collected: list[str] = []
            for collection in self.collections.values():
                result = collection.query(query_embeddings=vectors, query_texts=None if vectors else [query], n_results=min(limit, 3))
                collected.extend(result["documents"][0])
            return collected[:limit]
        terms = set(query.lower().split())
        ranked = sorted(
            self.documents,
            key=lambda doc: sum(term in doc["text"].lower() for term in terms),
            reverse=True,
        )
        return [item["text"] for item in ranked[:limit]]
