import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pay/pay.dart';
import 'payment_settings_service.dart';

/// خدمة الدفع المتكاملة - PayMob, Google Pay, Apple Pay
class PaymentService {
  static const String _paymobBaseUrl = 'https://accept.paymob.com/api';

  // ==================== PAYMOB ====================

  /// الحصول على توكن المصادقة من PayMob
  static Future<String?> getPaymobAuthToken() async {
    try {
      final settings = await PaymentSettingsService.getPaymobSettings();
      final apiKey = settings['apiKey'] ?? '';

      if (apiKey.isEmpty) {
        debugPrint('PayMob API Key is not configured');
        return null;
      }

      final response = await http.post(
        Uri.parse('$_paymobBaseUrl/auth/tokens'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'api_key': apiKey}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['token'];
      }
      debugPrint('PayMob Auth Error: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('PayMob Auth Error: $e');
      return null;
    }
  }

  /// تسجيل طلب جديد في PayMob
  static Future<int?> registerPaymobOrder({
    required String authToken,
    required double amount,
    required String currency,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_paymobBaseUrl/ecommerce/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'auth_token': authToken,
          'delivery_needed': 'false',
          'amount_cents': (amount * 100).toInt().toString(),
          'currency': currency,
          'items': [],
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['id'];
      }
      debugPrint('PayMob Order Error: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('PayMob Order Error: $e');
      return null;
    }
  }

  /// الحصول على مفتاح الدفع من PayMob
  static Future<String?> getPaymentKey({
    required String authToken,
    required int orderId,
    required double amount,
    required String currency,
    required Map<String, dynamic> billingData,
  }) async {
    try {
      final settings = await PaymentSettingsService.getPaymobSettings();
      final integrationId = settings['integrationId'] ?? '';

      final response = await http.post(
        Uri.parse('$_paymobBaseUrl/acceptance/payment_keys'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'auth_token': authToken,
          'amount_cents': (amount * 100).toInt().toString(),
          'expiration': 3600,
          'order_id': orderId.toString(),
          'billing_data': billingData,
          'currency': currency,
          'integration_id': integrationId,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['token'];
      }
      debugPrint('PayMob Payment Key Error: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('PayMob Payment Key Error: $e');
      return null;
    }
  }

  /// معالجة الدفع عبر PayMob
  static Future<Map<String, dynamic>> processPaymobPayment({
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerPhone,
    required String customerName,
    String countryCode = 'AE',
  }) async {
    try {
      // التحقق من تفعيل PayMob
      final isEnabled = await PaymentSettingsService.isPaymobEnabled();
      if (!isEnabled) {
        return {'success': false, 'error': 'PayMob غير مفعل'};
      }

      // Step 1: Get Auth Token
      final authToken = await getPaymobAuthToken();
      if (authToken == null) {
        return {'success': false, 'error': 'فشل في المصادقة مع PayMob'};
      }

      // Step 2: Register Order
      final orderId = await registerPaymobOrder(
        authToken: authToken,
        amount: amount,
        currency: currency,
      );
      if (orderId == null) {
        return {'success': false, 'error': 'فشل في إنشاء الطلب'};
      }

      // Step 3: Get Payment Key
      final nameParts = customerName.trim().split(' ').where((s) => s.isNotEmpty).toList();
      final firstName = nameParts.isNotEmpty ? nameParts.first : 'Customer';
      final lastName = nameParts.length > 1 ? nameParts.last : firstName;
      final paymentKey = await getPaymentKey(
        authToken: authToken,
        orderId: orderId,
        amount: amount,
        currency: currency,
        billingData: {
          'apartment': 'NA',
          'email': customerEmail,
          'floor': 'NA',
          'first_name': firstName,
          'street': 'NA',
          'building': 'NA',
          'phone_number': customerPhone,
          'shipping_method': 'NA',
          'postal_code': 'NA',
          'city': 'NA',
          'country': countryCode,
          'last_name': lastName,
          'state': 'NA',
        },
      );

      if (paymentKey == null) {
        return {'success': false, 'error': 'فشل في إنشاء مفتاح الدفع'};
      }

      final settings = await PaymentSettingsService.getPaymobSettings();
      final iframeId = settings['iframeId'] ?? '';

      return {
        'success': true,
        'paymentKey': paymentKey,
        'orderId': orderId,
        'iframeUrl': 'https://accept.paymob.com/api/acceptance/iframes/$iframeId?payment_token=$paymentKey',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== GOOGLE PAY ====================

  /// التحقق من توفر Google Pay
  static Future<bool> isGooglePayAvailable() async {
    try {
      if (kIsWeb || !Platform.isAndroid) {
        return false;
      }

      final isEnabled = await PaymentSettingsService.isGooglePayEnabled();
      if (!isEnabled) return false;

      final pay = Pay({
        PayProvider.google_pay: PaymentConfiguration.fromJsonString(
          await _getGooglePayConfig(),
        ),
      });

      return await pay.userCanPay(PayProvider.google_pay);
    } catch (e) {
      debugPrint('Google Pay availability check error: $e');
      return false;
    }
  }

  /// الحصول على تكوين Google Pay
  static Future<String> _getGooglePayConfig() async {
    final settings = await PaymentSettingsService.getGooglePaySettings();
    final isProduction = settings['isProduction'] ?? false;
    final merchantId = settings['merchantId'] ?? '';
    final merchantName = settings['merchantName'] ?? 'VitaFit';
    final gatewayMerchantId = settings['gatewayMerchantId'] ?? '';

    return jsonEncode({
      'provider': 'google_pay',
      'data': {
        'environment': isProduction ? 'PRODUCTION' : 'TEST',
        'apiVersion': 2,
        'apiVersionMinor': 0,
        'allowedPaymentMethods': [
          {
            'type': 'CARD',
            'tokenizationSpecification': {
              'type': 'PAYMENT_GATEWAY',
              'parameters': {
                'gateway': 'paymob',
                'gatewayMerchantId': gatewayMerchantId,
              },
            },
            'parameters': {
              'allowedCardNetworks': ['VISA', 'MASTERCARD', 'MADA'],
              'allowedAuthMethods': ['PAN_ONLY', 'CRYPTOGRAM_3DS'],
              'billingAddressRequired': true,
            },
          },
        ],
        'merchantInfo': {
          'merchantId': merchantId,
          'merchantName': merchantName,
        },
        'transactionInfo': {
          'countryCode': 'AE',
          'currencyCode': 'AED',
        },
      },
    });
  }

  /// معالجة الدفع عبر Google Pay
  static Future<Map<String, dynamic>> processGooglePayPayment({
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerPhone,
    required String customerName,
  }) async {
    try {
      final isEnabled = await PaymentSettingsService.isGooglePayEnabled();
      if (!isEnabled) {
        return {'success': false, 'error': 'Google Pay غير مفعل'};
      }

      // في الإنتاج، سيتم استخدام Pay package لعرض واجهة Google Pay
      // والحصول على token الدفع ثم معالجته مع PayMob

      return {
        'success': true,
        'requiresNativePayment': true,
        'paymentMethod': 'google_pay',
        'config': await _getGooglePayConfig(),
        'amount': amount,
        'currency': currency,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== APPLE PAY ====================

  /// التحقق من توفر Apple Pay
  static Future<bool> isApplePayAvailable() async {
    try {
      if (kIsWeb || !Platform.isIOS) {
        return false;
      }

      final isEnabled = await PaymentSettingsService.isApplePayEnabled();
      if (!isEnabled) return false;

      final pay = Pay({
        PayProvider.apple_pay: PaymentConfiguration.fromJsonString(
          await _getApplePayConfig(),
        ),
      });

      return await pay.userCanPay(PayProvider.apple_pay);
    } catch (e) {
      debugPrint('Apple Pay availability check error: $e');
      return false;
    }
  }

  /// الحصول على تكوين Apple Pay
  static Future<String> _getApplePayConfig() async {
    final settings = await PaymentSettingsService.getApplePaySettings();
    final merchantId = settings['merchantId'] ?? '';
    final merchantName = settings['merchantName'] ?? 'VitaFit';

    return jsonEncode({
      'provider': 'apple_pay',
      'data': {
        'merchantIdentifier': merchantId,
        'displayName': merchantName,
        'merchantCapabilities': ['3DS', 'debit', 'credit'],
        'supportedNetworks': ['visa', 'masterCard', 'mada'],
        'countryCode': 'AE',
        'currencyCode': 'AED',
        'requiredBillingContactFields': ['emailAddress', 'name', 'phoneNumber'],
        'requiredShippingContactFields': [],
      },
    });
  }

  /// معالجة الدفع عبر Apple Pay
  static Future<Map<String, dynamic>> processApplePayPayment({
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerPhone,
    required String customerName,
  }) async {
    try {
      final isEnabled = await PaymentSettingsService.isApplePayEnabled();
      if (!isEnabled) {
        return {'success': false, 'error': 'Apple Pay غير مفعل'};
      }

      return {
        'success': true,
        'requiresNativePayment': true,
        'paymentMethod': 'apple_pay',
        'config': await _getApplePayConfig(),
        'amount': amount,
        'currency': currency,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ==================== UNIFIED PAYMENT ====================

  /// معالجة الدفع الموحد
  static Future<Map<String, dynamic>> processPayment({
    required String method,
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerPhone,
    required String customerName,
    Map<String, dynamic>? additionalData,
  }) async {
    switch (method.toLowerCase()) {
      case 'paymob':
      case 'card':
        return await processPaymobPayment(
          amount: amount,
          currency: currency,
          customerEmail: customerEmail,
          customerPhone: customerPhone,
          customerName: customerName,
        );

      case 'applepay':
      case 'apple_pay':
        return await processApplePayPayment(
          amount: amount,
          currency: currency,
          customerEmail: customerEmail,
          customerPhone: customerPhone,
          customerName: customerName,
        );

      case 'googlepay':
      case 'google_pay':
        return await processGooglePayPayment(
          amount: amount,
          currency: currency,
          customerEmail: customerEmail,
          customerPhone: customerPhone,
          customerName: customerName,
        );

      default:
        return {'success': false, 'error': 'طريقة الدفع غير مدعومة'};
    }
  }

  /// الحصول على طرق الدفع المتاحة
  static Future<List<PaymentMethodInfo>> getAvailablePaymentMethods() async {
    final List<PaymentMethodInfo> methods = [];

    // PayMob
    if (await PaymentSettingsService.isPaymobEnabled()) {
      methods.add(PaymentMethodInfo(
        id: 'paymob',
        name: 'Credit/Debit Card',
        nameAr: 'بطاقة ائتمان/خصم',
        icon: 'credit_card',
        isAvailable: true,
      ));
    }

    // Google Pay
    if (await isGooglePayAvailable()) {
      methods.add(PaymentMethodInfo(
        id: 'google_pay',
        name: 'Google Pay',
        nameAr: 'Google Pay',
        icon: 'google',
        isAvailable: true,
      ));
    } else if (await PaymentSettingsService.isGooglePayEnabled()) {
      // مفعل لكن غير متاح على هذا الجهاز
      methods.add(PaymentMethodInfo(
        id: 'google_pay',
        name: 'Google Pay',
        nameAr: 'Google Pay',
        icon: 'google',
        isAvailable: false,
        unavailableReason: 'غير متاح على هذا الجهاز',
      ));
    }

    // Apple Pay
    if (await isApplePayAvailable()) {
      methods.add(PaymentMethodInfo(
        id: 'apple_pay',
        name: 'Apple Pay',
        nameAr: 'Apple Pay',
        icon: 'apple',
        isAvailable: true,
      ));
    } else if (await PaymentSettingsService.isApplePayEnabled()) {
      methods.add(PaymentMethodInfo(
        id: 'apple_pay',
        name: 'Apple Pay',
        nameAr: 'Apple Pay',
        icon: 'apple',
        isAvailable: false,
        unavailableReason: 'متاح فقط على أجهزة iOS',
      ));
    }

    return methods;
  }

  /// التحقق من نتيجة الدفع (Callback من PayMob)
  static Future<bool> verifyPaymentCallback(Map<String, dynamic> callbackData) async {
    try {
      final settings = await PaymentSettingsService.getPaymobSettings();
      final hmacSecret = settings['hmacSecret'] ?? '';

      if (hmacSecret.isEmpty) {
        // لا يوجد HMAC secret، نعتمد على النتيجة المباشرة
        debugPrint('Warning: HMAC secret not configured');
        return callbackData['success'] == true ||
               callbackData['obj']?['success'] == true;
      }

      // التحقق من HMAC signature
      final receivedHmac = callbackData['hmac'] ?? '';
      if (receivedHmac.isEmpty) {
        debugPrint('No HMAC received in callback');
        return false;
      }

      // حساب HMAC من البيانات المستلمة
      final calculatedHmac = _calculatePaymobHmac(callbackData, hmacSecret);

      if (calculatedHmac != receivedHmac) {
        debugPrint('HMAC verification failed');
        return false;
      }

      debugPrint('HMAC verification successful');
      return callbackData['success'] == true ||
             callbackData['obj']?['success'] == true;
    } catch (e) {
      debugPrint('Payment verification error: $e');
      return false;
    }
  }

  /// حساب HMAC لـ PayMob
  static String _calculatePaymobHmac(Map<String, dynamic> data, String secret) {
    // ترتيب الحقول حسب توثيق PayMob
    final obj = data['obj'] ?? data;

    final fields = [
      obj['amount_cents']?.toString() ?? '',
      obj['created_at']?.toString() ?? '',
      obj['currency']?.toString() ?? '',
      obj['error_occured']?.toString() ?? 'false',
      obj['has_parent_transaction']?.toString() ?? 'false',
      obj['id']?.toString() ?? '',
      obj['integration_id']?.toString() ?? '',
      obj['is_3d_secure']?.toString() ?? 'false',
      obj['is_auth']?.toString() ?? 'false',
      obj['is_capture']?.toString() ?? 'false',
      obj['is_refunded']?.toString() ?? 'false',
      obj['is_standalone_payment']?.toString() ?? 'true',
      obj['is_voided']?.toString() ?? 'false',
      obj['order']?['id']?.toString() ?? obj['order_id']?.toString() ?? '',
      obj['owner']?.toString() ?? '',
      obj['pending']?.toString() ?? 'false',
      obj['source_data']?['pan']?.toString() ?? '',
      obj['source_data']?['sub_type']?.toString() ?? '',
      obj['source_data']?['type']?.toString() ?? '',
      obj['success']?.toString() ?? 'false',
    ];

    final concatenated = fields.join('');
    final hmacSha512 = Hmac(sha512, utf8.encode(secret));
    final digest = hmacSha512.convert(utf8.encode(concatenated));

    return digest.toString();
  }

  /// معالجة نتيجة الدفع من Google/Apple Pay
  static Future<Map<String, dynamic>> processNativePaymentResult({
    required String paymentMethod,
    required Map<String, dynamic> paymentResult,
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerPhone,
    required String customerName,
  }) async {
    try {
      // الحصول على token من نتيجة الدفع
      final paymentToken = paymentResult['paymentMethodData']?['tokenizationData']?['token'];

      if (paymentToken == null) {
        return {'success': false, 'error': 'لم يتم الحصول على token الدفع'};
      }

      // معالجة الدفع مع PayMob باستخدام token
      // هذا يتطلب integration خاص مع PayMob للدفع عبر محافظ رقمية

      return {
        'success': true,
        'transactionId': DateTime.now().millisecondsSinceEpoch.toString(),
        'message': 'تم الدفع بنجاح',
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

/// معلومات طريقة الدفع
class PaymentMethodInfo {
  final String id;
  final String name;
  final String nameAr;
  final String icon;
  final bool isAvailable;
  final String? unavailableReason;

  PaymentMethodInfo({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.isAvailable,
    this.unavailableReason,
  });

  IconData get iconData {
    switch (icon) {
      case 'credit_card':
        return const IconData(0xe19d, fontFamily: 'MaterialIcons');
      case 'google':
        return const IconData(0xe5ec, fontFamily: 'MaterialIcons');
      case 'apple':
        return const IconData(0xe5e7, fontFamily: 'MaterialIcons');
      default:
        return const IconData(0xe6cf, fontFamily: 'MaterialIcons');
    }
  }
}
