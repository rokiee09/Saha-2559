# Web debug: Chrome otomatik acilmazsa bu scripti calistirin.
# Terminalde gorunen http://localhost:PORT adresini tarayicida (Chrome/Edge) acin.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# build/ klasorunu temizlemeyin: ilk derleme gereksiz uzar.

Write-Host "=== flutter run -d web-server (el ile tarayici) ===" -ForegroundColor Cyan
Write-Host "(Chrome'un otomatik acilmasi icin yerine run_web_chrome.ps1 kullanabilirsiniz.)" -ForegroundColor Gray
flutter pub get
# Sabit port; cakisma olursa --web-port=8090 deneyin
flutter run -d web-server --web-hostname=localhost --web-port=8080 --no-web-resources-cdn
