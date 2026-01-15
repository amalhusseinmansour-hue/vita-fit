# VitaFit - App Submission Checklist

## Current Status Summary

### Ready
- [x] Flutter app built and working
- [x] Android APK generated (VitaFit.apk, app-release.apk)
- [x] Android App Bundle generated (app-release.aab)
- [x] Release keystore configured (vitafit-release-key.jks)
- [x] iOS Privacy descriptions added (Info.plist)
- [x] Backend deployed at vitafit.online
- [x] Admin panel working at vitafit.online/admin
- [x] API endpoints functional
- [x] Privacy Policy page (vitafit.online/privacy-policy)
- [x] Terms of Service page (vitafit.online/terms)
- [x] Contact page (vitafit.online/contact)
- [x] Delete Account page (vitafit.online/delete-account)
- [x] Firebase packages in pubspec.yaml
- [x] Google Services Gradle plugin configured

### Needs Action

#### High Priority (Required for Firebase/Notifications)
- [ ] **google-services.json** - Download from Firebase Console and place in `android/app/`
- [ ] **GoogleService-Info.plist** - Download from Firebase Console and place in `ios/Runner/` (add to Xcode)
- [ ] **APNs Key** - Generate from Apple Developer and upload to Firebase Console

#### For Google Play
- [ ] Create Google Play Developer Account ($25 one-time fee)
- [ ] Prepare Feature Graphic (1024x500 px)
- [ ] Prepare Screenshots (minimum 2, recommended 8)
- [ ] Complete Content Rating questionnaire
- [ ] Complete Data Safety form
- [ ] Sign up for Google Play App Signing

#### For Apple App Store
- [ ] Apple Developer Account ($99/year)
- [ ] Create App Store Connect listing
- [ ] Prepare Screenshots for all required sizes
- [ ] Submit for Review

---

## App Information

| Field | Value |
|-------|-------|
| App Name | VitaFit - فيتافيت |
| Android Package | com.gym.fitness |
| iOS Bundle ID | com.vitafit.app |
| Version | 1.0.0 |
| Category | Health & Fitness |

---

## Files Location

```
C:\Users\HP\Desktop\gym\
├── android/
│   ├── app/
│   │   ├── build.gradle.kts        ✓ Configured
│   │   ├── proguard-rules.pro      ✓ Exists
│   │   └── google-services.json    ✗ MISSING (Download from Firebase)
│   ├── key.properties              ✓ Exists
│   ├── vitafit-release-key.jks     ✓ Exists (Keep secure!)
│   └── settings.gradle.kts         ✓ Google Services added
│
├── ios/
│   ├── Runner/
│   │   ├── Info.plist              ✓ Privacy descriptions added
│   │   └── GoogleService-Info.plist ✗ MISSING (Download from Firebase)
│
├── build/
│   └── app/outputs/
│       ├── flutter-apk/
│       │   └── app-release.apk     ✓ Ready for testing
│       └── bundle/release/
│           └── app-release.aab     ✓ Ready for Play Store
│
└── Docs/
    ├── STORE_LISTING.md            ✓ Store descriptions
    ├── FIREBASE_SETUP.md           ✓ Firebase guide
    └── APP_SUBMISSION_CHECKLIST.md ✓ This file
```

---

## Quick Start Commands

### Build Android APK
```bash
flutter build apk --release
```

### Build Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### Build iOS (on Mac only)
```bash
flutter build ios --release
```

---

## Firebase Setup Steps

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project "VitaFit"
3. Add Android app with package: `com.gym.fitness`
4. Download `google-services.json` → place in `android/app/`
5. Add iOS app with bundle ID: `com.vitafit.app`
6. Download `GoogleService-Info.plist` → place in `ios/Runner/` (add to Xcode)
7. Generate APNs key from Apple Developer Portal
8. Upload APNs key to Firebase Console

See `FIREBASE_SETUP.md` for detailed instructions.

---

## Store Submission Steps

### Google Play Store

1. **Create Account**
   - Go to [Google Play Console](https://play.google.com/console)
   - Pay $25 registration fee
   - Complete account verification

2. **Create App Listing**
   - Upload app-release.aab
   - Fill in app details (use STORE_LISTING.md)
   - Upload screenshots
   - Complete content rating
   - Complete data safety form

3. **Submit for Review**
   - Review usually takes 1-3 days
   - May need updates based on feedback

### Apple App Store

1. **Create Account**
   - Go to [Apple Developer](https://developer.apple.com/)
   - Pay $99/year membership
   - Complete verification

2. **Configure in App Store Connect**
   - Create new app
   - Fill in app information
   - Upload screenshots
   - Set pricing (Free)

3. **Build & Upload**
   - Open ios/Runner.xcworkspace in Xcode
   - Archive and upload to App Store Connect
   - Or use `flutter build ipa`

4. **Submit for Review**
   - Apple review usually takes 1-7 days
   - Must comply with App Store Guidelines

---

## Important Notes

### Security
- Keep `vitafit-release-key.jks` safe - you need it for updates
- Never commit `key.properties` or keystore to git
- Store Firebase config files securely

### Package Name Consideration
The Android package is `com.gym.fitness` which is generic. Consider:
- Keeping it as is (simpler)
- Changing to `com.vitafit.app` for consistency with iOS

If changing, update:
- `android/app/build.gradle.kts` (applicationId and namespace)
- Firebase Console (register new package)
- Re-download `google-services.json`

### iOS Bundle ID
Current iOS bundle ID is `com.vitafit.app` - this is good and matches the brand.

---

## Contact & Support

- Website: https://vitafit.online
- Support Email: support@vitafit.online
- Privacy Policy: https://vitafit.online/privacy-policy
- Terms: https://vitafit.online/terms
