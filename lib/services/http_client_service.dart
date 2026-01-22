import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'connectivity_service.dart';

/// نتيجة طلب HTTP
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isNetworkError;
  final bool isTimeout;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
    this.isNetworkError = false,
    this.isTimeout = false,
  });

  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.failure(String error, {int? statusCode, bool isNetworkError = false, bool isTimeout = false}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
      isNetworkError: isNetworkError,
      isTimeout: isTimeout,
    );
  }
}

/// خدمة HTTP Client مع retry logic ومعالجة الأخطاء
class HttpClientService {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// إرسال GET request مع retry
  static Future<ApiResponse<Map<String, dynamic>>> get(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
    int maxRetries = _maxRetries,
    bool checkConnectivity = true,
  }) async {
    return _executeWithRetry(
      () => _doGet(url, headers: headers, timeout: timeout ?? _defaultTimeout),
      maxRetries: maxRetries,
      checkConnectivity: checkConnectivity,
    );
  }

  /// إرسال POST request مع retry
  static Future<ApiResponse<Map<String, dynamic>>> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    Duration? timeout,
    int maxRetries = _maxRetries,
    bool checkConnectivity = true,
  }) async {
    return _executeWithRetry(
      () => _doPost(url, headers: headers, body: body, timeout: timeout ?? _defaultTimeout),
      maxRetries: maxRetries,
      checkConnectivity: checkConnectivity,
    );
  }

  /// إرسال PUT request مع retry
  static Future<ApiResponse<Map<String, dynamic>>> put(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    Duration? timeout,
    int maxRetries = _maxRetries,
    bool checkConnectivity = true,
  }) async {
    return _executeWithRetry(
      () => _doPut(url, headers: headers, body: body, timeout: timeout ?? _defaultTimeout),
      maxRetries: maxRetries,
      checkConnectivity: checkConnectivity,
    );
  }

  /// إرسال DELETE request مع retry
  static Future<ApiResponse<Map<String, dynamic>>> delete(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
    int maxRetries = _maxRetries,
    bool checkConnectivity = true,
  }) async {
    return _executeWithRetry(
      () => _doDelete(url, headers: headers, timeout: timeout ?? _defaultTimeout),
      maxRetries: maxRetries,
      checkConnectivity: checkConnectivity,
    );
  }

  /// تنفيذ الطلب مع إعادة المحاولة
  static Future<ApiResponse<Map<String, dynamic>>> _executeWithRetry(
    Future<ApiResponse<Map<String, dynamic>>> Function() request, {
    required int maxRetries,
    required bool checkConnectivity,
  }) async {
    // فحص الاتصال أولاً
    if (checkConnectivity && !ConnectivityService.isConnected) {
      return ApiResponse.failure(
        'لا يوجد اتصال بالإنترنت',
        isNetworkError: true,
      );
    }

    int attempts = 0;
    ApiResponse<Map<String, dynamic>>? lastResponse;

    while (attempts < maxRetries) {
      attempts++;

      try {
        final response = await request();

        // نجاح أو خطأ غير قابل لإعادة المحاولة
        if (response.success || !_shouldRetry(response)) {
          return response;
        }

        lastResponse = response;

        // انتظار قبل إعادة المحاولة
        if (attempts < maxRetries) {
          debugPrint('Retrying request (attempt $attempts/$maxRetries)...');
          await Future.delayed(_retryDelay * attempts);
        }
      } catch (e) {
        debugPrint('Request error (attempt $attempts): $e');
        lastResponse = ApiResponse.failure(
          _getErrorMessage(e),
          isNetworkError: e is SocketException,
          isTimeout: e is TimeoutException,
        );

        if (attempts < maxRetries && _shouldRetryException(e)) {
          await Future.delayed(_retryDelay * attempts);
        } else {
          break;
        }
      }
    }

    return lastResponse ?? ApiResponse.failure('فشل الاتصال بالخادم');
  }

  /// تحديد ما إذا كان يجب إعادة المحاولة
  static bool _shouldRetry(ApiResponse response) {
    if (response.isNetworkError || response.isTimeout) return true;
    final statusCode = response.statusCode ?? 0;
    return statusCode >= 500 || statusCode == 429; // Server errors or rate limit
  }

  /// تحديد ما إذا كان يجب إعادة المحاولة للاستثناء
  static bool _shouldRetryException(dynamic e) {
    return e is SocketException || e is TimeoutException || e is HttpException;
  }

  /// الحصول على رسالة خطأ مفهومة
  static String _getErrorMessage(dynamic e) {
    if (e is SocketException) {
      return 'لا يمكن الاتصال بالخادم';
    } else if (e is TimeoutException) {
      return 'انتهت مهلة الاتصال';
    } else if (e is HttpException) {
      return 'خطأ في الاتصال';
    } else if (e is FormatException) {
      return 'خطأ في تنسيق البيانات';
    }
    return 'حدث خطأ غير متوقع';
  }

  // ==================== HTTP Methods Implementation ====================

  static Future<ApiResponse<Map<String, dynamic>>> _doGet(
    String url, {
    Map<String, String>? headers,
    required Duration timeout,
  }) async {
    final response = await http.get(
      Uri.parse(url),
      headers: _buildHeaders(headers),
    ).timeout(timeout);

    return _processResponse(response);
  }

  static Future<ApiResponse<Map<String, dynamic>>> _doPost(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    required Duration timeout,
  }) async {
    final response = await http.post(
      Uri.parse(url),
      headers: _buildHeaders(headers),
      body: body is String ? body : jsonEncode(body),
    ).timeout(timeout);

    return _processResponse(response);
  }

  static Future<ApiResponse<Map<String, dynamic>>> _doPut(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    required Duration timeout,
  }) async {
    final response = await http.put(
      Uri.parse(url),
      headers: _buildHeaders(headers),
      body: body is String ? body : jsonEncode(body),
    ).timeout(timeout);

    return _processResponse(response);
  }

  static Future<ApiResponse<Map<String, dynamic>>> _doDelete(
    String url, {
    Map<String, String>? headers,
    required Duration timeout,
  }) async {
    final response = await http.delete(
      Uri.parse(url),
      headers: _buildHeaders(headers),
    ).timeout(timeout);

    return _processResponse(response);
  }

  /// بناء headers
  static Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// معالجة الاستجابة
  static ApiResponse<Map<String, dynamic>> _processResponse(http.Response response) {
    try {
      final statusCode = response.statusCode;
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};

      if (statusCode >= 200 && statusCode < 300) {
        return ApiResponse.success(
          body is Map<String, dynamic> ? body : {'data': body},
          statusCode: statusCode,
        );
      }

      // معالجة أخطاء HTTP
      String errorMessage;
      if (body is Map && body.containsKey('message')) {
        errorMessage = body['message'];
      } else if (body is Map && body.containsKey('error')) {
        errorMessage = body['error'];
      } else {
        errorMessage = _getHttpErrorMessage(statusCode);
      }

      return ApiResponse.failure(
        errorMessage,
        statusCode: statusCode,
      );
    } catch (e) {
      return ApiResponse.failure(
        'خطأ في معالجة الاستجابة',
        statusCode: response.statusCode,
      );
    }
  }

  /// الحصول على رسالة خطأ HTTP
  static String _getHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'طلب غير صالح';
      case 401:
        return 'غير مصرح - يرجى تسجيل الدخول';
      case 403:
        return 'غير مسموح بالوصول';
      case 404:
        return 'المورد غير موجود';
      case 409:
        return 'تعارض في البيانات';
      case 422:
        return 'بيانات غير صالحة';
      case 429:
        return 'طلبات كثيرة - حاول لاحقاً';
      case 500:
        return 'خطأ في الخادم';
      case 502:
        return 'الخادم غير متاح مؤقتاً';
      case 503:
        return 'الخدمة غير متاحة';
      case 504:
        return 'انتهت مهلة الخادم';
      default:
        return 'خطأ غير معروف ($statusCode)';
    }
  }
}
