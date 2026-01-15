# دليل نشر تطبيق VitaFit
# VitaFit Deployment Guide

---

## المتطلبات المسبقة | Prerequisites

### للخادم (Backend):
- [ ] حساب استضافة (Hostinger/DigitalOcean/AWS)
- [ ] Node.js 18+
- [ ] MongoDB Atlas أو MongoDB على الخادم
- [ ] شهادة SSL (Let's Encrypt مجانية)
- [ ] Domain: vitafit.online

### للتطبيق (Flutter):
- [ ] Flutter SDK 3.9+
- [ ] Android Studio / Xcode
- [ ] حساب Google Play Console ($25)
- [ ] حساب Apple Developer ($99/year) - للـ iOS

### للدفع (Paymob):
- [ ] حساب Paymob (paymob.com)
- [ ] Integration credentials

### للإشعارات (Firebase):
- [ ] مشروع Firebase
- [ ] google-services.json (Android)
- [ ] GoogleService-Info.plist (iOS)

---

## الخطوة 1: إعداد الخادم (Backend)

### 1.1 رفع الملفات
```bash
# عبر SSH
ssh -p 65002 u126213189@82.25.83.217

# إنشاء مجلد Backend
cd ~/domains/vitafit.online
mkdir -p backend
cd backend

# رفع الملفات (من جهازك المحلي)
scp -P 65002 -r ./backend/* u126213189@82.25.83.217:~/domains/vitafit.online/backend/
```

### 1.2 إعداد البيئة
```bash
# على الخادم
cd ~/domains/vitafit.online/backend

# إنشاء ملف البيئة
nano .env
```

محتوى `.env`:
```env
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/vitafit
JWT_SECRET=your-super-secret-jwt-key-here-make-it-long
JWT_EXPIRE=30d
```

### 1.3 تثبيت وتشغيل
```bash
npm install
npm install -g pm2
pm2 start server.js --name vitafit-api
pm2 save
pm2 startup
```

### 1.4 إعداد Nginx (Reverse Proxy)
```nginx
server {
    listen 80;
    server_name vitafit.online;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name vitafit.online;

    ssl_certificate /etc/letsencrypt/live/vitafit.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/vitafit.online/privkey.pem;

    location /api {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location / {
        root /home/u126213189/domains/vitafit.online/public_html;
        index index.html;
    }
}
```

---

## الخطوة 2: إعداد Firebase

### 2.1 إنشاء مشروع Firebase
1. اذهب إلى [Firebase Console](https://console.firebase.google.com)
2. أنشئ مشروع جديد باسم "VitaFit"
3. فعّل Analytics

### 2.2 إضافة تطبيق Android
1. اذهب إلى Project Settings > Add App > Android
2. Package name: `com.gym.fitness`
3. حمّل `google-services.json`
4. ضعه في: `android/app/google-services.json`

### 2.3 إضافة تطبيق iOS
1. Add App > iOS
2. Bundle ID: `com.gym.fitness`
3. حمّل `GoogleService-Info.plist`
4. ضعه في: `ios/Runner/GoogleService-Info.plist`

### 2.4 تفعيل Cloud Messaging
1. Project Settings > Cloud Messaging
2. احتفظ بـ Server Key

---

## الخطوة 3: إعداد Paymob

### 3.1 إنشاء حساب
1. اذهب إلى [Paymob](https://accept.paymob.com)
2. سجّل حساب تاجر
3. أكمل التحقق

### 3.2 الحصول على المفاتيح
من Dashboard > Settings:
- API Key
- Integration ID
- IFRAME ID
- HMAC Secret

### 3.3 تحديث الإعدادات
في `lib/config/env_config.dart`:
```dart
static const String paymobApiKey = 'YOUR_ACTUAL_API_KEY';
static const String paymobIntegrationId = 'YOUR_ACTUAL_INTEGRATION_ID';
static const String paymobIframeId = 'YOUR_ACTUAL_IFRAME_ID';
```

---

## الخطوة 4: بناء التطبيق

### 4.1 تحديث الإصدار
في `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version: major.minor.patch+buildNumber
```

### 4.2 تحديث الحزم
```bash
flutter pub get
```

### 4.3 بناء APK للاختبار
```bash
flutter build apk --release
```
الملف في: `build/app/outputs/flutter-apk/app-release.apk`

### 4.4 بناء App Bundle للمتجر
```bash
flutter build appbundle --release
```
الملف في: `build/app/outputs/bundle/release/app-release.aab`

---

## الخطوة 5: النشر على Google Play

### 5.1 إعداد Play Console
1. اذهب إلى [Google Play Console](https://play.google.com/console)
2. أنشئ تطبيق جديد
3. أكمل المعلومات الأساسية

### 5.2 رفع الملفات
1. Production > Create Release
2. ارفع `app-release.aab`
3. أضف Release Notes

### 5.3 المعلومات المطلوبة
- [ ] App Icon (512x512)
- [ ] Feature Graphic (1024x500)
- [ ] Screenshots (هاتف + تابلت)
- [ ] Privacy Policy URL: https://vitafit.online/privacy
- [ ] Short Description
- [ ] Full Description
- [ ] Content Rating
- [ ] Target Age

### 5.4 إرسال للمراجعة
1. أكمل جميع الأقسام
2. اضغط "Review Release"
3. اضغط "Start Rollout"

---

## الخطوة 6: النشر على App Store (iOS)

### 6.1 المتطلبات
- جهاز Mac
- Xcode 15+
- حساب Apple Developer

### 6.2 البناء
```bash
flutter build ios --release
```

### 6.3 الرفع
1. افتح `ios/Runner.xcworkspace` في Xcode
2. Archive > Distribute App
3. App Store Connect

---

## الخطوة 7: رفع الصفحات القانونية

### 7.1 رفع Privacy Policy
```bash
scp -P 65002 ./web_pages/privacy.html u126213189@82.25.83.217:~/domains/vitafit.online/public_html/privacy.html
```

### 7.2 رفع Terms of Service
```bash
scp -P 65002 ./web_pages/terms.html u126213189@82.25.83.217:~/domains/vitafit.online/public_html/terms.html
```

---

## قائمة التحقق النهائية | Final Checklist

### Backend:
- [ ] API يعمل على https://vitafit.online/api
- [ ] قاعدة البيانات متصلة
- [ ] SSL مفعّل
- [ ] PM2 يدير العملية

### التطبيق:
- [ ] لا أخطاء في `flutter analyze`
- [ ] تم اختبار جميع الميزات
- [ ] تم اختبار الدفع
- [ ] تم اختبار الإشعارات

### المتجر:
- [ ] جميع الصور جاهزة
- [ ] الوصف مكتمل
- [ ] Privacy Policy مرفوعة
- [ ] تم الإرسال للمراجعة

---

## استكشاف الأخطاء | Troubleshooting

### خطأ في الاتصال بالـ API:
```bash
# تحقق من حالة الخادم
pm2 status
pm2 logs vitafit-api

# أعد تشغيل الخادم
pm2 restart vitafit-api
```

### خطأ في البناء:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### خطأ في التوقيع:
تأكد من صحة `key.properties`:
```properties
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=vitafit
storeFile=../vitafit-key.jks
```

---

## الدعم | Support

للمساعدة:
- Email: support@vitafit.online
- Documentation: هذا الملف

---

تم إعداد هذا الدليل بواسطة Claude Code
آخر تحديث: ديسمبر 2024
