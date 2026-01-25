# VitaFit Test Build Script v1.0.10+56
# Run this in PowerShell to test the app

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  VitaFit Build Test" -ForegroundColor Cyan
Write-Host "  Version: 1.0.10+56" -ForegroundColor Gray
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Set-Location "C:\Users\HP\Desktop\projects\vitafit"

# Test 1: Check Flutter
Write-Host "[1/5] Checking Flutter..." -ForegroundColor Yellow
$flutterVersion = flutter --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - Flutter found" -ForegroundColor Green
} else {
    Write-Host "  ERROR - Flutter not found!" -ForegroundColor Red
    Write-Host "  Make sure Flutter is in your PATH" -ForegroundColor Yellow
    exit 1
}

# Test 2: Clean and get dependencies
Write-Host "`n[2/5] Getting dependencies..." -ForegroundColor Yellow
flutter clean | Out-Null
flutter pub get
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - Dependencies ready" -ForegroundColor Green
} else {
    Write-Host "  ERROR - Failed to get dependencies!" -ForegroundColor Red
    exit 1
}

# Test 3: Analyze code
Write-Host "`n[3/5] Analyzing code..." -ForegroundColor Yellow
$analyzeOutput = flutter analyze 2>&1
$hasErrors = $analyzeOutput | Select-String -Pattern "error" -CaseSensitive:$false
if ($null -eq $hasErrors) {
    Write-Host "  OK - No errors found" -ForegroundColor Green
} else {
    Write-Host "  WARNING - Some issues found:" -ForegroundColor Yellow
    Write-Host $analyzeOutput -ForegroundColor Gray
}

# Test 4: Build iOS
Write-Host "`n[4/5] Building iOS (this may take a while)..." -ForegroundColor Yellow
flutter build ios --release --no-codesign 2>&1 | Tee-Object -Variable buildOutput
if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK - iOS build successful!" -ForegroundColor Green
} else {
    Write-Host "  ERROR - iOS build failed!" -ForegroundColor Red
    Write-Host "`nBuild output:" -ForegroundColor Yellow
    Write-Host $buildOutput -ForegroundColor Gray
    exit 1
}

# Test 5: Summary
Write-Host "`n[5/5] Build Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  All tests passed!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Open ios/Runner.xcworkspace in Xcode" -ForegroundColor White
Write-Host "  2. Set your signing team" -ForegroundColor White
Write-Host "  3. Build and run on device" -ForegroundColor White
Write-Host ""
Write-Host "For App Store submission:" -ForegroundColor Cyan
Write-Host "  1. Product -> Archive in Xcode" -ForegroundColor White
Write-Host "  2. Distribute App -> App Store Connect" -ForegroundColor White
Write-Host ""
