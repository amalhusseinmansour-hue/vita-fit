import 'package:flutter/foundation.dart';

/// Firebase Service - Disabled until iOS crash is resolved
/// This is a stub implementation that does nothing
class FirebaseService {
  static bool _initialized = false;
  static bool _firebaseAvailable = false;

  /// Check if Firebase is available
  static bool get isAvailable => _firebaseAvailable;

  /// Initialize Firebase services (currently disabled)
  static Future<void> initialize() async {
    if (_initialized) return;

    // Firebase is currently disabled
    debugPrint('Firebase is disabled - skipping initialization');
    _firebaseAvailable = false;
    _initialized = true;
  }

  /// Log error to Crashlytics (no-op when disabled)
  static Future<void> logError(dynamic error, StackTrace? stack, {String? reason}) async {
    // Disabled
  }

  /// Log message to Crashlytics (no-op when disabled)
  static Future<void> logMessage(String message) async {
    // Disabled
  }

  /// Set user identifier for Crashlytics (no-op when disabled)
  static Future<void> setCrashlyticsUser(String userId) async {
    // Disabled
  }

  /// Set custom key for Crashlytics (no-op when disabled)
  static Future<void> setCrashlyticsCustomKey(String key, dynamic value) async {
    // Disabled
  }

  // ============ Analytics (disabled) ============

  static Future<void> logScreenView(String screenName) async {
    // Disabled
  }

  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    // Disabled
  }

  static Future<void> logLogin(String method) async {
    // Disabled
  }

  static Future<void> logSignUp(String method) async {
    // Disabled
  }

  static Future<void> logPurchase({
    required String currency,
    required double value,
    String? transactionId,
  }) async {
    // Disabled
  }

  static Future<void> setUserId(String userId) async {
    // Disabled
  }

  static Future<void> setUserProperty(String name, String value) async {
    // Disabled
  }
}
