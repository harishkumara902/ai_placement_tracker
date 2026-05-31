#!/usr/bin/env bash
set -euo pipefail

trap 'kill 0' EXIT
(cd backend && uvicorn main:app --reload --host 127.0.0.1 --port 8000) &
(cd flutter_app && flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000)
