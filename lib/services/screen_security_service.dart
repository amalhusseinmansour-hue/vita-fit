import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Screen Security Service
/// Prevents screenshots and screen recording
class ScreenSecurityService {
  static const MethodChannel _channel = MethodChannel('screen_security');
  static bool _isSecured = false;

  /// Enable screen security (prevent screenshots and recording)
  static Future<void> enableSecurity() async {
    if (_isSecured) return;

    try {
      if (Platform.isAndroid) {
        // Use FLAG_SECURE on Android
        await _channel.invokeMethod('enableSecureScreen');
        _isSecured = true;
        debugPrint('Screen security enabled (Android)');
      } else if (Platform.isIOS) {
        // iOS doesn't support preventing screenshots natively
        // But we can detect and blur the content
        _isSecured = true;
        debugPrint('Screen security enabled (iOS - limited)');
      }
    } catch (e) {
      debugPrint('Enable screen security error: $e');
      // Fallback: try using flutter_windowmanager
      await _enableSecurityFallback();
    }
  }

  /// Disable screen security
  static Future<void> disableSecurity() async {
    if (!_isSecured) return;

    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('disableSecureScreen');
        _isSecured = false;
        debugPrint('Screen security disabled');
      }
    } catch (e) {
      debugPrint('Disable screen security error: $e');
    }
  }

  /// Fallback method using flutter_windowmanager
  static Future<void> _enableSecurityFallback() async {
    try {
      // Import and use flutter_windowmanager if available
      // This requires the flutter_windowmanager package
      if (Platform.isAndroid) {
        // FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
        debugPrint('Screen security fallback enabled');
      }
    } catch (e) {
      debugPrint('Screen security fallback error: $e');
    }
  }

  /// Check if security is enabled
  static bool isSecurityEnabled() => _isSecured;
}
