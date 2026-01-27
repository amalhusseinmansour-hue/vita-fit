#!/bin/bash

# VitaFit iOS Build Script
# Run this script on Mac to build the iOS app

set -e

echo "=========================================="
echo "VitaFit iOS Build Script"
echo "=========================================="

# Navigate to project directory
cd "$(dirname "$0")"

echo ""
echo "[1/7] Cleaning Flutter project..."
flutter clean

echo ""
echo "[2/7] Getting Flutter dependencies..."
flutter pub get

echo ""
echo "[3/7] Cleaning iOS build artifacts..."
cd ios
rm -rf Pods Podfile.lock .symlinks
rm -rf ~/Library/Developer/Xcode/DerivedData/*vitafit* 2>/dev/null || true
rm -rf build 2>/dev/null || true
cd ..

echo ""
echo "[4/7] Regenerating iOS files..."
flutter build ios --config-only

echo ""
echo "[5/7] Installing CocoaPods dependencies..."
cd ios
pod deintegrate 2>/dev/null || true
pod cache clean --all 2>/dev/null || true
pod install --repo-update
cd ..

echo ""
echo "[6/7] Building iOS app (Release)..."
flutter build ios --release --no-codesign

echo ""
echo "[7/7] Build completed successfully!"
echo ""
echo "=========================================="
echo "Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Select your team for signing"
echo "3. Set the correct Bundle Identifier: com.vitafitapp.fitness"
echo "4. Archive and upload to App Store Connect"
echo "=========================================="
echo ""
echo "To build IPA directly, run:"
echo "  flutter build ipa --release"
echo ""
