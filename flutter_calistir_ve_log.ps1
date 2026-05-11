# Proje klasorunde calistirin. Hata olursa flutter_run_LOG.txt dosyasini acip son ~40 satiri paylasin.
$ErrorActionPreference = "Continue"
Set-Location $PSScriptRoot
$log = Join-Path $PSScriptRoot "flutter_run_LOG.txt"

@"
=== $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===
"@ | Set-Content -Path $log -Encoding UTF8

Add-Content $log "`n--- flutter doctor (ozet) ---`n"
flutter doctor 2>&1 | Add-Content $log -Encoding UTF8

Add-Content $log "`n--- flutter clean ---`n"
flutter clean 2>&1 | Add-Content $log -Encoding UTF8

Add-Content $log "`n--- flutter pub get ---`n"
flutter pub get 2>&1 | Add-Content $log -Encoding UTF8

Add-Content $log "`n--- flutter build web ---`n"
flutter build web --no-web-resources-cdn 2>&1 | Add-Content $log -Encoding UTF8

if ($LASTEXITCODE -ne 0) {
  Write-Host "HATA: build web basarisiz. Log dosyasi: $log" -ForegroundColor Red
  Write-Host "Son satirlar:" -ForegroundColor Yellow
  Get-Content $log -Tail 35
  exit $LASTEXITCODE
}

Add-Content $log "`n--- flutter run chrome (CTRL+C ile durdur) ---`n"
Write-Host "Build tamam. Simdi Chrome ile calisiyor; bitirmek icin terminalde CTRL+C kullanin.`nLog: $log" -ForegroundColor Green
flutter run -d chrome --no-web-resources-cdn -v 2>&1 | Tee-Object -FilePath $log -Append
