import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// خدمة التخزين الآمن للبيانات الحساسة
/// تستخدم Keychain على iOS و EncryptedSharedPreferences على Android
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // مفاتيح التخزين
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyApiKey = 'api_key';

  // ==================== Auth Token ====================

  /// حفظ توكن المصادقة
  static Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _keyAuthToken, value: token);
    } catch (e) {
      debugPrint('Error saving auth token: $e');
    }
  }

  /// الحصول على توكن المصادقة
  static Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _keyAuthToken);
    } catch (e) {
      debugPrint('Error reading auth token: $e');
      return null;
    }
  }

  /// حذف توكن المصادقة
  static Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: _keyAuthToken);
    } catch (e) {
      debugPrint('Error deleting auth token: $e');
    }
  }

  // ==================== Refresh Token ====================

  /// حفظ توكن التحديث
  static Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
    } catch (e) {
      debugPrint('Error saving refresh token: $e');
    }
  }

  /// الحصول على توكن التحديث
  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      debugPrint('Error reading refresh token: $e');
      return null;
    }
  }

  /// حذف توكن التحديث
  static Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _keyRefreshToken);
    } catch (e) {
      debugPrint('Error deleting refresh token: $e');
    }
  }

  // ==================== User Data ====================

  /// حفظ معرف المستخدم
  static Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _keyUserId, value: userId);
    } catch (e) {
      debugPrint('Error saving user id: $e');
    }
  }

  /// الحصول على معرف المستخدم
  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      debugPrint('Error reading user id: $e');
      return null;
    }
  }

  /// حفظ بريد المستخدم
  static Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: _keyUserEmail, value: email);
    } catch (e) {
      debugPrint('Error saving user email: $e');
    }
  }

  /// الحصول على بريد المستخدم
  static Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _keyUserEmail);
    } catch (e) {
      debugPrint('Error reading user email: $e');
      return null;
    }
  }

  // ==================== API Keys ====================

  /// حفظ مفتاح API
  static Future<void> saveApiKey(String key) async {
    try {
      await _storage.write(key: _keyApiKey, value: key);
    } catch (e) {
      debugPrint('Error saving API key: $e');
    }
  }

  /// الحصول على مفتاح API
  static Future<String?> getApiKey() async {
    try {
      return await _storage.read(key: _keyApiKey);
    } catch (e) {
      debugPrint('Error reading API key: $e');
      return null;
    }
  }

  // ==================== Generic Methods ====================

  /// حفظ قيمة بمفتاح مخصص
  static Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Error writing to secure storage: $e');
    }
  }

  /// قراءة قيمة بمفتاح مخصص
  static Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('Error reading from secure storage: $e');
      return null;
    }
  }

  /// حذف قيمة بمفتاح مخصص
  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('Error deleting from secure storage: $e');
    }
  }

  /// التحقق من وجود مفتاح
  static Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      debugPrint('Error checking key in secure storage: $e');
      return false;
    }
  }

  /// مسح جميع البيانات الآمنة (عند تسجيل الخروج)
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Error clearing secure storage: $e');
    }
  }

  /// مسح بيانات المصادقة فقط
  static Future<void> clearAuthData() async {
    try {
      await Future.wait([
        _storage.delete(key: _keyAuthToken),
        _storage.delete(key: _keyRefreshToken),
        _storage.delete(key: _keyUserId),
        _storage.delete(key: _keyUserEmail),
      ]);
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }
}
