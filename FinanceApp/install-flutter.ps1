# Flutter Installation Script for Windows
# Run this script AFTER downloading and extracting Flutter to C:\src\flutter

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Flutter Installation Helper" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter directory exists
if (-not (Test-Path "C:\src\flutter\bin\flutter.bat")) {
    Write-Host "❌ Flutter not found at C:\src\flutter" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please follow these steps:" -ForegroundColor Yellow
    Write-Host "1. Download Flutter from: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "2. Extract the ZIP to C:\src (so you have C:\src\flutter\)" -ForegroundColor White
    Write-Host "3. Run this script again" -ForegroundColor White
    Write-Host ""
    
    # Offer to download
    $download = Read-Host "Would you like to open the download page? (y/n)"
    if ($download -eq 'y') {
        Start-Process "https://docs.flutter.dev/get-started/install/windows"
    }
    exit 1
}

Write-Host "✅ Flutter directory found!" -ForegroundColor Green
Write-Host ""

# Add to PATH
Write-Host "Adding Flutter to PATH..." -ForegroundColor Yellow
$flutterPath = "C:\src\flutter\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")

if ($userPath -notlike "*$flutterPath*") {
    try {
        $newPath = "$userPath;$flutterPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
        Write-Host "✅ Flutter added to PATH successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "⚠️  IMPORTANT: Close and reopen this terminal for PATH changes to take effect" -ForegroundColor Yellow
    }
    catch {
        Write-Host "❌ Error adding to PATH: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please add manually:" -ForegroundColor Yellow
        Write-Host "1. Press Win + X and select 'System'" -ForegroundColor White
        Write-Host "2. Click 'Advanced system settings'" -ForegroundColor White
        Write-Host "3. Click 'Environment Variables'" -ForegroundColor White
        Write-Host "4. Under 'User variables', find 'Path' and click 'Edit'" -ForegroundColor White
        Write-Host "5. Click 'New' and add: C:\src\flutter\bin" -ForegroundColor White
        Write-Host "6. Click 'OK' on all dialogs" -ForegroundColor White
    }
}
else {
    Write-Host "✅ Flutter is already in PATH" -ForegroundColor Green
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Close this terminal and open a NEW one" -ForegroundColor White
Write-Host "2. Run: flutter doctor" -ForegroundColor Cyan
Write-Host "3. Install missing dependencies (Git, Android Studio)" -ForegroundColor White
Write-Host "4. Run: flutter doctor --android-licenses" -ForegroundColor Cyan
Write-Host "5. Navigate back to this project and run: flutter pub get" -ForegroundColor Cyan
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
