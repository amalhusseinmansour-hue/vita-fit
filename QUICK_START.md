# 🚀 دليل البدء السريع - GYM Fitness App

## ⚡ التشغيل في 3 خطوات

### الخطوة 1️⃣: تثبيت Backend Dependencies

```bash
cd backend
npm install
```

⏱️ الوقت المتوقع: **2-3 دقائق**

---

### الخطوة 2️⃣: تشغيل MongoDB

**إذا كان MongoDB مثبت:**
```bash
# في terminal منفصل
mongod
```

**إذا لم يكن MongoDB مثبت:**

**Windows:**
1. نزّل من: https://www.mongodb.com/try/download/community
2. ثبّت مع الإعدادات الافتراضية
3. شغّل `mongod`

**أو استخدم MongoDB Atlas (Cloud - مجاني):**
1. اذهب إلى: https://www.mongodb.com/cloud/atlas/register
2. أنشئ حساب مجاني
3. أنشئ Cluster جديد (Free Tier)
4. احصل على Connection String
5. حدّث `MONGODB_URI` في `backend/.env`

---

### الخطوة 3️⃣: تشغيل Backend Server

```bash
# في نفس مجلد backend
npm start
```

**المتوقع:**
```
✅ Connected to MongoDB
🚀 Server running on port 5000
📊 Environment: development
```

**للتحقق:** افتح المتصفح على http://localhost:5000

يجب أن ترى:
```json
{
  "message": "GYM Fitness API Server",
  "version": "1.0.0",
  "status": "Running"
}
```

---

## ✅ تم! Backend جاهز

الآن Backend يعمل بالكامل على `http://localhost:5000`

---

## 📱 تشغيل Flutter App (اختياري)

### للويب:
```bash
flutter run -d chrome
```

### للأندرويد:
```bash
flutter run
```

### لبناء APK:
```bash
flutter build apk --release
```

APK سيكون في: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 اختبار API

### Test 1: التسجيل (Register)

```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Test User\",\"email\":\"test@test.com\",\"password\":\"123456\"}"
```

**المتوقع:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "name": "Test User",
      "email": "test@test.com"
    }
  }
}
```

### Test 2: تسجيل الدخول (Login)

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@test.com\",\"password\":\"123456\"}"
```

### Test 3: جلب المستخدم الحالي

```bash
curl -X GET http://localhost:5000/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 🔧 حل المشاكل الشائعة

### مشكلة: MongoDB لا يعمل

**الخطأ:** `MongoNetworkError: connect ECONNREFUSED`

**الحل:**
1. تأكد من تشغيل MongoDB: `mongod`
2. أو غيّر `MONGODB_URI` في `.env` لاستخدام Atlas

### مشكلة: Port 5000 مستخدم

**الخطأ:** `Error: listen EADDRINUSE: address already in use :::5000`

**الحل:**
```bash
# غيّر PORT في .env إلى 5001 أو أي رقم آخر
PORT=5001
```

### مشكلة: npm install فشل

**الحل:**
```bash
# امسح node_modules
rm -rf node_modules

# امسح package-lock.json
rm package-lock.json

# أعد التثبيت
npm install
```

---

## 📊 Endpoints المتاحة

### Authentication
- `POST /api/auth/register` - تسجيل مستخدم جديد
- `POST /api/auth/login` - تسجيل الدخول
- `GET /api/auth/me` - جلب بيانات المستخدم الحالي
- `PUT /api/auth/updatepassword` - تحديث كلمة المرور
- `POST /api/auth/logout` - تسجيل الخروج

### Workouts
- `GET /api/workouts` - جلب جميع التمارين
- `POST /api/workouts` - إنشاء تمرين جديد
- `GET /api/workouts/:id` - جلب تمرين محدد
- `PUT /api/workouts/:id` - تحديث تمرين
- `DELETE /api/workouts/:id` - حذف تمرين

### Meals
- `GET /api/meals` - جلب جميع الوجبات
- `POST /api/meals` - إنشاء وجبة جديدة
- `GET /api/meals/daily-nutrition` - جلب التغذية اليومية

### Subscriptions
- `POST /api/subscriptions/subscribe` - الاشتراك في خطة
- `GET /api/subscriptions/my-subscription` - جلب اشتراكي

### Trainers
- `GET /api/trainers` - جلب جميع المدربين
- `GET /api/trainers/:id` - جلب مدرب محدد

### Workshops
- `GET /api/workshops` - جلب جميع الورش
- `POST /api/workshops/:id/register` - التسجيل في ورشة
- `GET /api/workshops/user/my-workshops` - ورشي

### Progress
- `GET /api/progress` - جلب تاريخ التقدم
- `POST /api/progress` - إضافة سجل تقدم
- `GET /api/progress/stats/summary` - إحصائيات التقدم

---

## 📚 ملفات التوثيق

- **LAUNCH_READINESS_REPORT.md** - تقرير الجاهزية الشامل
- **INTEGRATION_COMPLETE_GUIDE.md** - أمثلة التكامل الكاملة
- **BACKEND_COMPLETE_GUIDE.md** - دليل الباك اند
- **PROJECT_STATUS.md** - حالة المشروع
- **README.md** - التوثيق الأساسي

---

## ✅ Checklist للإطلاق

- [ ] تثبيت MongoDB
- [ ] تشغيل `npm install` في backend
- [ ] تشغيل MongoDB (`mongod`)
- [ ] تشغيل Backend (`npm start`)
- [ ] التحقق من http://localhost:5000
- [ ] (اختياري) تشغيل Flutter app
- [ ] (اختياري) اختبار APIs

---

## 🎉 مبروك!

لديك الآن:
- ✅ Backend API جاهز ويعمل
- ✅ Database متصلة
- ✅ 30+ Endpoint جاهزة
- ✅ Authentication System
- ✅ Flutter App جاهز

**ابدأ التطوير الآن!** 🚀
