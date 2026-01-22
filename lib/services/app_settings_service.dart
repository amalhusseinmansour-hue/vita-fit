import 'package:flutter/material.dart';
import 'hive_storage_service.dart';

/// خدمة إعدادات التطبيق العامة
class AppSettingsService {
  // مفاتيح التخزين
  static const String _keyLanguage = 'app_language';
  static const String _keyCountry = 'app_country';
  static const String _keyCurrency = 'app_currency';
  static const String _keyCurrencySymbol = 'app_currency_symbol';
  static const String _keyAppName = 'app_name';
  static const String _keyPhoneCode = 'app_phone_code';
  static const String _keyDateFormat = 'app_date_format';
  static const String _keyTimeFormat = 'app_time_format';

  /// اللغات المدعومة
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'ar', 'name': 'العربية', 'englishName': 'Arabic', 'direction': 'rtl'},
    {'code': 'en', 'name': 'English', 'englishName': 'English', 'direction': 'ltr'},
  ];

  /// الدول المدعومة
  static const List<Map<String, dynamic>> supportedCountries = [
    {
      'code': 'AE',
      'name': 'الإمارات العربية المتحدة',
      'englishName': 'United Arab Emirates',
      'currency': 'AED',
      'currencySymbol': 'د.إ',
      'currencyEnglish': 'AED',
      'phoneCode': '+971',
      'flag': '🇦🇪',
    },
    {
      'code': 'SA',
      'name': 'المملكة العربية السعودية',
      'englishName': 'Saudi Arabia',
      'currency': 'SAR',
      'currencySymbol': 'ر.س',
      'currencyEnglish': 'SAR',
      'phoneCode': '+966',
      'flag': '🇸🇦',
    },
    {
      'code': 'KW',
      'name': 'الكويت',
      'englishName': 'Kuwait',
      'currency': 'KWD',
      'currencySymbol': 'د.ك',
      'currencyEnglish': 'KWD',
      'phoneCode': '+965',
      'flag': '🇰🇼',
    },
    {
      'code': 'QA',
      'name': 'قطر',
      'englishName': 'Qatar',
      'currency': 'QAR',
      'currencySymbol': 'ر.ق',
      'currencyEnglish': 'QAR',
      'phoneCode': '+974',
      'flag': '🇶🇦',
    },
    {
      'code': 'BH',
      'name': 'البحرين',
      'englishName': 'Bahrain',
      'currency': 'BHD',
      'currencySymbol': 'د.ب',
      'currencyEnglish': 'BHD',
      'phoneCode': '+973',
      'flag': '🇧🇭',
    },
    {
      'code': 'OM',
      'name': 'عمان',
      'englishName': 'Oman',
      'currency': 'OMR',
      'currencySymbol': 'ر.ع',
      'currencyEnglish': 'OMR',
      'phoneCode': '+968',
      'flag': '🇴🇲',
    },
    {
      'code': 'EG',
      'name': 'مصر',
      'englishName': 'Egypt',
      'currency': 'EGP',
      'currencySymbol': 'ج.م',
      'currencyEnglish': 'EGP',
      'phoneCode': '+20',
      'flag': '🇪🇬',
    },
    {
      'code': 'JO',
      'name': 'الأردن',
      'englishName': 'Jordan',
      'currency': 'JOD',
      'currencySymbol': 'د.أ',
      'currencyEnglish': 'JOD',
      'phoneCode': '+962',
      'flag': '🇯🇴',
    },
    {
      'code': 'US',
      'name': 'الولايات المتحدة',
      'englishName': 'United States',
      'currency': 'USD',
      'currencySymbol': '\$',
      'currencyEnglish': 'USD',
      'phoneCode': '+1',
      'flag': '🇺🇸',
    },
    {
      'code': 'GB',
      'name': 'المملكة المتحدة',
      'englishName': 'United Kingdom',
      'currency': 'GBP',
      'currencySymbol': '£',
      'currencyEnglish': 'GBP',
      'phoneCode': '+44',
      'flag': '🇬🇧',
    },
  ];

  /// حفظ إعدادات التطبيق
  static Future<void> saveSettings({
    String? language,
    String? country,
    String? currency,
    String? currencySymbol,
    String? appName,
    String? phoneCode,
    String? dateFormat,
    String? timeFormat,
  }) async {
    if (language != null) await HiveStorageService.setString(_keyLanguage, language);
    if (country != null) await HiveStorageService.setString(_keyCountry, country);
    if (currency != null) await HiveStorageService.setString(_keyCurrency, currency);
    if (currencySymbol != null) await HiveStorageService.setString(_keyCurrencySymbol, currencySymbol);
    if (appName != null) await HiveStorageService.setString(_keyAppName, appName);
    if (phoneCode != null) await HiveStorageService.setString(_keyPhoneCode, phoneCode);
    if (dateFormat != null) await HiveStorageService.setString(_keyDateFormat, dateFormat);
    if (timeFormat != null) await HiveStorageService.setString(_keyTimeFormat, timeFormat);
  }

  /// استرجاع جميع الإعدادات
  static Map<String, dynamic> getSettings() {
    return {
      'language': HiveStorageService.getString(_keyLanguage) ?? 'ar',
      'country': HiveStorageService.getString(_keyCountry) ?? 'AE',
      'currency': HiveStorageService.getString(_keyCurrency) ?? 'AED',
      'currencySymbol': HiveStorageService.getString(_keyCurrencySymbol) ?? 'د.إ',
      'appName': HiveStorageService.getString(_keyAppName) ?? 'VitaFit',
      'phoneCode': HiveStorageService.getString(_keyPhoneCode) ?? '+971',
      'dateFormat': HiveStorageService.getString(_keyDateFormat) ?? 'dd/MM/yyyy',
      'timeFormat': HiveStorageService.getString(_keyTimeFormat) ?? 'HH:mm',
    };
  }

  /// الحصول على اللغة الحالية
  static String getCurrentLanguage() {
    return HiveStorageService.getString(_keyLanguage) ?? 'ar';
  }

  /// الحصول على الدولة الحالية
  static String getCurrentCountry() {
    return HiveStorageService.getString(_keyCountry) ?? 'AE';
  }

  /// الحصول على العملة الحالية
  static String getCurrentCurrency() {
    return HiveStorageService.getString(_keyCurrency) ?? 'AED';
  }

  /// الحصول على رمز العملة
  static String getCurrencySymbol() {
    return HiveStorageService.getString(_keyCurrencySymbol) ?? 'د.إ';
  }

  /// هل اللغة من اليمين لليسار؟
  static bool isRTL() {
    final language = getCurrentLanguage();
    return language == 'ar';
  }

  /// الحصول على اتجاه النص
  static TextDirection getTextDirection() {
    final isRtl = isRTL();
    return isRtl ? TextDirection.rtl : TextDirection.ltr;
  }

  /// الحصول على Locale
  static Locale getLocale() {
    final language = getCurrentLanguage();
    final country = getCurrentCountry();
    return Locale(language, country);
  }

  /// الحصول على معلومات الدولة
  static Map<String, dynamic>? getCountryInfo(String countryCode) {
    try {
      return supportedCountries.firstWhere((c) => c['code'] == countryCode);
    } catch (e) {
      return supportedCountries.first;
    }
  }

  /// الحصول على معلومات اللغة
  static Map<String, String>? getLanguageInfo(String languageCode) {
    try {
      return supportedLanguages.firstWhere((l) => l['code'] == languageCode);
    } catch (e) {
      return supportedLanguages.first;
    }
  }

  /// تنسيق المبلغ بالعملة
  static String formatCurrency(double amount) {
    final symbol = getCurrencySymbol();
    final language = getCurrentLanguage();

    if (language == 'ar') {
      return '${amount.toStringAsFixed(2)} $symbol';
    } else {
      return '$symbol ${amount.toStringAsFixed(2)}';
    }
  }
}
