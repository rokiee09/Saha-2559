@echo off
chcp 65001 >nul
cd /d "%~dp0"
title SAHA 2559 - Flutter (web-server)
color 0B
echo.
echo ============================================
echo   SAHA 2559 - calistirma (tarayiciyi siz acin)
echo ============================================
echo  Klasor: %CD%
echo.

if exist build (
  echo [build] Eski build siliniyor...
  rmdir /s /q build 2>nul
)
echo.
echo [1/3] flutter clean
call flutter clean
if errorlevel 1 goto hata
echo.
echo [2/3] flutter pub get
call flutter pub get
if errorlevel 1 goto hata
echo.
echo [3/3] Sunucu basliyor. Asagidaki gibi bir satir gorunur:
echo       http://127.0.0.1:8080  veya  http://localhost:8080
echo       Bu adresi Chrome veya Edge^'e yapistirip acin.
echo      (8080 baskasinda ise terminalde gosterilen portu kullanin)
echo.
echo Durdurmak icin: Ctrl+C
echo ============================================
echo.

call flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8080 --no-web-resources-cdn

if errorlevel 1 goto hata
goto son
:hata
echo.
echo ---- HATA ----
echo Yukaridaki kirmizi/uyari metinlerini not edin (flutter doctor da calistirilabilir).
echo.
:son
pause
