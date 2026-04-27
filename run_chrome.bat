@echo off
cd /d "%~dp0"
echo Chrome'da Flutter web calistiriliyor...
echo (CDN kapali: ag engeli / kurum agi icin)
echo.
flutter run -d chrome --no-web-resources-cdn
if errorlevel 1 (
  echo.
  echo HATA: Yukaridaki mesaji okuyun. Genelde once "flutter pub get" deneyin.
  pause
)
