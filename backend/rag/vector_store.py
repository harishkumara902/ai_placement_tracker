import os
from pathlib import Path

from rag.embeddings import embed


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
    for company in companies:
        for index in range(4):
            documents.append(
                {
                    "id": f"{company.lower()}-{index}",
                    "text": f"{company} interview experience: Round {index + 1} covered aptitude, projects, SQL, DSA, and confident communication.",
                    "category": company,
                }
            )
    return documents


class VectorStore:
    def __init__(self) -> None:
        self.documents = seeded_documents()
        self.collection = None
        if os.getenv("ENABLE_CHROMA", "false").lower() == "true":
            self._start_chroma()

    def _start_chroma(self) -> None:
        try:
            import chromadb

            path = Path(__file__).resolve().parent / ".chroma"
            self.collection = chromadb.PersistentClient(path=str(path)).get_or_create_collection("interview_knowledge")
            if self.collection.count() == 0:
                texts = [doc["text"] for doc in self.documents]
                vectors = embed(texts)
                kwargs = {"ids": [doc["id"] for doc in self.documents], "documents": texts, "metadatas": [{"category": doc["category"]} for doc in self.documents]}
                if vectors:
                    kwargs["embeddings"] = vectors
                self.collection.add(**kwargs)
        except Exception:
            self.collection = None

    def search(self, query: str, limit: int) -> list[str]:
        if self.collection:
            vectors = embed([query])
            result = self.collection.query(query_embeddings=vectors, query_texts=None if vectors else [query], n_results=limit)
            return result["documents"][0]
        terms = set(query.lower().split())
        ranked = sorted(
            self.documents,
            key=lambda doc: sum(term in doc["text"].lower() for term in terms),
            reverse=True,
        )
        return [item["text"] for item in ranked[:limit]]
