# Firebase Setup Guide for VitaFit

## Overview
This guide explains how to set up Firebase for VitaFit app to enable:
- Push Notifications (FCM)
- Analytics
- Crashlytics (optional)

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `VitaFit` or `vitafit-app`
4. Enable/Disable Google Analytics (recommended to enable)
5. Click "Create project"

---

## Step 2: Add Android App

1. In Firebase Console, click "Add app" > Android icon
2. Enter the following details:
   - **Android package name:** `com.gym.fitness`
   - **App nickname:** VitaFit Android
   - **Debug signing certificate SHA-1:** (optional for now, required for some features)

3. Download `google-services.json`
4. Place the file in: `android/app/google-services.json`

### Get SHA-1 Certificate (Windows)
```bash
cd android
./gradlew signingReport
```

Or using keytool:
```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

For release keystore:
```bash
keytool -list -v -keystore your-release-key.keystore -alias your-alias
```

---

## Step 3: Add iOS App

1. In Firebase Console, click "Add app" > iOS icon
2. Enter the following details:
   - **Apple bundle ID:** `com.vitafit.app`
   - **App nickname:** VitaFit iOS
   - **App Store ID:** (leave empty for now)

3. Download `GoogleService-Info.plist`
4. Place the file in: `ios/Runner/GoogleService-Info.plist`

### Important: Add to Xcode Project
1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click on `Runner` folder
3. Select "Add Files to Runner..."
4. Select `GoogleService-Info.plist`
5. Make sure "Copy items if needed" is checked
6. Click "Add"

---

## Step 4: Enable Cloud Messaging

1. In Firebase Console, go to **Project Settings** > **Cloud Messaging**
2. For iOS, you need to upload APNs Authentication Key:

### Generate APNs Key (iOS)
1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/authkeys/list)
2. Click "+" to create a new key
3. Enter key name: `VitaFit Push Key`
4. Check "Apple Push Notifications service (APNs)"
5. Click "Continue" > "Register"
6. Download the `.p8` file (save it securely!)
7. Note the **Key ID**
8. Note your **Team ID** (found in Membership section)

### Upload APNs Key to Firebase
1. In Firebase Console > Project Settings > Cloud Messaging
2. Under "Apple app configuration", click "Upload" for APNs Authentication Key
3. Upload the `.p8` file
4. Enter the Key ID
5. Enter your Team ID

---

## Step 5: Flutter Configuration

### pubspec.yaml
Make sure these dependencies are in your `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^16.3.0
```

### Initialize Firebase in main.dart
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}
```

---

## Step 6: Request Notification Permissions

```dart
Future<void> requestNotificationPermissions() async {
  final messaging = FirebaseMessaging.instance;

  // Request permission (iOS will show dialog, Android 13+ will show dialog)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Get FCM token
  String? token = await messaging.getToken();
  print('FCM Token: $token');

  // Send token to your server
  if (token != null) {
    await sendTokenToServer(token);
  }

  // Listen for token refresh
  messaging.onTokenRefresh.listen((newToken) {
    sendTokenToServer(newToken);
  });
}

Future<void> sendTokenToServer(String token) async {
  // Call your API to save the token
  // POST https://vitafit.online/api/user/fcm-token
  // Body: { "fcm_token": token }
}
```

---

## Step 7: Handle Incoming Notifications

```dart
void setupNotificationHandlers() {
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      // Show local notification
      showLocalNotification(message);
    }
  });

  // Handle notification tap when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification clicked!');
    // Navigate to specific screen based on message data
    handleNotificationClick(message);
  });
}
```

---

## Step 8: Send Test Notification

### From Firebase Console
1. Go to Firebase Console > Engage > Messaging
2. Click "Create your first campaign" > "Firebase Notification messages"
3. Enter notification title and text
4. Click "Send test message"
5. Enter your device's FCM token
6. Click "Test"

### From Backend (Laravel)
```php
// Using kreait/firebase-php package
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;

$factory = (new Factory)->withServiceAccount('/path/to/firebase-credentials.json');
$messaging = $factory->createMessaging();

$message = CloudMessage::withTarget('token', $fcmToken)
    ->withNotification([
        'title' => 'مرحباً!',
        'body' => 'لديك جلسة تدريب قادمة'
    ])
    ->withData([
        'type' => 'session_reminder',
        'session_id' => '123'
    ]);

$messaging->send($message);
```

---

## File Checklist

### Android
- [ ] `android/app/google-services.json` - Firebase config file
- [ ] `android/build.gradle` - Google services classpath
- [ ] `android/app/build.gradle` - Google services plugin applied

### iOS
- [ ] `ios/Runner/GoogleService-Info.plist` - Firebase config file
- [ ] Added to Xcode project
- [ ] APNs key uploaded to Firebase Console

### Flutter
- [ ] `firebase_core` package installed
- [ ] `firebase_messaging` package installed
- [ ] Firebase initialized in `main.dart`
- [ ] Permission request implemented
- [ ] Token sent to server
- [ ] Notification handlers set up

---

## Troubleshooting

### Android Issues
1. **Build fails after adding google-services.json**
   - Make sure package name in `google-services.json` matches `android/app/build.gradle`
   - Run `flutter clean` then `flutter pub get`

2. **Notifications not received**
   - Check if FCM token is valid
   - Verify google-services.json is in correct location
   - Check Android notification channel settings

### iOS Issues
1. **Notifications not received**
   - Verify APNs key is uploaded to Firebase
   - Check Bundle ID matches Firebase config
   - Ensure push notification capability is added in Xcode
   - Test on real device (simulator doesn't receive push)

2. **Token is null**
   - APNs might not be configured correctly
   - Check provisioning profile has push notification enabled

### Common Issues
1. **Token changes frequently**
   - This is normal, always listen to `onTokenRefresh`

2. **Background notifications not working**
   - Ensure background handler is a top-level function
   - Check `Info.plist` has `remote-notification` in `UIBackgroundModes`

---

## Production Checklist

- [ ] Replace debug google-services.json with production one (if different project)
- [ ] Upload production APNs key
- [ ] Test on real devices (both Android and iOS)
- [ ] Verify server can send notifications
- [ ] Test all notification scenarios:
  - [ ] App in foreground
  - [ ] App in background
  - [ ] App terminated
  - [ ] Notification click navigation

---

## Useful Links

- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
- [FCM Flutter Package](https://pub.dev/packages/firebase_messaging)
- [Apple Developer Portal](https://developer.apple.com/)
