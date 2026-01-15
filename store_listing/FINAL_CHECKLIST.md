# قائمة التحقق النهائية للنشر على المتاجر ✅

## تاريخ التحديث: يناير 2025

---

## 📱 ملفات البناء الجاهزة

### Android:
| الملف | الموقع | الحجم | الاستخدام |
|-------|--------|-------|-----------|
| AAB | `build/app/outputs/bundle/release/app-release.aab` | ~28MB | Google Play Store |
| APK (arm64) | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` | 12.3MB | التوزيع المباشر |
| APK (armeabi) | `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` | 11.9MB | الأجهزة القديمة |
| APK (x86_64) | `build/app/outputs/flutter-apk/app-x86_64-release.apk` | 12.4MB | المحاكيات |

### iOS:
```bash
# لبناء iOS (يتطلب macOS):
flutter build ios --release
# ثم من Xcode: Product > Archive
```

---

## ✅ المهام المكتملة

### التطبيق:
- [x] تسجيل الدخول والتسجيل
- [x] نسيت كلمة المرور
- [x] لوحة المتدرب
- [x] لوحة المدرب
- [x] لوحة الأدمن
- [x] التمارين والجدول
- [x] التغذية وخطط الوجبات
- [x] تتبع التقدم
- [x] المحادثات
- [x] الإشعارات (Firebase)
- [x] الدفع (PayMob, Google Pay, Apple Pay)
- [x] المتجر والمنتجات
- [x] الإعدادات والملف الشخصي

### المتاجر:
- [x] سياسة الخصوصية (HTML)
- [x] شروط الاستخدام (HTML)
- [x] وصف التطبيق (عربي)
- [x] وصف التطبيق (إنجليزي)
- [x] دليل Data Safety
- [x] دليل أصول المتجر
- [x] Proguard Rules
- [x] Android Permissions
- [x] iOS Permissions (Info.plist)
- [x] Firebase Configuration
- [x] App Signing (keystore)

---

## ⏳ المهام المتبقية

### Google Play Store:

#### 1. إنشاء حساب المطور
```
رابط: https://play.google.com/console
التكلفة: $25 (مرة واحدة)
```

#### 2. إنشاء التطبيق الجديد
- [ ] اسم التطبيق: VitaFit
- [ ] اللغة الافتراضية: العربية
- [ ] نوع التطبيق: App (ليس Game)

#### 3. Store Listing
- [ ] وصف قصير (من: store_listing/google_play_description_ar.txt)
- [ ] وصف كامل
- [ ] رابط سياسة الخصوصية: `https://vitafit.online/privacy-policy`
- [ ] App Icon (512x512) - تم
- [ ] Feature Graphic (1024x500) - يحتاج تصميم
- [ ] Screenshots (8 صور للهاتف)

#### 4. Content Rating
- [ ] ملء استبيان التصنيف العمري
- [ ] التصنيف المتوقع: Everyone

#### 5. Data Safety
- [ ] ملء النموذج (استخدم: store_listing/DATA_SAFETY_FORM.md)

#### 6. App Release
- [ ] رفع AAB: `build/app/outputs/bundle/release/app-release.aab`
- [ ] اختيار: Production / Internal Testing
- [ ] Release Notes

---

### Apple App Store:

#### 1. Apple Developer Account
```
رابط: https://developer.apple.com
التكلفة: $99/سنة
```

#### 2. App Store Connect
- [ ] إنشاء تطبيق جديد
- [ ] Bundle ID: com.gym.fitness
- [ ] SKU: vitafit-ios-001

#### 3. معلومات التطبيق
- [ ] الاسم: VitaFit
- [ ] الوصف
- [ ] الكلمات المفتاحية
- [ ] رابط الدعم
- [ ] رابط سياسة الخصوصية

#### 4. Screenshots
- [ ] iPhone 6.7" (1290x2796)
- [ ] iPhone 6.5" (1242x2688)
- [ ] iPhone 5.5" (1242x2208)
- [ ] iPad Pro 12.9" (اختياري)

#### 5. App Privacy
- [ ] ملء نموذج جمع البيانات

#### 6. Build & Submit
```bash
# على macOS:
flutter build ios --release
# من Xcode: Product > Archive > Distribute App
```

---

## 🔴 إعداد الخادم (Backend) - مهم جداً!

### المطلوب قبل النشر:

#### 1. تشغيل API Server
```bash
# تأكد من أن الخادم يعمل على:
https://vitafit.online/api
```

#### 2. API Endpoints المطلوبة:
```
POST /auth/trainee/register
POST /auth/trainee/login
POST /auth/trainer/login
POST /auth/admin/login
POST /auth/forgot-password
POST /auth/verify-otp
POST /auth/reset-password
GET  /profile
PUT  /profile
GET  /trainers
GET  /classes
GET  /workshops
GET  /meals
GET  /workouts
GET  /products
POST /orders
GET  /notifications
...
```

#### 3. Firebase Admin SDK
- [ ] إعداد لإرسال الإشعارات من الخادم

#### 4. PayMob
- [ ] إنشاء حساب PayMob
- [ ] الحصول على API Key
- [ ] تكوين Webhook

---

## 📞 معلومات الدعم

```
البريد الإلكتروني: support@vitafit.online
سياسة الخصوصية: https://vitafit.online/privacy-policy
شروط الاستخدام: https://vitafit.online/terms
```

---

## 🎉 بعد النشر

1. **مراقبة التقييمات** - الرد على مراجعات المستخدمين
2. **Analytics** - مراقبة Firebase Analytics
3. **Crashlytics** - متابعة تقارير الأعطال
4. **التحديثات** - إصدار تحديثات دورية

---

## أوامر مفيدة:

```bash
# بناء APK
flutter build apk --release

# بناء AAB
flutter build appbundle --release

# بناء iOS
flutter build ios --release

# تحديث الأيقونات
flutter pub run flutter_launcher_icons

# تشغيل التحليل
flutter analyze

# تنظيف المشروع
flutter clean && flutter pub get
```

---

**VitaFit v1.0.0** - جاهز للنشر! 🚀
