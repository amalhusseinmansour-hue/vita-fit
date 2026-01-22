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
  // Lazy initialization - only access after Firebase.initializeApp() is called
  static FirebaseMessaging? _messaging;
  static FirebaseAnalytics? _analytics;
  static FlutterLocalNotificationsPlugin? _localNotifications;

  static bool _initialized = false;

  // Getters for lazy initialization
  static FirebaseMessaging get _messagingInstance {
    _messaging ??= FirebaseMessaging.instance;
    return _messaging!;
  }

  static FirebaseAnalytics get _analyticsInstance {
    _analytics ??= FirebaseAnalytics.instance;
    return _analytics!;
  }

  static FlutterLocalNotificationsPlugin get _localNotificationsInstance {
    _localNotifications ??= FlutterLocalNotificationsPlugin();
    return _localNotifications!;
  }

  /// Initialize Firebase services
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firebase with platform-specific options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Crashlytics (not available on web)
      if (!kIsWeb) {
        await _initCrashlytics();
      }

      // Notifications are not fully supported on web
      if (!kIsWeb) {
        // Request notification permissions
        await _requestPermissions();

        // Initialize local notifications
        await _initLocalNotifications();

        // Configure message handlers
        _configureMessageHandlers();

        // Get and save FCM token
        await _saveFcmToken();
      }

      _initialized = true;
    } catch (e) {
      // Firebase not configured - skip initialization
      // This allows the app to work without Firebase in demo mode
      debugPrint('Firebase initialization error: $e');
    }
  }

  /// Initialize Crashlytics
  static Future<void> _initCrashlytics() async {
    // Disable Crashlytics in debug mode
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Pass all uncaught "fatal" errors to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Log error to Crashlytics
  static Future<void> logError(dynamic error, StackTrace? stack, {String? reason}) async {
    // Don't try to log if Firebase isn't initialized
    if (!_initialized) {
      debugPrint('Firebase not initialized, skipping error log: $error');
      return;
    }
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: reason ?? 'Non-fatal error',
        fatal: false,
      );
    } catch (e) {
      debugPrint('Crashlytics error logging failed: $e');
    }
  }

  /// Log message to Crashlytics
  static Future<void> logMessage(String message) async {
    try {
      await FirebaseCrashlytics.instance.log(message);
    } catch (e) {
      debugPrint('Crashlytics message logging failed: $e');
    }
  }

  /// Set user identifier for Crashlytics
  static Future<void> setCrashlyticsUser(String userId) async {
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    } catch (e) {
      debugPrint('Crashlytics user ID setting failed: $e');
    }
  }

  /// Set custom key for Crashlytics
  static Future<void> setCrashlyticsCustomKey(String key, dynamic value) async {
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
    } catch (e) {
      debugPrint('Crashlytics custom key setting failed: $e');
    }
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    final settings = await _messagingInstance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // User granted permission
    }
  }

  /// Initialize local notifications
  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsInstance.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const channel = AndroidNotificationChannel(
      'vitafit_channel',
      'VitaFit Notifications',
      description: 'Notifications from VitaFit app',
      importance: Importance.high,
    );

    await _localNotificationsInstance
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Configure message handlers
  static void _configureMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await _showLocalNotification(
        title: notification.title ?? 'VitaFit',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle background messages (must be top-level function)
  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background message
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    // Navigate to specific screen based on notification data
    final data = message.data;
    if (data.containsKey('screen')) {
      // Handle navigation
    }
  }

  /// Handle local notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle navigation based on payload
  }

  /// Show local notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'vitafit_channel',
      'VitaFit Notifications',
      channelDescription: 'Notifications from VitaFit app',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsInstance.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Get and save FCM token
  static Future<void> _saveFcmToken() async {
    try {
      final token = await _messagingInstance.getToken();
      if (token != null) {
        // Save token locally using Hive
        await HiveStorageService.setString('fcm_token', token);

        // Send token to server if user is logged in
        final authToken = HiveStorageService.getString('token');
        if (authToken != null) {
          await _sendTokenToServer(token);
        }
      }

      // Listen for token refresh
      _messagingInstance.onTokenRefresh.listen((newToken) async {
        await HiveStorageService.setString('fcm_token', newToken);
        await _sendTokenToServer(newToken);
      });
    } catch (e) {
      // Handle error
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Send FCM token to server
  static Future<void> _sendTokenToServer(String token) async {
    try {
      // Send to your backend API
      await ApiService.updateFcmToken(token);
    } catch (e) {
      // Handle error
    }
  }

  /// Get current FCM token
  static Future<String?> getFcmToken() async {
    try {
      return await _messagingInstance.getToken();
    } catch (e) {
      return null;
    }
  }

  // ============ Analytics ============

  /// Log screen view
  static Future<void> logScreenView(String screenName) async {
    try {
      await _analyticsInstance.logScreenView(screenName: screenName);
    } catch (e) {
      // Analytics not available
    }
  }

  /// Log event
  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      await _analyticsInstance.logEvent(
        name: name,
        parameters: parameters?.map((key, value) => MapEntry(key, value.toString())),
      );
    } catch (e) {
      // Analytics not available
    }
  }

  /// Log login
  static Future<void> logLogin(String method) async {
    try {
      await _analyticsInstance.logLogin(loginMethod: method);
    } catch (e) {
      // Analytics not available
    }
  }

  /// Log sign up
  static Future<void> logSignUp(String method) async {
    try {
      await _analyticsInstance.logSignUp(signUpMethod: method);
    } catch (e) {
      // Analytics not available
    }
  }

  /// Log purchase
  static Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
  }) async {
    try {
      await _analyticsInstance.logPurchase(
        currency: currency,
        value: value,
        transactionId: transactionId,
      );
    } catch (e) {
      // Analytics not available
    }
  }

  /// Set user ID
  static Future<void> setUserId(String userId) async {
    try {
      await _analyticsInstance.setUserId(id: userId);
    } catch (e) {
      // Analytics not available
    }
  }

  /// Set user property
  static Future<void> setUserProperty(String name, String value) async {
    try {
      await _analyticsInstance.setUserProperty(name: name, value: value);
    } catch (e) {
      // Analytics not available
    }
  }
}
