import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    await NotificationService.showNotification(message);
  } catch (e) {
    debugPrint('Error handling background message: $e');
  }
}

class NotificationService {
  static FirebaseMessaging? _messaging;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'vitafit_channel',
    'VitaFit Notifications',
    description: 'Notifications from VitaFit app',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize local notifications first (always works)
    await _initializeLocalNotifications();

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    // Try to initialize Firebase (may fail if not configured)
    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission
      await _requestPermission();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showNotification(message);
      });

      // Handle notification tap when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationTap(message);
      });

      // Check if app was opened from notification
      final initialMessage = await _messaging?.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // Get and save FCM token
      await _saveFCMToken();

      // Listen for token refresh
      _messaging?.onTokenRefresh.listen((token) {
        _updateFCMToken(token);
      });

      debugPrint('Firebase notifications initialized successfully');
    } catch (e) {
      debugPrint('Firebase not configured, using local notifications only: $e');
    }

    _isInitialized = true;
  }

  static Future<void> _requestPermission() async {
    if (_messaging == null) return;

    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional notification permission');
      } else {
        debugPrint('User denied notification permission');
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
  }

  static Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'VitaFit',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            color: const Color(0xFFFF69B4),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  static void _handleNotificationTap(RemoteMessage message) {
    // Handle navigation based on notification data
    final data = message.data;
    debugPrint('Notification tapped with data: $data');

    // You can navigate to specific screens based on data
    // For example:
    // if (data['type'] == 'order') {
    //   Navigator.pushNamed(context, '/orders');
    // }
  }

  static Future<void> _saveFCMToken() async {
    if (_messaging == null) return;

    try {
      final token = await _messaging!.getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');

        // Save token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', token);

        // Send token to server
        await _updateFCMToken(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  static Future<void> _updateFCMToken(String token) async {
    try {
      // Check if user is logged in
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('authToken');

      if (authToken != null && authToken.isNotEmpty) {
        // Send token to server
        await ApiService.updateFCMToken(token);
      }
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  // Get current FCM token
  static Future<String?> getToken() async {
    if (_messaging == null) return null;
    return await _messaging!.getToken();
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    if (_messaging == null) return;
    await _messaging!.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    if (_messaging == null) return;
    await _messaging!.unsubscribeFromTopic(topic);
  }

  // Show local notification (for testing or custom notifications)
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFFF69B4),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}
