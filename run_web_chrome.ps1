# Flutter web-server modunda ayaklanir; localhost yanitlayinca Chrome'u acar.
# -d chrome bazen ilk derlemede pencere acmaz ya da dakikalarca bekletir — bu daha guvenilir.
# build/ klasorunu SILME — temiz kaldirma ilk derlemeyi uzatip dosya kilidi da yaratabilir.
param([int]$Port = 8080)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$Chrome = $null
foreach ($path in @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LocalAppData\Google\Chrome\Application\chrome.exe"
)) {
  if (Test-Path -LiteralPath $path) {
    $Chrome = $path
    $env:CHROME_EXECUTABLE = $path
    break
  }
}

if (-not $Chrome) {
  Write-Host "UYARI: Chrome.exe bulunamadi; URL sistem varsayilaninda acilacak." -ForegroundColor Yellow
}

$url = "http://localhost:${Port}/"

Write-Host "=== 1. Derleme penceresi (cmd) ===" -ForegroundColor Cyan
Write-Host "   Ilk derleme 2-10 dk surebilir. Hata gorurseniz buradaki mesaja bakin.`n" -ForegroundColor Gray

$cmdRun = 'flutter pub get && flutter run -d web-server --web-hostname=localhost --web-port=' + $Port + ' --no-web-resources-cdn'

Start-Process -FilePath "cmd.exe" -WorkingDirectory $PSScriptRoot -ArgumentList @("/k", $cmdRun)

Write-Host "=== 2. Adres yanitlanana kadar bekleniyor: $url ===" -ForegroundColor Cyan

$opened = $false
$deadline = (Get-Date).AddMinutes(15)
$n = 0
while ((Get-Date) -lt $deadline) {
  try {
    $null = Invoke-WebRequest -Uri $url -TimeoutSec 3 -UseBasicParsing
    Write-Host "`nSunucu hazir. Chrome aciliyor...`n" -ForegroundColor Green
    if ($Chrome) {
      Start-Process -FilePath $Chrome -ArgumentList @("--new-window", $url)
    } else {
      Start-Process $url
    }
    $opened = $true
    break
  } catch {
    Start-Sleep -Seconds 4
    $n++
    if (($n % 10) -eq 0) {
      Write-Host "Hala bekleniyor (ilk derleme uzun surebilir)..." -ForegroundColor DarkGray
    }
  }
}

if (-not $opened) {
  Write-Host ('Zaman asimi: Port ' + $Port + ' yanitlamadi. CMD penceresindeki Flutter ciktisina bakin. Sunucu hazirsa Chrome ile su adresi acin:') -ForegroundColor Red
  Write-Host $url -ForegroundColor Yellow
} else {
  Write-Host 'Tamam: Flutter sunucusu o CMD penceresinde - pencereyi KAPATMAYIN.' -ForegroundColor Green
}
