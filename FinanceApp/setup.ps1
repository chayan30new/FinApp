# Investment Tracker - Quick Start Script
# Run this script to check your Flutter setup and run the app

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Investment Tracker - Setup Check" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
$flutterInstalled = Get-Command flutter -ErrorAction SilentlyContinue

if ($null -eq $flutterInstalled) {
    Write-Host "❌ Flutter is NOT installed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Flutter first:" -ForegroundColor Yellow
    Write-Host "1. Visit: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "2. Download and extract Flutter SDK" -ForegroundColor White
    Write-Host "3. Add Flutter to your PATH" -ForegroundColor White
    Write-Host "4. Run: flutter doctor" -ForegroundColor White
    Write-Host ""
    Write-Host "See SETUP_GUIDE.md for detailed instructions" -ForegroundColor Cyan
    exit 1
}

Write-Host "✅ Flutter is installed" -ForegroundColor Green
Write-Host ""

# Run flutter doctor
Write-Host "Running Flutter Doctor..." -ForegroundColor Yellow
flutter doctor

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan

# Ask if user wants to get packages
$response = Read-Host "Do you want to get Flutter packages now? (y/n)"
if ($response -eq 'y') {
    Write-Host ""
    Write-Host "Getting Flutter packages..." -ForegroundColor Yellow
    flutter pub get
    
    Write-Host ""
    Write-Host "✅ Packages installed successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Ask if user wants to run the app
    $runApp = Read-Host "Do you want to run the app now? (y/n)"
    if ($runApp -eq 'y') {
        Write-Host ""
        Write-Host "Starting the app..." -ForegroundColor Yellow
        Write-Host "Note: Make sure you have an Android emulator running or a device connected" -ForegroundColor Cyan
        Write-Host ""
        flutter run
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Make sure Android Studio is installed" -ForegroundColor White
Write-Host "2. Create/Start an Android emulator" -ForegroundColor White
Write-Host "3. Run: flutter run" -ForegroundColor White
Write-Host ""
Write-Host "For detailed instructions, see SETUP_GUIDE.md" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
