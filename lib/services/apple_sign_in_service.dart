import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'hive_storage_service.dart';
import 'api_service.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;

/// Apple Sign In Service
/// Required for App Store approval when other social logins are present
class AppleSignInService {
  /// Check if Apple Sign In is available on this device
  static Future<bool> isAvailable() async {
    try {
      if (!Platform.isIOS) return false;
      return await SignInWithApple.isAvailable();
    } catch (e) {
      debugPrint('Apple Sign In availability check error: $e');
      return false;
    }
  }

  /// Sign in with Apple
  /// Returns user data on success, throws exception on failure
  static Future<Map<String, dynamic>> signIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Get user info from credential
      final String? identityToken = credential.identityToken;
      final String? authorizationCode = credential.authorizationCode;
      final String? email = credential.email;
      final String? givenName = credential.givenName;
      final String? familyName = credential.familyName;
      final String userIdentifier = credential.userIdentifier ?? '';

      if (identityToken == null) {
        throw Exception('Failed to get identity token from Apple');
      }

      // Build full name if available
      String? fullName;
      if (givenName != null || familyName != null) {
        fullName = [givenName, familyName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');

        // Store the name for future use (Apple only sends it on first sign in)
        if (fullName.isNotEmpty) {
          await HiveStorageService.setString('apple_user_name_$userIdentifier', fullName);
        }
      } else {
        // Try to get stored name
        fullName = HiveStorageService.getString('apple_user_name_$userIdentifier');
      }

      // Store email for future use
      if (email != null && email.isNotEmpty) {
        await HiveStorageService.setString('apple_user_email_$userIdentifier', email);
      }

      // Send to backend for authentication
      final result = await _authenticateWithBackend(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
        email: email,
        fullName: fullName,
        userIdentifier: userIdentifier,
      );

      return result;
    } on SignInWithAppleAuthorizationException catch (e) {
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw Exception('تم إلغاء تسجيل الدخول');
        case AuthorizationErrorCode.failed:
          throw Exception('فشل تسجيل الدخول بـ Apple');
        case AuthorizationErrorCode.invalidResponse:
          throw Exception('استجابة غير صالحة من Apple');
        case AuthorizationErrorCode.notHandled:
          throw Exception('طلب غير مدعوم');
        case AuthorizationErrorCode.notInteractive:
          throw Exception('تسجيل الدخول غير تفاعلي');
        case AuthorizationErrorCode.unknown:
        default:
          throw Exception('خطأ غير معروف: ${e.message}');
      }
    } catch (e) {
      debugPrint('Apple Sign In Error: $e');
      rethrow;
    }
  }

  /// Authenticate with backend using Apple credentials
  static Future<Map<String, dynamic>> _authenticateWithBackend({
    required String identityToken,
    String? authorizationCode,
    String? email,
    String? fullName,
    required String userIdentifier,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/apple'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'identity_token': identityToken,
          'authorization_code': authorizationCode,
          'email': email,
          'full_name': fullName,
          'user_identifier': userIdentifier,
        }),
      ).timeout(ApiConfig.timeout);

      // Safe JSON parsing to prevent crash on malformed response
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error parsing response JSON: $e');
        return {
          'success': false,
          'message': 'استجابة غير صالحة من الخادم',
        };
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Save authentication data
        if (responseData['token'] != null) {
          await ApiService.saveToken(responseData['token']);
        }
        if (responseData['refresh_token'] != null) {
          await ApiService.saveRefreshToken(responseData['refresh_token']);
        }
        if (responseData['user'] != null) {
          await ApiService.saveUserData(responseData['user']);
          final userRole = responseData['user']['role'] ??
                          responseData['user']['type'] ??
                          'trainee';
          await ApiService.saveUserType(userRole);
        }

        return {
          'success': true,
          'data': responseData,
          'user': responseData['user'],
          'token': responseData['token'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل المصادقة مع الخادم',
        };
      }
    } catch (e) {
      debugPrint('Backend authentication error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم: $e',
      };
    }
  }

  /// Check if user has previously signed in with Apple
  static Future<bool> hasAppleCredential() async {
    try {
      final credentialState = await SignInWithApple.getCredentialState(
        _getStoredUserIdentifier() ?? '',
      );
      return credentialState == CredentialState.authorized;
    } catch (e) {
      return false;
    }
  }

  /// Get stored Apple user identifier
  static String? _getStoredUserIdentifier() {
    return HiveStorageService.getString('apple_user_identifier');
  }

  /// Store Apple user identifier
  static Future<void> _storeUserIdentifier(String identifier) async {
    await HiveStorageService.setString('apple_user_identifier', identifier);
  }

  /// Clear Apple Sign In data on logout
  static Future<void> signOut() async {
    // Clear all apple-related keys
    final keysToRemove = <String>[];
    // Note: Hive doesn't expose all keys directly, so we clear known patterns
    await HiveStorageService.remove('apple_user_identifier');
    // For other apple_ prefixed keys, they will be overwritten on next sign in
  }
}
