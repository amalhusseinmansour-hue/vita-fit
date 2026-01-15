import 'package:flutter/material.dart';
import 'translations_ar.dart';
import 'translations_en.dart';

/// خدمة الترجمة
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar', 'AE'),
    Locale('ar', 'SA'),
    Locale('en', 'US'),
    Locale('en', 'GB'),
  ];

  Map<String, String> get _localizedStrings {
    switch (locale.languageCode) {
      case 'en':
        return translationsEn;
      case 'ar':
      default:
        return translationsAr;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  /// هل اللغة من اليمين لليسار
  bool get isRTL => locale.languageCode == 'ar';

  /// اتجاه النص
  TextDirection get textDirection =>
      isRTL ? TextDirection.rtl : TextDirection.ltr;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension لسهولة الاستخدام
extension TranslateExtension on BuildContext {
  AppLocalizations get tr => AppLocalizations.of(this)!;
  String t(String key) => AppLocalizations.of(this)?.translate(key) ?? key;
  bool get isRTL => AppLocalizations.of(this)?.isRTL ?? true;
  TextDirection get textDirection =>
      AppLocalizations.of(this)?.textDirection ?? TextDirection.rtl;
}
