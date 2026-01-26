import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../firebase_options.dart';

/// Firebase Service - Handles all Firebase functionality
class FirebaseService {
  static bool _initialized = false;
  static bool _firebaseAvailable = false;
  static FirebaseAnalytics? _analytics;
  static FirebaseMessaging? _messaging;

  /// Check if Firebase is available
  static bool get isAvailable => _firebaseAvailable;

  /// Get analytics instance
  static FirebaseAnalytics? get analytics => _analytics;

  /// Initialize Firebase services
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _firebaseAvailable = true;
      _initialized = true;

      // Initialize Analytics
      _analytics = FirebaseAnalytics.instance;

      // Initialize Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Initialize Messaging
      _messaging = FirebaseMessaging.instance;
      await _setupMessaging();

      debugPrint('Firebase initialized successfully');
    } catch (e, stack) {
      debugPrint('Firebase initialization error: $e');
      _firebaseAvailable = false;
      _initialized = true;
    }
  }

  /// Setup Firebase Messaging
  static Future<void> _setupMessaging() async {
    if (_messaging == null) return;

    // Request permission
    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('Notification permission: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await _messaging!.getToken();
    debugPrint('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.notification?.title}');
      // Handle foreground notification
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    if (!_firebaseAvailable || _messaging == null) return null;
    return await _messaging!.getToken();
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    if (!_firebaseAvailable || _messaging == null) return;
    await _messaging!.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    if (!_firebaseAvailable || _messaging == null) return;
    await _messaging!.unsubscribeFromTopic(topic);
  }

  // ============ Crashlytics ============

  /// Log error to Crashlytics
  static Future<void> logError(dynamic error, StackTrace? stack, {String? reason}) async {
    if (!_firebaseAvailable) return;
    await FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
  }

  /// Log message to Crashlytics
  static Future<void> logMessage(String message) async {
    if (!_firebaseAvailable) return;
    await FirebaseCrashlytics.instance.log(message);
  }

  /// Set user identifier for Crashlytics
  static Future<void> setCrashlyticsUser(String userId) async {
    if (!_firebaseAvailable) return;
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Set custom key for Crashlytics
  static Future<void> setCrashlyticsCustomKey(String key, dynamic value) async {
    if (!_firebaseAvailable) return;
    await FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
  }

  // ============ Analytics ============

  static Future<void> logScreenView(String screenName) async {
    if (!_firebaseAvailable || _analytics == null) return;
    await _analytics!.logScreenView(screenName: screenName);
  }

  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    if (!_firebaseAvailable || _analytics == null) return;
    await _analytics!.logEvent(
      name: name,
      parameters: parameters?.map((k, v) => MapEntry(k, v)),
    );
  }

  static Future<void> logLogin(String method) async {
    if (!_firebaseAvailable || _analytics == null) return;
    await _analytics!.logLogin(loginMethod: method);
  }

  static Future<void> logSignUp(String method) async {
    if (!_firebaseAvailable || _analytics == null) return;
    await _analytics!.logSignUp(signUpMethod: method);
  }

  static Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
  }) async {
    if (!_firebaseAvailable || _analytics == null) return;
    await _analytics!.logPurchase(
      currency: currency,
      value: value,
      transactionId: transactionId,
    );
  }

  static Future<void> setUserId(String userId) async {
    if (!_firebaseAvailable || _analytics == null) return;
    await _analytics!.setUserId(id: userId);
  }

  static Future<void> setUserProperty(String name, String value) async {
    if (!_firebaseAvailable || _analytics == null) return;
    await _analytics!.setUserProperty(name: name, value: value);
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
}
