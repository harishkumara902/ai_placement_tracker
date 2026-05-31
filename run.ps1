$ErrorActionPreference = "Stop"
$backend = Start-Process -FilePath "python" -ArgumentList "-m", "uvicorn", "main:app", "--reload", "--host", "127.0.0.1", "--port", "8000" -WorkingDirectory "$PSScriptRoot\backend" -PassThru -WindowStyle Hidden
try {
  Push-Location "$PSScriptRoot\flutter_app"
  flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
} finally {
  Pop-Location
  Stop-Process -Id $backend.Id -ErrorAction SilentlyContinue
}
