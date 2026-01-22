import 'dart:convert';
import 'hive_storage_service.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

/// خدمة إعدادات الدفع - تخزين واسترجاع إعدادات بوابات الدفع من السيرفر
class PaymentSettingsService {
  static const String _keyPaymentSettings = 'payment_settings';
  static const String _keyPaymobSettings = 'paymob_settings';
  static const String _keyGooglePaySettings = 'google_pay_settings';
  static const String _keyApplePaySettings = 'apple_pay_settings';
  static const String _keyLastSync = 'payment_settings_last_sync';

  // Default payment settings - معطلة افتراضياً حتى يفعّلها الأدمن
  static final Map<String, dynamic> _defaultSettings = {
    'paymob': {
      'enabled': false,
      'apiKey': '',
      'integrationId': '',
      'iframeId': '',
      'hmacSecret': '',
      'isProduction': false,
    },
    'googlePay': {
      'enabled': false,
      'merchantId': '',
      'merchantName': 'VitaFit',
      'isProduction': false,
      'allowedCardNetworks': ['VISA', 'MASTERCARD', 'MADA'],
      'gateway': 'paymob',
      'gatewayMerchantId': '',
    },
    'applePay': {
      'enabled': false,
      'merchantId': '',
      'merchantName': 'VitaFit',
      'isProduction': false,
      'supportedNetworks': ['visa', 'masterCard', 'mada'],
    },
    'cod': {
      'enabled': true,
      'fee': 0,
    },
    'supportedCurrencies': ['AED', 'SAR', 'KWD', 'QAR', 'BHD', 'OMR', 'EGP', 'JOD', 'USD', 'GBP'],
    'defaultCurrency': 'AED',
  };

  /// جلب الإعدادات من السيرفر ومزامنتها محلياً
  static Future<void> syncSettingsFromServer() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/settings'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          final serverSettings = result['data'] as Map<String, dynamic>;
          await _updateLocalSettingsFromServer(serverSettings);

          // حفظ وقت آخر مزامنة
          await HiveStorageService.setInt(_keyLastSync, DateTime.now().millisecondsSinceEpoch);
        }
      }
    } catch (e) {
      print('Error syncing settings from server: $e');
    }
  }

  /// تحديث الإعدادات المحلية من بيانات السيرفر
  static Future<void> _updateLocalSettingsFromServer(Map<String, dynamic> serverSettings) async {
    final localSettings = Map<String, dynamic>.from(_defaultSettings);

    // تحديث إعدادات PayMob
    localSettings['paymob'] = {
      'enabled': serverSettings['paymobEnabled'] == true || serverSettings['paymobEnabled'] == 'true',
      'apiKey': serverSettings['paymobApiKey'] ?? '',
      'integrationId': serverSettings['paymobIntegrationId'] ?? '',
      'iframeId': serverSettings['paymobIframeId'] ?? '',
      'hmacSecret': serverSettings['paymobHmacSecret'] ?? '',
      'isProduction': serverSettings['paymobProduction'] == true || serverSettings['paymobProduction'] == 'true',
    };

    // تحديث إعدادات Google Pay
    localSettings['googlePay'] = {
      'enabled': serverSettings['googlePayEnabled'] == true || serverSettings['googlePayEnabled'] == 'true',
      'merchantId': serverSettings['googlePayMerchantId'] ?? '',
      'merchantName': serverSettings['googlePayMerchantName'] ?? 'VitaFit',
      'isProduction': serverSettings['googlePayProduction'] == true || serverSettings['googlePayProduction'] == 'true',
      'allowedCardNetworks': ['VISA', 'MASTERCARD', 'MADA'],
      'gateway': 'paymob',
      'gatewayMerchantId': serverSettings['googlePayGatewayMerchantId'] ?? '',
    };

    // تحديث إعدادات Apple Pay
    localSettings['applePay'] = {
      'enabled': serverSettings['applePayEnabled'] == true || serverSettings['applePayEnabled'] == 'true',
      'merchantId': serverSettings['applePayMerchantId'] ?? '',
      'merchantName': serverSettings['applePayMerchantName'] ?? 'VitaFit',
      'isProduction': serverSettings['applePayProduction'] == true || serverSettings['applePayProduction'] == 'true',
      'supportedNetworks': ['visa', 'masterCard', 'mada'],
    };

    // تحديث إعدادات الدفع عند الاستلام
    localSettings['cod'] = {
      'enabled': serverSettings['codEnabled'] == true || serverSettings['codEnabled'] == 'true',
      'fee': double.tryParse(serverSettings['codFee']?.toString() ?? '0') ?? 0,
    };

    // تحديث العملة الافتراضية
    if (serverSettings['defaultCurrency'] != null) {
      localSettings['defaultCurrency'] = serverSettings['defaultCurrency'];
    }

    await savePaymentSettings(localSettings);
  }

  /// التحقق من الحاجة للمزامنة (كل ساعة)
  static bool needsSync() {
    try {
      final lastSync = HiveStorageService.getInt(_keyLastSync) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      // مزامنة كل ساعة
      return (now - lastSync) > 3600000;
    } catch (e) {
      return true;
    }
  }

  // Get all payment settings
  static Future<Map<String, dynamic>> getPaymentSettings({bool forceSync = false}) async {
    try {
      // التحقق من الحاجة للمزامنة (فقط إذا لم يتم استدعاء الدالة من داخل المزامنة)
      if (forceSync || needsSync()) {
        // تجنب المزامنة المتكررة
        await HiveStorageService.setInt(_keyLastSync, DateTime.now().millisecondsSinceEpoch);
        await syncSettingsFromServer();
      }

      final settingsJson = HiveStorageService.getString(_keyPaymentSettings);
      if (settingsJson != null) {
        return Map<String, dynamic>.from(jsonDecode(settingsJson));
      }
      return Map<String, dynamic>.from(_defaultSettings);
    } catch (e) {
      print('Error getting payment settings: $e');
      return Map<String, dynamic>.from(_defaultSettings);
    }
  }

  // Save all payment settings
  static Future<bool> savePaymentSettings(Map<String, dynamic> settings) async {
    try {
      await HiveStorageService.setString(_keyPaymentSettings, jsonEncode(settings));
      return true;
    } catch (e) {
      print('Error saving payment settings: $e');
      return false;
    }
  }

  // ==================== PayMob Settings ====================

  static Future<Map<String, dynamic>> getPaymobSettings() async {
    final settings = await getPaymentSettings();
    return Map<String, dynamic>.from(settings['paymob'] ?? _defaultSettings['paymob']);
  }

  static Future<bool> savePaymobSettings(Map<String, dynamic> paymobSettings) async {
    final settings = await getPaymentSettings();
    settings['paymob'] = paymobSettings;
    return await savePaymentSettings(settings);
  }

  static Future<bool> isPaymobEnabled() async {
    final paymob = await getPaymobSettings();
    return paymob['enabled'] == true &&
           (paymob['apiKey']?.isNotEmpty ?? false);
  }

  // ==================== Google Pay Settings ====================

  static Future<Map<String, dynamic>> getGooglePaySettings() async {
    final settings = await getPaymentSettings();
    return Map<String, dynamic>.from(settings['googlePay'] ?? _defaultSettings['googlePay']);
  }

  static Future<bool> saveGooglePaySettings(Map<String, dynamic> googlePaySettings) async {
    final settings = await getPaymentSettings();
    settings['googlePay'] = googlePaySettings;
    return await savePaymentSettings(settings);
  }

  static Future<bool> isGooglePayEnabled() async {
    final googlePay = await getGooglePaySettings();
    return googlePay['enabled'] == true;
  }

  // ==================== Apple Pay Settings ====================

  static Future<Map<String, dynamic>> getApplePaySettings() async {
    final settings = await getPaymentSettings();
    return Map<String, dynamic>.from(settings['applePay'] ?? _defaultSettings['applePay']);
  }

  static Future<bool> saveApplePaySettings(Map<String, dynamic> applePaySettings) async {
    final settings = await getPaymentSettings();
    settings['applePay'] = applePaySettings;
    return await savePaymentSettings(settings);
  }

  static Future<bool> isApplePayEnabled() async {
    final applePay = await getApplePaySettings();
    return applePay['enabled'] == true;
  }

  // ==================== Payment Method Toggle ====================

  static Future<bool> togglePaymentMethod(String method, bool enabled) async {
    final settings = await getPaymentSettings();

    switch (method.toLowerCase()) {
      case 'paymob':
        if (settings['paymob'] != null) {
          settings['paymob']['enabled'] = enabled;
        }
        break;
      case 'googlepay':
      case 'google_pay':
        if (settings['googlePay'] != null) {
          settings['googlePay']['enabled'] = enabled;
        }
        break;
      case 'applepay':
      case 'apple_pay':
        if (settings['applePay'] != null) {
          settings['applePay']['enabled'] = enabled;
        }
        break;
    }

    return await savePaymentSettings(settings);
  }

  // ==================== Get Available Payment Methods ====================

  static Future<List<PaymentMethod>> getAvailablePaymentMethods() async {
    final settings = await getPaymentSettings();
    final List<PaymentMethod> methods = [];

    // PayMob (Card payments)
    final paymob = settings['paymob'];
    if (paymob != null && paymob['enabled'] == true) {
      methods.add(PaymentMethod(
        id: 'paymob',
        name: 'Credit/Debit Card',
        nameAr: 'بطاقة ائتمان/خصم',
        icon: 'credit_card',
        isEnabled: true,
      ));
    }

    // Google Pay
    final googlePay = settings['googlePay'];
    if (googlePay != null && googlePay['enabled'] == true) {
      methods.add(PaymentMethod(
        id: 'google_pay',
        name: 'Google Pay',
        nameAr: 'Google Pay',
        icon: 'google',
        isEnabled: true,
      ));
    }

    // Apple Pay
    final applePay = settings['applePay'];
    if (applePay != null && applePay['enabled'] == true) {
      methods.add(PaymentMethod(
        id: 'apple_pay',
        name: 'Apple Pay',
        nameAr: 'Apple Pay',
        icon: 'apple',
        isEnabled: true,
      ));
    }

    return methods;
  }

  // ==================== Currency Settings ====================

  static Future<String> getDefaultCurrency() async {
    final settings = await getPaymentSettings();
    return settings['defaultCurrency'] ?? 'AED';
  }

  static Future<bool> setDefaultCurrency(String currency) async {
    final settings = await getPaymentSettings();
    settings['defaultCurrency'] = currency;
    return await savePaymentSettings(settings);
  }

  static Future<List<String>> getSupportedCurrencies() async {
    final settings = await getPaymentSettings();
    return List<String>.from(settings['supportedCurrencies'] ?? ['AED', 'SAR', 'USD']);
  }

  // ==================== Validation ====================

  static Future<Map<String, bool>> validatePaymentSetup() async {
    final settings = await getPaymentSettings();

    final paymob = settings['paymob'] ?? {};
    final googlePay = settings['googlePay'] ?? {};
    final applePay = settings['applePay'] ?? {};

    return {
      'paymobConfigured': (paymob['apiKey']?.isNotEmpty ?? false) &&
                          (paymob['integrationId']?.isNotEmpty ?? false),
      'googlePayConfigured': googlePay['enabled'] == true,
      'applePayConfigured': applePay['enabled'] == true,
      'hasAtLeastOneMethod': (paymob['enabled'] == true) ||
                             (googlePay['enabled'] == true) ||
                             (applePay['enabled'] == true),
    };
  }
}

/// نموذج طريقة الدفع
class PaymentMethod {
  final String id;
  final String name;
  final String nameAr;
  final String icon;
  final bool isEnabled;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.icon,
    required this.isEnabled,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameAr': nameAr,
    'icon': icon,
    'isEnabled': isEnabled,
  };

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    nameAr: json['nameAr'] ?? '',
    icon: json['icon'] ?? '',
    isEnabled: json['isEnabled'] ?? false,
  );
}
