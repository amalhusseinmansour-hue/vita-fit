# VitaFit - Test Data & Manual Testing Guide

## Test APK
**File:** `VitaFit-Test.apk`
**Location:** `C:\Users\HP\Desktop\gym\VitaFit-Test.apk`

---

## Test Accounts

### Trainee (Client) Accounts
| Email | Password | Name |
|-------|----------|------|
| sara@test.com | 123456 | سارة أحمد |
| noura@test.com | 123456 | نورة محمد |
| mariam@test.com | 123456 | مريم علي |

### Trainer Account
| Email | Password | Name |
|-------|----------|------|
| trainer@vitafit.com | 123456 | Ahmed Trainer |

### Admin Panel (vitafit.online/admin)
| Email | Password | Role |
|-------|----------|------|
| superadmin@vitafit.com | admin123 | Super Admin |
| admin@vitafit.com | admin123 | Admin |

---

## API Endpoints

**Base URL:** `https://vitafit.online/api`

### Authentication
- POST `/auth/trainee/login` - Trainee login
- POST `/auth/trainee/register` - Trainee registration
- POST `/auth/trainer/login` - Trainer login
- POST `/user/fcm-token` - Update FCM token (requires auth)

### Trainee Endpoints
- GET `/trainee/profile` - Get profile
- PUT `/trainee/profile` - Update profile
- GET `/trainee/dashboard` - Dashboard data
- GET `/trainee/workouts` - Get workouts
- GET `/trainee/nutrition` - Get nutrition plans
- GET `/trainee/sessions` - Get training sessions

### Trainer Endpoints
- GET `/trainer/profile` - Get profile
- GET `/trainer/trainees` - Get trainees list
- GET `/trainer/sessions` - Get sessions

### Store
- GET `/products` - Get products
- GET `/products/{id}` - Get product details
- POST `/orders` - Create order
- GET `/orders` - Get orders

---

## Manual Testing Checklist

### 1. Installation
- [ ] Install VitaFit-Test.apk on Android device
- [ ] App opens without crash
- [ ] Splash screen appears
- [ ] App navigates to login/welcome screen

### 2. Trainee Flow
- [ ] Login with sara@test.com / 123456
- [ ] Dashboard loads correctly
- [ ] Profile section accessible
- [ ] Workouts section loads
- [ ] Nutrition plans section loads
- [ ] Sessions section loads
- [ ] Store/Products section loads
- [ ] Logout works

### 3. Trainer Flow
- [ ] Login with trainer@vitafit.com / 123456
- [ ] Trainer dashboard loads
- [ ] Trainees list accessible
- [ ] Sessions management works
- [ ] Profile section works
- [ ] Logout works

### 4. Registration (New User)
- [ ] Navigate to registration
- [ ] Fill form with test data
- [ ] Submit registration
- [ ] Login with new account

### 5. Store & Orders
- [ ] Browse products
- [ ] View product details
- [ ] Add to cart (if implemented)
- [ ] Checkout process

### 6. Profile Management
- [ ] View profile
- [ ] Edit profile info
- [ ] Change avatar (if implemented)
- [ ] Update measurements

### 7. Notifications
- [ ] FCM token sent to server on login
- [ ] Push notification received (test from Firebase Console)

### 8. Offline Behavior
- [ ] App handles no internet gracefully
- [ ] Shows appropriate error messages

### 9. UI/UX
- [ ] RTL layout correct (Arabic)
- [ ] Fonts display properly
- [ ] Colors and theme consistent
- [ ] Navigation intuitive
- [ ] Loading indicators show

---

## Testing Notifications

### From Firebase Console:
1. Go to Firebase Console > Engage > Messaging
2. Click "Create your first campaign"
3. Select "Firebase Notification messages"
4. Enter:
   - Title: "اختبار الإشعارات"
   - Text: "هذا إشعار تجريبي من VitaFit"
5. Click "Send test message"
6. Enter device FCM token (from app logs)
7. Click "Test"

### Get FCM Token:
After login, the app should log the FCM token. Check:
- Android Studio Logcat (filter by "FCM" or "token")
- Or check the database: `SELECT fcm_token FROM trainees WHERE email='sara@test.com'`

---

## Known Issues & Notes

1. **App Bundle Issue:** Due to NDK configuration, AAB build fails. Use APK for testing and publishing.

2. **iOS Testing:** Requires Mac with Xcode. iOS notifications need APNs key uploaded to Firebase.

3. **First Login:** FCM token is registered on first login.

---

## Quick API Tests

### Test Trainee Login:
```bash
curl -X POST https://vitafit.online/api/auth/trainee/login \
  -H "Content-Type: application/json" \
  -d '{"email":"sara@test.com","password":"123456"}'
```

### Test Trainer Login:
```bash
curl -X POST https://vitafit.online/api/auth/trainer/login \
  -H "Content-Type: application/json" \
  -d '{"email":"trainer@vitafit.com","password":"123456"}'
```

### Test FCM Token Update:
```bash
curl -X POST https://vitafit.online/api/user/fcm-token \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"fcm_token":"test_fcm_token_123"}'
```

---

## Contact

- **Website:** https://vitafit.online
- **Admin Panel:** https://vitafit.online/admin
- **API Base:** https://vitafit.online/api
