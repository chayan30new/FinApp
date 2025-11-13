@echo off
echo Starting Flutter web app with CORS disabled for development...
echo.
echo NOTE: This will close all Chrome windows and restart Chrome with CORS disabled.
echo This is ONLY for development purposes.
echo.
pause

REM Kill all Chrome processes
taskkill /F /IM chrome.exe 2>nul

REM Wait a moment for Chrome to close
timeout /t 2 /nobreak >nul

REM Start Flutter with Chrome in CORS-disabled mode
flutter run -d chrome --web-browser-flag "--disable-web-security" --web-browser-flag "--user-data-dir=%TEMP%\chrome_dev_session"
