# Web debug: Chrome otomatik acilmazsa bu scripti calistirin.
# Terminalde gorunen http://localhost:PORT adresini tarayicida (Chrome/Edge) acin.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (Test-Path "build") {
  Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
}

Write-Host "=== flutter run -d web-server (el ile tarayici) ===" -ForegroundColor Cyan
flutter pub get
# Sabit port; cakisma olursa --web-port=8090 deneyin
flutter run -d web-server --web-hostname=localhost --web-port=8080 --no-web-resources-cdn
