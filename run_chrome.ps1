# Chrome yolu tanimli degilse otomatik acilmama sik goriulur. Bu script dener.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$candidates = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe",
  "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
)
foreach ($p in $candidates) {
  if (Test-Path -LiteralPath $p) {
    $env:CHROME_EXECUTABLE = $p
    Write-Host "CHROME_EXECUTABLE=$p" -ForegroundColor Green
    break
  }
}

# build/ klasorunu temizlemeyin: ilk derleme uzar, Windows'ta klasor kilidi/hata daha sik gorulur.

Write-Host "=== flutter run -d chrome ===" -ForegroundColor Cyan
Write-Host "(Ilk derlemede dakikalar surebilir. Chrome otomatik acilmazsa: run_web_chrome.ps1 kullan.)" -ForegroundColor Gray
flutter pub get
flutter run -d chrome --no-web-resources-cdn
