# VitaFit Laravel Filament Backend

## متطلبات النظام
- PHP >= 8.1
- Composer
- MySQL / PostgreSQL
- Node.js & NPM

## التثبيت

### 1. نسخ الملفات
```bash
# انسخ مجلد laravel-backend إلى السيرفر
cd laravel-backend
```

### 2. تثبيت المتطلبات
```bash
composer install
```

### 3. إعداد ملف البيئة
```bash
cp .env.example .env
php artisan key:generate
```

### 4. إعداد قاعدة البيانات
قم بتعديل ملف `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=vitafit
DB_USERNAME=root
DB_PASSWORD=your_password
```

### 5. تشغيل Migrations
```bash
php artisan migrate
```

### 6. إنشاء مستخدم Admin
```bash
php artisan make:filament-user
```

### 7. نشر ملفات Filament
```bash
php artisan filament:install --panels
php artisan storage:link
```

### 8. تشغيل السيرفر
```bash
php artisan serve
```

## الوصول للوحة التحكم
```
http://localhost:8000/admin
```

## API Endpoints

### المصادقة (Authentication)
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/trainee/register` | تسجيل متدربة جديدة |
| POST | `/api/auth/trainee/login` | تسجيل دخول متدربة |
| POST | `/api/auth/trainer/login` | تسجيل دخول مدربة |
| POST | `/api/auth/forgot-password` | نسيت كلمة المرور |
| POST | `/api/auth/verify-otp` | التحقق من OTP |
| POST | `/api/auth/reset-password` | إعادة تعيين كلمة المرور |

### المتدربة (Trainee)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/trainee/profile` | الحصول على الملف الشخصي |
| PUT | `/api/trainee/profile` | تحديث الملف الشخصي |
| PUT | `/api/trainee/profile/health` | تحديث المعلومات الصحية |
| GET | `/api/trainee/dashboard` | لوحة التحكم |
| GET | `/api/trainee/smart-plan` | الخطة الذكية |

### المدربة (Trainer)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/trainer/profile` | الحصول على الملف الشخصي |
| PUT | `/api/trainer/profile` | تحديث الملف الشخصي |
| GET | `/api/trainer/dashboard` | لوحة التحكم |
| GET | `/api/trainer/trainees` | قائمة المتدربات |
| GET | `/api/trainer/statistics` | الإحصائيات |

### الجلسات (Sessions)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/trainer/sessions` | قائمة الجلسات |
| POST | `/api/trainer/sessions` | إنشاء جلسة جديدة |
| GET | `/api/trainer/sessions/{id}` | تفاصيل الجلسة |
| POST | `/api/trainer/sessions/{id}/start` | بدء الجلسة |
| POST | `/api/trainer/sessions/{id}/end` | إنهاء الجلسة |
| POST | `/api/trainer/sessions/{id}/cancel` | إلغاء الجلسة |

### المحادثات (Chat)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/trainee/conversations` | قائمة المحادثات |
| GET | `/api/trainee/conversations/{id}/messages` | رسائل المحادثة |
| POST | `/api/trainee/conversations` | إنشاء محادثة جديدة |
| POST | `/api/trainee/messages` | إرسال رسالة |
| POST | `/api/trainee/conversations/{id}/read` | تحديد كمقروءة |

### الإعدادات (Settings)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/settings` | جميع الإعدادات |
| GET | `/api/settings/{group}` | إعدادات مجموعة معينة |

### المنتجات (Products)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | قائمة المنتجات |
| GET | `/api/products/featured` | المنتجات المميزة |
| GET | `/api/products/{id}` | تفاصيل المنتج |

## الموارد في لوحة التحكم (Filament Resources)

### إدارة المستخدمين
- **المتدربات** - إدارة حسابات المتدربات والمعلومات الصحية
- **المدربات** - إدارة حسابات المدربات والتخصصات

### إدارة الاشتراكات
- **الاشتراكات** - إدارة خطط الاشتراك والجلسات

### إدارة التدريب
- **الجلسات** - إدارة جلسات التدريب وربط Zoom

### المتجر
- **المنتجات** - إدارة المنتجات والأسعار والمخزون
- **الطلبات** - إدارة طلبات الشراء والشحن

### النظام
- **الإعدادات** - إدارة إعدادات التطبيق

## إعداد Zoom للجلسات الأونلاين

1. أنشئ تطبيق Server-to-Server OAuth في [Zoom Marketplace](https://marketplace.zoom.us/)
2. احصل على:
   - Account ID
   - Client ID
   - Client Secret
3. أضفها في `.env`:
```env
ZOOM_ACCOUNT_ID=your_account_id
ZOOM_CLIENT_ID=your_client_id
ZOOM_CLIENT_SECRET=your_client_secret
```

## إعداد Paymob للمدفوعات

1. أنشئ حساب في [Paymob](https://paymob.com/)
2. احصل على:
   - API Key
   - Integration ID
   - iFrame ID
   - HMAC Secret
3. أضفها في `.env`:
```env
PAYMOB_API_KEY=your_api_key
PAYMOB_INTEGRATION_ID=your_integration_id
PAYMOB_IFRAME_ID=your_iframe_id
PAYMOB_HMAC_SECRET=your_hmac_secret
```

## إعداد FCM للإشعارات

1. أنشئ مشروع في [Firebase Console](https://console.firebase.google.com/)
2. احصل على Server Key من Cloud Messaging
3. أضفه في `.env`:
```env
FCM_SERVER_KEY=your_server_key
FCM_SENDER_ID=your_sender_id
```

## هيكل قاعدة البيانات

### الجداول الرئيسية
- `trainees` - بيانات المتدربات
- `trainers` - بيانات المدربات
- `subscriptions` - الاشتراكات
- `training_sessions` - جلسات التدريب
- `conversations` - المحادثات
- `messages` - الرسائل
- `products` - المنتجات
- `orders` - الطلبات
- `order_items` - عناصر الطلبات
- `settings` - إعدادات التطبيق

## ملاحظات هامة

1. تأكد من تشغيل `php artisan storage:link` لربط مجلد التخزين
2. استخدم HTTPS في البيئة الإنتاجية
3. قم بإعداد قيود CORS بشكل صحيح للـ API
4. استخدم queue workers للإشعارات والعمليات الطويلة

## الدعم

للمساعدة أو الاستفسارات، تواصل مع فريق التطوير.
