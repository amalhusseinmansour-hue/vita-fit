import 'package:flutter/material.dart';
import '../services/app_settings_service.dart';

/// Provider لإدارة اللغة والإعدادات الإقليمية
class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('ar', 'AE');
  String _country = 'AE';
  String _currency = 'AED';
  String _currencySymbol = 'د.إ';
  String _phoneCode = '+971';
  bool _isLoading = false;

  LanguageProvider() {
    // Load settings without notifyListeners in constructor
    // Wrapped in try-catch to prevent any crash during app startup
    try {
      _loadSettingsSync();
    } catch (e) {
      debugPrint('LanguageProvider init error: $e');
      // Use defaults - already set in field declarations
    }
  }

  // Getters
  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  String get countryCode => _country;
  String get currency => _currency;
  String get currencySymbol => _currencySymbol;
  String get phoneCode => _phoneCode;
  bool get isLoading => _isLoading;
  bool get isRTL => _locale.languageCode == 'ar';
  TextDirection get textDirection => isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// تحميل الإعدادات بشكل متزامن (للـ constructor)
  void _loadSettingsSync() {
    try {
      final settings = AppSettingsService.getSettings();
      _locale = Locale(settings['language'] ?? 'ar', settings['country'] ?? 'AE');
      _country = settings['country'] ?? 'AE';
      _currency = settings['currency'] ?? 'AED';
      _currencySymbol = settings['currencySymbol'] ?? 'د.إ';
      _phoneCode = settings['phoneCode'] ?? '+971';
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Use defaults
      _locale = const Locale('ar', 'AE');
      _country = 'AE';
      _currency = 'AED';
      _currencySymbol = 'د.إ';
      _phoneCode = '+971';
    }
  }

  /// تحميل الإعدادات المحفوظة
  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final settings = AppSettingsService.getSettings();
      _locale = Locale(settings['language'] ?? 'ar', settings['country'] ?? 'AE');
      _country = settings['country'] ?? 'AE';
      _currency = settings['currency'] ?? 'AED';
      _currencySymbol = settings['currencySymbol'] ?? 'د.إ';
      _phoneCode = settings['phoneCode'] ?? '+971';
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// تغيير اللغة
  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode != languageCode) {
      _locale = Locale(languageCode, _country);
      await AppSettingsService.saveSettings(language: languageCode);
      notifyListeners();
    }
  }

  /// تغيير الدولة
  Future<void> setCountry(String countryCode) async {
    final countryInfo = AppSettingsService.getCountryInfo(countryCode);
    if (countryInfo != null) {
      _country = countryCode;
      _currency = countryInfo['currency'];
      _currencySymbol = countryInfo['currencySymbol'];
      _phoneCode = countryInfo['phoneCode'];
      _locale = Locale(_locale.languageCode, countryCode);

      await AppSettingsService.saveSettings(
        country: countryCode,
        currency: _currency,
        currencySymbol: _currencySymbol,
        phoneCode: _phoneCode,
      );

      notifyListeners();
    }
  }

  /// تغيير اللغة والدولة معاً
  Future<void> setLocale(Locale newLocale) async {
    if (_locale != newLocale) {
      _locale = newLocale;
      _country = newLocale.countryCode ?? 'AE';

      await AppSettingsService.saveSettings(
        language: newLocale.languageCode,
        country: _country,
      );

      notifyListeners();
    }
  }

  /// تنسيق المبلغ بالعملة
  String formatCurrency(double amount) {
    if (isRTL) {
      return '${amount.toStringAsFixed(2)} $_currencySymbol';
    } else {
      return '$_currencySymbol ${amount.toStringAsFixed(2)}';
    }
  }

  /// إعادة تحميل الإعدادات
  Future<void> reload() async {
    await _loadSettings();
  }
}
