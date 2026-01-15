/// Environment Configuration
///
/// This file contains all environment-specific configurations.
/// For production, replace placeholder values with actual credentials.
///
/// IMPORTANT: Never commit actual API keys to version control!
/// Use environment variables or secure storage for production.

class EnvConfig {
  // ============ APP SETTINGS ============
  static const String appName = 'VITAFIT';
  static const String appNameAr = 'فيتافيت';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // ============ API CONFIGURATION ============
  static const String apiBaseUrl = 'https://vitafit.online/api';
  static const int apiTimeout = 30; // seconds

  // ============ PAYMOB CONFIGURATION ============
  /// Get these from https://accept.paymob.com/portal2/en/settings
  static const String paymobApiKey = String.fromEnvironment(
    'PAYMOB_API_KEY',
    defaultValue: 'YOUR_PAYMOB_API_KEY',
  );
  static const String paymobIntegrationId = String.fromEnvironment(
    'PAYMOB_INTEGRATION_ID',
    defaultValue: 'YOUR_INTEGRATION_ID',
  );
  static const String paymobIframeId = String.fromEnvironment(
    'PAYMOB_IFRAME_ID',
    defaultValue: 'YOUR_IFRAME_ID',
  );
  static const String paymobHmacSecret = String.fromEnvironment(
    'PAYMOB_HMAC_SECRET',
    defaultValue: 'YOUR_HMAC_SECRET',
  );

  // ============ FIREBASE CONFIGURATION ============
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'vitafit-app',
  );

  // ============ SUPPORT ============
  static const String supportEmail = 'support@vitafit.online';
  static const String supportPhone = '+966500000000';
  static const String whatsappNumber = '+966500000000';

  // ============ SOCIAL LINKS ============
  static const String instagramUrl = 'https://instagram.com/vitafit';
  static const String twitterUrl = 'https://twitter.com/vitafit';
  static const String facebookUrl = 'https://facebook.com/vitafit';

  // ============ LEGAL URLS ============
  static const String privacyPolicyUrl = 'https://vitafit.online/privacy';
  static const String termsOfServiceUrl = 'https://vitafit.online/terms';

  // ============ APP STORE URLS ============
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.vitafit.app';
  static const String appStoreUrl = 'https://apps.apple.com/app/vitafit/id123456789';

  // ============ VALIDATION ============
  static bool get isPaymobConfigured =>
      paymobApiKey != 'YOUR_PAYMOB_API_KEY' &&
      paymobIntegrationId != 'YOUR_INTEGRATION_ID';

  static bool get isProduction =>
      const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development') == 'production';
}
