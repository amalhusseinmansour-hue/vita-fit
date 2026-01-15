# VitaFit - App Store Submission Guide

## Prerequisites Checklist

### 1. Apple Developer Account
- [ ] Active Apple Developer Program membership ($99/year)
- [ ] App ID created in Apple Developer Portal
- [ ] Enable "Sign in with Apple" capability for your App ID
- [ ] Create provisioning profiles (Development & Distribution)

### 2. Xcode Configuration
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Set Bundle Identifier (e.g., `com.vitafit.app`)
- [ ] Set Team to your Apple Developer account
- [ ] Add "Sign in with Apple" capability in Xcode:
  - Select Runner target > Signing & Capabilities > + Capability > Sign in with Apple

### 3. Firebase Configuration
- [ ] Download `GoogleService-Info.plist` from Firebase Console
- [ ] Add it to `ios/Runner/` folder
- [ ] Ensure Bundle ID matches Firebase configuration

---

## Build Instructions

### Step 1: Install Dependencies
```bash
# In project root
flutter pub get

# Install iOS pods
cd ios
pod install --repo-update
cd ..
```

### Step 2: Build for Release
```bash
# Build iOS release
flutter build ios --release

# Or build IPA for App Store
flutter build ipa --release
```

### Step 3: Archive in Xcode
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as build target
3. Product > Archive
4. Distribute App > App Store Connect > Upload

---

## App Store Connect Setup

### App Information
```
App Name: VitaFit
Subtitle: Fitness & Nutrition Coach
Category: Health & Fitness
Content Rating: 12+ (Infrequent/Mild Medical Information)
```

### Keywords (Arabic)
```
لياقة، تمارين، نظام غذائي، صحة، مدربة، تغذية، رياضة، وزن، عضلات، جيم
```

### Keywords (English)
```
fitness, workout, diet, health, trainer, nutrition, gym, weight, muscles, exercise
```

### App Description (Arabic)
```
VitaFit - رفيقتك في رحلة اللياقة والصحة

انضمي إلى آلاف النساء اللواتي غيرن حياتهن مع VitaFit!

المميزات:
• خطط تدريب مخصصة من مدربات محترفات
• برامج غذائية متكاملة تناسب أهدافك
• تتبع التقدم اليومي والأسبوعي
• جلسات تدريب مباشرة مع المدربات
• متجر للمنتجات الرياضية والمكملات
• إشعارات تذكيرية للتمارين والوجبات

ابدئي رحلتك الآن وحققي أهدافك!
```

### App Description (English)
```
VitaFit - Your Personal Fitness & Nutrition Companion

Join thousands of women who transformed their lives with VitaFit!

Features:
• Personalized training plans from professional coaches
• Comprehensive nutrition programs tailored to your goals
• Daily and weekly progress tracking
• Live training sessions with coaches
• Shop for fitness products and supplements
• Workout and meal reminder notifications

Start your journey today and achieve your goals!
```

---

## Privacy Policy Requirements

### Required URLs
- **Privacy Policy URL**: `https://vitafit.online/privacy-policy`
- **Terms of Service URL**: `https://vitafit.online/terms`
- **Support URL**: `https://vitafit.online/support`

### Data Collection Disclosure
In App Store Connect > App Privacy, declare:

| Data Type | Collection | Linked to User | Tracking |
|-----------|------------|----------------|----------|
| Name | Yes | Yes | No |
| Email | Yes | Yes | No |
| Phone | Optional | Yes | No |
| Health & Fitness | Yes | Yes | No |
| Photos | Optional | Yes | No |
| Payment Info | Via PayMob | No | No |
| Usage Data | Yes | Yes | No |
| Device ID | Yes | No | Yes |

---

## Screenshots Requirements

### iPhone Screenshots (Required)
- 6.7" Display (iPhone 14 Pro Max): 1290 x 2796 px
- 6.5" Display (iPhone 11 Pro Max): 1242 x 2688 px
- 5.5" Display (iPhone 8 Plus): 1242 x 2208 px

### iPad Screenshots (Optional but Recommended)
- 12.9" Display (iPad Pro): 2048 x 2732 px

### Recommended Screenshots
1. Login/Sign Up screen with Apple Sign In
2. Home dashboard
3. Training programs
4. Nutrition plans
5. Progress tracking
6. Shop screen

---

## Common Rejection Reasons & Solutions

### 1. Sign in with Apple Required
**Status**: ✅ IMPLEMENTED
- Added `sign_in_with_apple` package
- Backend endpoint `/api/auth/apple` added
- Apple Sign In button on login screen

### 2. Account Deletion Required
**Status**: ✅ EXISTS
- Delete account option in settings
- Soft delete with 30-day data retention
- Endpoint: `DELETE /api/auth/delete-account`

### 3. App Tracking Transparency
**Status**: ✅ IMPLEMENTED
- Added `app_tracking_transparency` package
- Permission requested after splash screen
- Proper usage description in Info.plist

### 4. Privacy Policy
**Status**: ✅ EXISTS
- Arabic privacy policy at `/privacy-policy`
- In-app privacy policy screen
- GDPR compliant

### 5. Terms of Service
**Status**: ✅ EXISTS
- Arabic terms at `/terms`
- In-app terms screen
- Age restriction (16+)

### 6. In-App Purchases
**Note**: If using PayMob for subscriptions, ensure:
- Clear pricing displayed
- Cancellation instructions
- Restore purchases option

---

## Entitlements Configuration

Create/Update `ios/Runner/Runner.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
    <key>aps-environment</key>
    <string>production</string>
</dict>
</plist>
```

---

## Backend Deployment Checklist

Before submission, ensure your backend:
- [ ] SSL certificate is valid (HTTPS)
- [ ] Apple Sign In endpoint tested
- [ ] Rate limiting configured
- [ ] Error handling for all edge cases
- [ ] Database migrations applied (apple_id field)

### Database Migration
Run this SQL to add Apple ID field:
```sql
ALTER TABLE users ADD COLUMN apple_id VARCHAR(255) UNIQUE;
ALTER TABLE users ADD COLUMN refresh_token VARCHAR(500);
```

---

## Testing Checklist

### Before Submission
- [ ] Test Apple Sign In on real device
- [ ] Test account creation via Apple
- [ ] Test login with existing Apple account
- [ ] Test account deletion
- [ ] Test push notifications
- [ ] Test all payment flows
- [ ] Test app in Arabic language
- [ ] Test app in English language
- [ ] Test on iPhone (various sizes)
- [ ] Test on iPad (if supported)

### TestFlight
1. Upload build to App Store Connect
2. Add internal testers
3. Test for at least 24-48 hours
4. Fix any crashes reported in Crashlytics

---

## Support Information

### App Store Connect Metadata
```
Support URL: https://vitafit.online/support
Support Email: support@vitafit.online
Marketing URL: https://vitafit.online
Privacy URL: https://vitafit.online/privacy-policy
```

### Contact Information
```
Developer Name: [Your Company Name]
Contact Email: support@vitafit.online
Phone: [Your Phone Number]
Address: [Your Business Address]
```

---

## Version History

| Version | Build | Changes |
|---------|-------|---------|
| 1.0.7 | 10 | Initial App Store submission with Apple Sign In |

---

## Notes

1. **Review Time**: First submissions typically take 24-48 hours
2. **Expedited Review**: Available for critical bug fixes
3. **Rejection Response**: You have 14 days to respond to rejections
4. **App Preview Videos**: Optional but recommended (15-30 seconds)

---

Good luck with your App Store submission! 🍎
