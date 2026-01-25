# VitaFit iOS Rebuild Script v1.0.10+56
# Run this in PowerShell

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  VitaFit iOS Clean Rebuild" -ForegroundColor Cyan
Write-Host "  Version: 1.0.10+56" -ForegroundColor Gray
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to project
Set-Location "C:\Users\HP\Desktop\projects\vitafit"

# Step 1: Clean Flutter
Write-Host "[1/6] Cleaning Flutter..." -ForegroundColor Yellow
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "Warning: flutter clean had issues" -ForegroundColor Yellow
}

# Step 2: Clean iOS files
Write-Host "`n[2/6] Cleaning iOS files..." -ForegroundColor Yellow
if (Test-Path "ios\Pods") {
    Remove-Item -Recurse -Force "ios\Pods"
    Write-Host "  - Removed Pods folder" -ForegroundColor Gray
}
if (Test-Path "ios\Podfile.lock") {
    Remove-Item -Force "ios\Podfile.lock"
    Write-Host "  - Removed Podfile.lock" -ForegroundColor Gray
}
if (Test-Path "ios\.symlinks") {
    Remove-Item -Recurse -Force "ios\.symlinks"
    Write-Host "  - Removed .symlinks" -ForegroundColor Gray
}
if (Test-Path "build") {
    Remove-Item -Recurse -Force "build"
    Write-Host "  - Removed build folder" -ForegroundColor Gray
}

# Step 3: Get dependencies
Write-Host "`n[3/6] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: flutter pub get failed!" -ForegroundColor Red
    exit 1
}

# Step 4: Run pod install (for macOS only, skip on Windows)
Write-Host "`n[4/6] Pod install will run during build..." -ForegroundColor Yellow

# Step 5: Build iOS Release
Write-Host "`n[5/6] Building iOS Release..." -ForegroundColor Yellow
flutter build ios --release
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: iOS build failed!" -ForegroundColor Red
    Write-Host "`nTry building from Xcode for more details:" -ForegroundColor Yellow
    Write-Host "  1. Open ios/Runner.xcworkspace" -ForegroundColor Gray
    Write-Host "  2. Select Product -> Build" -ForegroundColor Gray
    exit 1
}

# Step 6: Success
Write-Host "`n[6/6] Build Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  SUCCESS! App is ready" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To test on device:" -ForegroundColor Cyan
Write-Host "  1. Open ios/Runner.xcworkspace in Xcode" -ForegroundColor White
Write-Host "  2. Select your device" -ForegroundColor White
Write-Host "  3. Press Cmd+R to run" -ForegroundColor White
Write-Host ""
Write-Host "To submit to App Store:" -ForegroundColor Cyan
Write-Host "  1. In Xcode: Product -> Archive" -ForegroundColor White
Write-Host "  2. Click 'Distribute App'" -ForegroundColor White
Write-Host "  3. Select 'App Store Connect'" -ForegroundColor White
Write-Host "  4. Upload to App Store Connect" -ForegroundColor White
Write-Host ""
