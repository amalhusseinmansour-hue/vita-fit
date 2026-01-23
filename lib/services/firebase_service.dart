import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'hive_storage_service.dart';
import '../firebase_options.dart';
import 'api_service.dart';

/// Firebase Service for handling Push Notifications, Analytics, and Crashlytics
class FirebaseService {
  static FirebaseMessaging? _messaging;
  static FirebaseAnalytics? _analytics;
  static FlutterLocalNotificationsPlugin? _localNotifications;

  static bool _initialized = false;
  static bool _firebaseAvailable = false;

  /// Check if Firebase is available
  static bool get isAvailable => _firebaseAvailable;

  /// Initialize Firebase services
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firebase Core first
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _firebaseAvailable = true;
      debugPrint('Firebase Core initialized');

      // Initialize other services only if Firebase Core succeeded
      if (_firebaseAvailable && !kIsWeb) {
        await _initCrashlyticsSafely();
        await _initNotificationsSafely();
      }

      _initialized = true;
      debugPrint('Firebase fully initialized');
    } catch (e, stack) {
      debugPrint('Firebase initialization failed: $e');
      debugPrint('Stack: $stack');
      _firebaseAvailable = false;
      _initialized = true; // Mark as initialized to prevent retry
    }
  }

  /// Initialize Crashlytics safely
  static Future<void> _initCrashlyticsSafely() async {
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
      debugPrint('Crashlytics initialized');
    } catch (e) {
      debugPrint('Crashlytics init failed: $e');
    }
  }

  /// Initialize notifications safely
  static Future<void> _initNotificationsSafely() async {
    try {
      _messaging = FirebaseMessaging.instance;
      _localNotifications = FlutterLocalNotificationsPlugin();

      // Request permissions
      await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false, // Already requested above
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _localNotifications!.initialize(
        const InitializationSettings(android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Setup message handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Get FCM token
      await _saveFcmToken();

      debugPrint('Notifications initialized');
    } catch (e) {
      debugPrint('Notifications init failed: $e');
    }
  }

  /// Log error to Crashlytics
  static Future<void> logError(dynamic error, StackTrace? stack, {String? reason}) async {
    if (!_firebaseAvailable) return;
    try {
      await FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
    } catch (e) {
      debugPrint('Crashlytics error logging failed: $e');
    }
  }

  /// Log message to Crashlytics
  static Future<void> logMessage(String message) async {
    if (!_firebaseAvailable) return;
    try {
      await FirebaseCrashlytics.instance.log(message);
    } catch (e) {
      debugPrint('Crashlytics message logging failed: $e');
    }
  }

  /// Set user identifier for Crashlytics
  static Future<void> setCrashlyticsUser(String userId) async {
    if (!_firebaseAvailable) return;
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (e) {
      debugPrint('Crashlytics user ID setting failed: $e');
    }
  }

  /// Set custom key for Crashlytics
  static Future<void> setCrashlyticsCustomKey(String key, dynamic value) async {
    if (!_firebaseAvailable) return;
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
    } catch (e) {
      debugPrint('Crashlytics custom key setting failed: $e');
    }
  }

  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      final notification = message.notification;
      if (notification != null && _localNotifications != null) {
        await _localNotifications!.show(
          DateTime.now().millisecondsSinceEpoch.remainder(100000),
          notification.title ?? 'VitaFit',
          notification.body ?? '',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'vitafit_channel',
              'VitaFit Notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error handling foreground message: $e');
    }
  }

  /// Handle background messages
  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background message
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    // Navigate to specific screen based on notification data
  }

  /// Handle local notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle navigation based on payload
  }

  /// Get and save FCM token
  static Future<void> _saveFcmToken() async {
    if (_messaging == null) return;
    try {
      final token = await _messaging!.getToken();
      if (token != null) {
        await HiveStorageService.setString('fcm_token', token);
        final authToken = HiveStorageService.getString('token');
        if (authToken != null) {
          await _sendTokenToServer(token);
        }
      }
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Send FCM token to server
  static Future<void> _sendTokenToServer(String token) async {
    try {
      await ApiService.updateFcmToken(token);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get current FCM token
  static Future<String?> getFcmToken() async {
    if (_messaging == null) return null;
    try {
      return await _messaging!.getToken();
    } catch (e) {
      return null;
    }
  }

  // ============ Analytics ============

  static Future<void> logScreenView(String screenName) async {
    if (!_firebaseAvailable) return;
    try {
      _analytics ??= FirebaseAnalytics.instance;
      await _analytics!.logScreenView(screenName: screenName);
    } catch (e) {
      // Ignore
    }
  }

  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    if (!_firebaseAvailable) return;
    try {
      _analytics ??= FirebaseAnalytics.instance;
      await _analytics!.logEvent(
        name: name,
        parameters: parameters?.map((key, value) => MapEntry(key, value.toString())),
      );
    } catch (e) {
      // Ignore
    }
  }

  static Future<void> logLogin(String method) async {
    if (!_firebaseAvailable) return;
    try {
      _analytics ??= FirebaseAnalytics.instance;
      await _analytics!.logLogin(loginMethod: method);
    } catch (e) {
      // Ignore
    }
  }

  static Future<void> logSignUp(String method) async {
    if (!_firebaseAvailable) return;
    try {
      _analytics ??= FirebaseAnalytics.instance;
      await _analytics!.logSignUp(signUpMethod: method);
    } catch (e) {
      // Ignore
    }
  }

  static Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
  }) async {
    if (!_firebaseAvailable) return;
    try {
      _analytics ??= FirebaseAnalytics.instance;
      await _analytics!.logPurchase(
        currency: currency,
        value: value,
        transactionId: transactionId,
      );
    } catch (e) {
      // Ignore
    }
  }

  static Future<void> setUserId(String userId) async {
    if (!_firebaseAvailable) return;
    try {
      _analytics ??= FirebaseAnalytics.instance;
      await _analytics!.setUserId(id: userId);
    } catch (e) {
      // Ignore
    }
  }

  static Future<void> setUserProperty(String name, String value) async {
    if (!_firebaseAvailable) return;
    try {
      _analytics ??= FirebaseAnalytics.instance;
      await _analytics!.setUserProperty(name: name, value: value);
    } catch (e) {
      // Ignore
    }
  }
}
