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

if (Test-Path "build") {
  Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
}

Write-Host "=== flutter run -d chrome ===" -ForegroundColor Cyan
flutter pub get
flutter run -d chrome --no-web-resources-cdn
