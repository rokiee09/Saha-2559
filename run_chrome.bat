@echo off
cd /d "%~dp0"
echo Chrome'da Flutter web calistiriliyor...
echo.
flutter run -d chrome
if errorlevel 1 (
  echo.
  echo HATA: Yukaridaki mesaji okuyun. Genelde once "flutter pub get" deneyin.
  pause
)
