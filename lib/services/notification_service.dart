import 'package:flutter/foundation.dart';

/// Notification Service - Simplified version without Firebase
/// Firebase notifications will be added back after iOS crash is resolved
class NotificationService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('NotificationService: Firebase notifications disabled');
    _isInitialized = true;
  }

  // Get current FCM token (returns null when disabled)
  static Future<String?> getToken() async {
    return null;
  }

  // Subscribe to topic (no-op when disabled)
  static Future<void> subscribeToTopic(String topic) async {
    // Disabled
  }

  // Unsubscribe from topic (no-op when disabled)
  static Future<void> unsubscribeFromTopic(String topic) async {
    // Disabled
  }

  // Show local notification (no-op when disabled)
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('Notification: $title - $body');
  }

  // Cancel notification (no-op when disabled)
  static Future<void> cancelNotification(int id) async {
    // Disabled
  }

  // Cancel all notifications (no-op when disabled)
  static Future<void> cancelAllNotifications() async {
    // Disabled
  }
}
