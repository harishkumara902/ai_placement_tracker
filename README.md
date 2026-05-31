# AI Placement Mentor

Production-ready full-stack placement preparation app:

- Flutter mobile app in `flutter_app/` for APK and Play Store builds.
- FastAPI backend in `backend/` for Render deployment.
- PostgreSQL on Render for production data.
- SQLite fallback for local development.
- ChromaDB persistent vector store on the Render instance.
- RandomForest ML predictor trained on first startup when no model exists.

## Repository Structure

```text
backend/
  main.py
  config.py
  database.py
  requirements.txt
  render.yaml
  .env.example
  alembic/
  routers/
  agents/
  rag/
  ml/
flutter_app/
  pubspec.yaml
  android/
  lib/
    config/
    core/
    models/
    services/
    providers/
    screens/
    pages/
    widgets/
```

## Local Development

### Backend

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Add GEMINI_API_KEY or OPENAI_API_KEY if you want real AI responses.
uvicorn main:app --reload --port 8000
```

If `DATABASE_URL` is not set, the backend automatically uses SQLite at `backend/placement.db`.

Useful checks:

```bash
curl http://127.0.0.1:8000/health
open http://127.0.0.1:8000/docs
```

### Flutter

```bash
cd flutter_app
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Use `http://10.0.2.2:8000` for Android emulator and `http://localhost:8000` for iOS simulator.

## Render Deployment

1. Push this repository to GitHub.
2. Render Dashboard → New → PostgreSQL.
3. Choose the free tier and copy the Internal Database URL.
4. Render Dashboard → New → Web Service → connect this repo.
5. Set Root Directory to `backend`.
6. Use:
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `uvicorn main:app --host 0.0.0.0 --port $PORT`
7. Add environment variables:
   - `DATABASE_URL` = Render PostgreSQL Internal Database URL
   - `SECRET_KEY` = any random 32+ character value
   - `AI_PROVIDER` = `gemini`
   - `GEMINI_API_KEY` = your Gemini key
   - `OPENAI_API_KEY` = optional OpenAI key
8. Deploy and test:

```bash
curl https://your-app.onrender.com/health
```

`backend/render.yaml` is included for Blueprint deployment. Alembic runs on startup and `Base.metadata.create_all()` is also called so local demo databases bootstrap automatically.

## PostgreSQL Production Database

Tables created:

- `users`: id, email, name, hashed_password, college, target_domain, created_at
- `user_progress`: id, user_id, module, score, completed_at
- `roadmap_items`: id, user_id, week, topic, is_completed
- `interview_sessions`: id, user_id, type, score, feedback, created_at
- `predictions`: id, user_id, probability, weak_areas, cgpa, created_at

## ChromaDB Vector Store

On startup, the backend creates `./chroma_db` and seeds:

- 50 DSA questions
- 30 SQL questions
- 20 HR questions
- 10 company-specific questions

The embedding model is `all-MiniLM-L6-v2`. If ChromaDB or the embedding model is unavailable locally, the app falls back to keyword retrieval so demos still work.

## Flutter APK Build

1. Update `flutter_app/lib/config/api_config.dart`:

```dart
static const String baseUrl = "https://your-app.onrender.com";
```

Or build with:

```bash
cd flutter_app
flutter build apk --release --dart-define=API_BASE_URL=https://your-app.onrender.com
```

APK output:

```text
flutter_app/build/app/outputs/flutter-apk/app-release.apk
```

## Play Store Build

Configure a release keystore in `flutter_app/android/app/build.gradle.kts`, then run:

```bash
cd flutter_app
flutter build appbundle --release --dart-define=API_BASE_URL=https://your-app.onrender.com
```

Upload the generated `.aab` to Google Play Console.

## Keep Render Free Tier Alive

Use [cron-job.org](https://cron-job.org):

- Method: `GET`
- URL: `https://your-app.onrender.com/health`
- Schedule: every 10 minutes

This reduces cold starts on Render free tier.

## API Health

```http
GET /health
```

Response:

```json
{"status":"ok","version":"1.0.0"}
```
