import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'hive_storage_service.dart';

/// Biometric Authentication Service
/// Handles Face ID, Touch ID, and Fingerprint authentication
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricTypeKey = 'biometric_type';

  /// Check if device supports biometric authentication
  static Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('Biometric device support check error: $e');
      return false;
    }
  }

  /// Check if biometrics are available and enrolled
  static Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Biometric availability check error: $e');
      return false;
    }
  }

  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Get biometrics error: $e');
      return [];
    }
  }

  /// Check if Face ID is available
  static Future<bool> isFaceIdAvailable() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  /// Check if Fingerprint is available
  static Future<bool> isFingerprintAvailable() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  /// Get biometric type name in Arabic
  static Future<String> getBiometricTypeName() async {
    final biometrics = await getAvailableBiometrics();
    if (biometrics.contains(BiometricType.face)) {
      return 'بصمة الوجه';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'بصمة الإصبع';
    } else if (biometrics.contains(BiometricType.strong)) {
      return 'المصادقة البيومترية';
    }
    return 'غير متاح';
  }

  /// Authenticate user with biometrics
  static Future<bool> authenticate({
    String reason = 'يرجى التحقق من هويتك للمتابعة',
  }) async {
    try {
      final canAuth = await canCheckBiometrics();
      final isSupported = await isDeviceSupported();

      if (!canAuth || !isSupported) {
        debugPrint('Biometric not available');
        return false;
      }

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  /// Authenticate for login
  static Future<bool> authenticateForLogin() async {
    return authenticate(reason: 'تسجيل الدخول باستخدام بصمة الوجه');
  }

  /// Authenticate for sensitive action
  static Future<bool> authenticateForSensitiveAction() async {
    return authenticate(reason: 'يرجى التحقق من هويتك لإتمام العملية');
  }

  /// Check if biometric login is enabled
  static bool isBiometricEnabled() {
    return HiveStorageService.getBool(_biometricEnabledKey) ?? false;
  }

  /// Enable biometric login
  static Future<void> enableBiometric() async {
    await HiveStorageService.setBool(_biometricEnabledKey, true);
    final typeName = await getBiometricTypeName();
    await HiveStorageService.setString(_biometricTypeKey, typeName);
  }

  /// Disable biometric login
  static Future<void> disableBiometric() async {
    await HiveStorageService.setBool(_biometricEnabledKey, false);
    await HiveStorageService.remove(_biometricTypeKey);
  }

  /// Get stored biometric type
  static String? getStoredBiometricType() {
    return HiveStorageService.getString(_biometricTypeKey);
  }
}
