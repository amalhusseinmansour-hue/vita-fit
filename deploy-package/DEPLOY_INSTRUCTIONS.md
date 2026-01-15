# تعليمات رفع الملفات للسيرفر

## الملفات المطلوب رفعها

### 1. Controllers (app/Http/Controllers/Api/)
- `PublicController.php` → `/home/user/public_html/app/Http/Controllers/Api/`

### 2. Models (app/Models/)
- `SubscriptionPlan.php` → `/home/user/public_html/app/Models/`
- `User.php` → `/home/user/public_html/app/Models/`
- `Subscription.php` → `/home/user/public_html/app/Models/` (استبدال الملف الموجود)

### 3. Routes
- `api.php` → `/home/user/public_html/routes/`

### 4. Migrations (database/migrations/)
- `2024_01_01_000000_create_users_table.php`
- `2024_01_01_000011_create_subscription_plans_table.php`

### 5. Seeders (database/seeders/)
- `DatabaseSeeder.php`
- `TrainerSeeder.php`
- `ProductSeeder.php`
- `SubscriptionPlanSeeder.php`
- `AdminSeeder.php`

---

## الأوامر المطلوب تشغيلها على السيرفر

```bash
cd /home/user/public_html

# مسح الكاش
php artisan config:clear
php artisan cache:clear
php artisan route:clear

# تشغيل migrations
php artisan migrate --force

# تشغيل seeders
php artisan db:seed --force

# أو لتشغيل seeder معين
php artisan db:seed --class=TrainerSeeder --force
php artisan db:seed --class=SubscriptionPlanSeeder --force

# إعادة بناء الكاش
php artisan config:cache
php artisan route:cache
```

---

## بيانات تسجيل الدخول للأدمن بعد التشغيل
- **Email:** admin@vitafit.online
- **Password:** Admin@123456

## بيانات المدربة للاختبار
- **Email:** sara@vitafit.online
- **Password:** 123456
