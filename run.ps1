$ErrorActionPreference = "Stop"
$backend = Start-Process -FilePath "python" -ArgumentList "-m", "uvicorn", "main:app", "--reload", "--host", "127.0.0.1", "--port", "8000" -WorkingDirectory "$PSScriptRoot\backend" -PassThru -WindowStyle Hidden
try {
  flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
} finally {
  Stop-Process -Id $backend.Id -ErrorAction SilentlyContinue
}
