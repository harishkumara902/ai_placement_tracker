#!/usr/bin/env bash
set -euo pipefail

trap 'kill 0' EXIT
(cd backend && uvicorn main:app --reload --host 127.0.0.1 --port 8000) &
flutter run -d chrome --web-port 5173 \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
