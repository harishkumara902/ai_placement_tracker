# AI Placement Mentor

A full-stack placement preparation platform built with Flutter Web and FastAPI. The application provides JWT authentication, resume ATS analysis, persistent learning roadmaps, evaluated mock interviews, coding practice, company retrieval, and an ML-backed placement probability report.

## Experience

- Dark academia / futuristic terminal interface with animated dot-grid background, glass cards, responsive navigation, and loading feedback.
- Protected Flutter application shell with dashboard, all preparation modules, and profile settings.
- AI agents automatically use thoughtful offline responses unless an OpenAI or Gemini key is supplied.
- Retrieval seed corpus includes 50 DSA questions, 30 SQL questions, 20 HR questions, and experiences for five companies.
- Random Forest placement model trains on 500 generated examples on first prediction and saves its artifact locally.

## Structure

```text
ai_placement_mentor/
  lib/                         Flutter web application
    core/                      theme, API client, JWT auth state
    pages/                     landing, auth, dashboard and feature screens
    widgets/                   reusable glass UI, score ring and gauge
  backend/
    agents/                    AI/mocked placement specialist agents
    ml/                        persisted sklearn predictor
    models/                    Pydantic contracts
    rag/                       seeded vector store and retriever
    routers/                   protected /api endpoints
    main.py                    FastAPI entrypoint and agentic chat route
```

## Prerequisites

- Flutter stable with web support
- Python 3.11 or newer

## Backend Setup

From the project directory:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
cd backend
uvicorn main:app --reload --port 8000
```

The default mode requires no API keys. To enable a provider, set `AI_PROVIDER=openai` with `OPENAI_API_KEY`, or `AI_PROVIDER=gemini` with `GEMINI_API_KEY` in `.env` before starting the backend.

For full semantic retrieval, install `pip install -r requirements-rag.txt` and set `ENABLE_CHROMA=true` to persist ChromaDB embeddings using `all-MiniLM-L6-v2`. Chroma may require Microsoft C++ Build Tools on Windows. With it disabled, the seeded retrieval corpus runs through the zero-download retriever so demos always start immediately.

## Flutter Setup

In another terminal from the project directory:

```powershell
flutter pub get
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

For Windows convenience, `.\run.ps1` starts both services. On macOS/Linux, run `chmod +x run.sh && ./run.sh`.

## API Surface

All application operations use the `/api` prefix. Authenticated routes require `Authorization: Bearer <jwt>`.

| Endpoint | Purpose |
| --- | --- |
| `POST /api/auth/register`, `POST /api/auth/login`, `GET /api/auth/me` | JWT account flow |
| `POST /api/resume/analyze`, `POST /api/resume/analyze-file` | ATS analysis for pasted text or upload |
| `POST /api/roadmap/generate`, `POST /api/roadmap/progress` | Timeline and persisted completion |
| `POST /api/interview/start`, `POST /api/interview/evaluate` | HR, technical, and system-design sessions |
| `GET /api/code/problems`, `POST /api/code/run`, `POST /api/code/explain` | Coding arena |
| `GET /api/company`, `GET /api/company/{name}` | Company preparation and retrieval |
| `POST /api/predict/placement` | Random Forest probability and recommendations |
| `POST /api/chat` | Master intent router |

Interactive OpenAPI documentation is available at [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs) while the backend runs.

## Production Notes

- Replace `SECRET_KEY`, restrict CORS to deployed frontend origins, and run behind HTTPS before deployment.
- SQLite is suitable for local and small deployments; configure a managed database through `DATABASE_URL` for multi-instance production.
- The Coding Arena intentionally executes a deterministic sandbox-free verdict service in this build. A production judge should run untrusted code in isolated containers with resource limits.
- Google OAuth is visibly available in the Flutter auth UI and reports configuration status until an OAuth backend is supplied.
