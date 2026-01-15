import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();

    if (language != null) await prefs.setString(_keyLanguage, language);
    if (country != null) await prefs.setString(_keyCountry, country);
    if (currency != null) await prefs.setString(_keyCurrency, currency);
    if (currencySymbol != null) await prefs.setString(_keyCurrencySymbol, currencySymbol);
    if (appName != null) await prefs.setString(_keyAppName, appName);
    if (phoneCode != null) await prefs.setString(_keyPhoneCode, phoneCode);
    if (dateFormat != null) await prefs.setString(_keyDateFormat, dateFormat);
    if (timeFormat != null) await prefs.setString(_keyTimeFormat, timeFormat);
  }

  /// استرجاع جميع الإعدادات
  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'language': prefs.getString(_keyLanguage) ?? 'ar',
      'country': prefs.getString(_keyCountry) ?? 'AE',
      'currency': prefs.getString(_keyCurrency) ?? 'AED',
      'currencySymbol': prefs.getString(_keyCurrencySymbol) ?? 'د.إ',
      'appName': prefs.getString(_keyAppName) ?? 'VitaFit',
      'phoneCode': prefs.getString(_keyPhoneCode) ?? '+971',
      'dateFormat': prefs.getString(_keyDateFormat) ?? 'dd/MM/yyyy',
      'timeFormat': prefs.getString(_keyTimeFormat) ?? 'HH:mm',
    };
  }

  /// الحصول على اللغة الحالية
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage) ?? 'ar';
  }

  /// الحصول على الدولة الحالية
  static Future<String> getCurrentCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCountry) ?? 'AE';
  }

  /// الحصول على العملة الحالية
  static Future<String> getCurrentCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrency) ?? 'AED';
  }

  /// الحصول على رمز العملة
  static Future<String> getCurrencySymbol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrencySymbol) ?? 'د.إ';
  }

  /// هل اللغة من اليمين لليسار؟
  static Future<bool> isRTL() async {
    final language = await getCurrentLanguage();
    return language == 'ar';
  }

  /// الحصول على اتجاه النص
  static Future<TextDirection> getTextDirection() async {
    final isRtl = await isRTL();
    return isRtl ? TextDirection.rtl : TextDirection.ltr;
  }

  /// الحصول على Locale
  static Future<Locale> getLocale() async {
    final language = await getCurrentLanguage();
    final country = await getCurrentCountry();
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
  static Future<String> formatCurrency(double amount) async {
    final symbol = await getCurrencySymbol();
    final language = await getCurrentLanguage();

    if (language == 'ar') {
      return '${amount.toStringAsFixed(2)} $symbol';
    } else {
      return '$symbol ${amount.toStringAsFixed(2)}';
    }
  }
}
