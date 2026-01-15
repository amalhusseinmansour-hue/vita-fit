# دليل النشر السريع - Quick Deployment Guide

## الملفات الجاهزة للرفع | Files Ready for Deployment

### 1. Backend (Node.js API)
- **الموقع**: `C:\Users\HP\Desktop\gym\backend-deploy.zip` (50KB)
- **الوجهة**: `vitafit.online/backend`

### 2. تطبيق Android (APKs)
- **APK الكامل**: `build\app\outputs\flutter-apk\app-release.apk` (54.8MB)
- **APKs مقسمة**:
  - `app-arm64-v8a-release.apk` (21.4MB) - الأجهزة الحديثة
  - `app-armeabi-v7a-release.apk` (19.0MB) - الأجهزة القديمة
  - `app-x86_64-release.apk` (22.5MB) - المحاكيات

### 3. صفحات الويب
- `web_pages/privacy.html` - سياسة الخصوصية
- `web_pages/terms.html` - الشروط والأحكام

---

## خطوات نشر Backend

### الخطوة 1: إعداد .env
1. افتح `backend\.env.production`
2. أضف بيانات MongoDB Atlas الخاصة بك:
```
MONGODB_URI=mongodb+srv://YOUR_USER:YOUR_PASSWORD@cluster.mongodb.net/vitafit
JWT_SECRET=your-super-secret-key-here-make-it-very-long
```

### الخطوة 2: الرفع عبر SSH
```bash
# من PowerShell أو Terminal
scp -P 65002 "C:\Users\HP\Desktop\gym\backend-deploy.zip" u126213189@82.25.83.217:~/domains/vitafit.online/
```

### الخطوة 3: إعداد الخادم
```bash
# الاتصال بالخادم
ssh -p 65002 u126213189@82.25.83.217

# فك الضغط والتثبيت
cd ~/domains/vitafit.online
unzip -o backend-deploy.zip -d backend
cd backend

# نسخ ملف البيئة
mv .env.production .env
# أو تعديله مباشرة: nano .env

# تثبيت الحزم
npm install

# تشغيل PM2
npm install -g pm2
pm2 start server.js --name vitafit-api
pm2 save
pm2 startup
```

---

## رفع صفحات الخصوصية

```bash
scp -P 65002 "C:\Users\HP\Desktop\gym\web_pages\privacy.html" u126213189@82.25.83.217:~/domains/vitafit.online/public_html/privacy.html

scp -P 65002 "C:\Users\HP\Desktop\gym\web_pages\terms.html" u126213189@82.25.83.217:~/domains/vitafit.online/public_html/terms.html
```

---

## إنشاء حساب MongoDB Atlas (مجاني)

1. اذهب إلى: https://www.mongodb.com/cloud/atlas
2. أنشئ حساب مجاني
3. أنشئ Cluster جديد (M0 Free Tier)
4. أضف Database User بـ username و password
5. أضف IP Address: `0.0.0.0/0` للوصول من أي مكان
6. انسخ Connection String واستبدل `<password>` بكلمة المرور

---

## التحقق من عمل API

بعد النشر، اختبر:
```
https://vitafit.online/api
```

يجب أن يظهر:
```json
{
  "message": "GYM Fitness API Server",
  "version": "1.0.0",
  "status": "Running"
}
```

---

## رفع التطبيق على Google Play

1. اذهب إلى: https://play.google.com/console
2. أنشئ تطبيق جديد
3. ارفع: `app-release.apk` أو الـ APKs المقسمة
4. أضف الوصف من: `store_assets/app_description_ar.txt`
5. أضف رابط الخصوصية: `https://vitafit.online/privacy.html`

---

## الملفات المطلوبة للمتجر

- [ ] أيقونة التطبيق (512x512) PNG
- [ ] صورة Feature Graphic (1024x500) PNG
- [ ] Screenshots (3-8 صور من الهاتف)
- [ ] وصف قصير (80 حرف)
- [ ] وصف كامل (4000 حرف) - جاهز في `store_assets/`
