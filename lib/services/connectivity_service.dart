import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// خدمة فحص الاتصال بالإنترنت
class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  static bool _isConnected = true;
  static bool _isInitialized = false;

  /// تهيئة الخدمة
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // فحص الحالة الأولية
      final results = await _connectivity.checkConnectivity();
      _isConnected = _hasConnection(results);

      // الاستماع للتغييرات
      _subscription = _connectivity.onConnectivityChanged.listen(
        (results) {
          final wasConnected = _isConnected;
          _isConnected = _hasConnection(results);

          if (wasConnected != _isConnected) {
            _connectionController.add(_isConnected);
            debugPrint('Connectivity changed: ${_isConnected ? "Online" : "Offline"}');
          }
        },
        onError: (e) {
          debugPrint('Connectivity error: $e');
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing connectivity service: $e');
      _isConnected = true; // نفترض الاتصال في حالة الخطأ
    }
  }

  /// التحقق من وجود اتصال
  static bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
  }

  /// الحصول على حالة الاتصال الحالية
  static bool get isConnected => _isConnected;

  /// الحصول على حالة الاتصال الحالية (async)
  static Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isConnected = _hasConnection(results);
      return _isConnected;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return true; // نفترض الاتصال في حالة الخطأ
    }
  }

  /// stream لمتابعة تغييرات الاتصال
  static Stream<bool> get connectionStream => _connectionController.stream;

  /// الحصول على نوع الاتصال الحالي
  static Future<String> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();

      if (results.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      } else if (results.contains(ConnectivityResult.mobile)) {
        return 'Mobile Data';
      } else if (results.contains(ConnectivityResult.ethernet)) {
        return 'Ethernet';
      } else {
        return 'None';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// إيقاف الخدمة
  static void dispose() {
    try {
      _subscription?.cancel();
      _subscription = null;
      // Don't close the broadcast controller - it can't be reused after closing
      // Just cancel the subscription
      _isInitialized = false;
    } catch (e) {
      debugPrint('Error disposing connectivity service: $e');
    }
  }
}
