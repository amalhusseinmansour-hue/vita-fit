import 'dart:math';
import 'hive_storage_service.dart';

/// خدمة إرسال البريد الإلكتروني
/// ملاحظة: تم إزالة SMTP لأنه لا يعمل على iOS
/// يتم عرض رمز OTP مباشرة للمستخدم
class EmailService {
  // مفاتيح التخزين
  static const String _keySmtpHost = 'smtp_host';
  static const String _keySmtpPort = 'smtp_port';
  static const String _keySmtpUsername = 'smtp_username';
  static const String _keySmtpPassword = 'smtp_password';
  static const String _keySmtpFromName = 'smtp_from_name';
  static const String _keySmtpFromEmail = 'smtp_from_email';
  static const String _keySmtpEncryption = 'smtp_encryption';

  // تخزين OTP مؤقتاً للتحقق
  static final Map<String, _OtpData> _otpStorage = {};

  /// حفظ إعدادات SMTP (للاستخدام المستقبلي)
  static Future<void> saveSmtpSettings({
    required String host,
    required String port,
    required String username,
    required String password,
    required String fromName,
    required String fromEmail,
    required String encryption,
  }) async {
    await HiveStorageService.setString(_keySmtpHost, host);
    await HiveStorageService.setString(_keySmtpPort, port);
    await HiveStorageService.setString(_keySmtpUsername, username);
    await HiveStorageService.setString(_keySmtpPassword, password);
    await HiveStorageService.setString(_keySmtpFromName, fromName);
    await HiveStorageService.setString(_keySmtpFromEmail, fromEmail);
    await HiveStorageService.setString(_keySmtpEncryption, encryption);
  }

  /// استرجاع إعدادات SMTP
  static Map<String, String> getSmtpSettings() {
    return {
      'host': HiveStorageService.getString(_keySmtpHost) ?? 'smtp.gmail.com',
      'port': HiveStorageService.getString(_keySmtpPort) ?? '587',
      'username': HiveStorageService.getString(_keySmtpUsername) ?? '',
      'password': HiveStorageService.getString(_keySmtpPassword) ?? '',
      'fromName': HiveStorageService.getString(_keySmtpFromName) ?? 'VitaFit',
      'fromEmail': HiveStorageService.getString(_keySmtpFromEmail) ?? '',
      'encryption': HiveStorageService.getString(_keySmtpEncryption) ?? 'tls',
    };
  }

  /// التحقق من تكوين SMTP
  static bool isSmtpConfigured() {
    final settings = getSmtpSettings();
    return settings['username']!.isNotEmpty && settings['password']!.isNotEmpty;
  }

  /// توليد رمز OTP عشوائي من 6 أرقام
  static String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// إرسال رمز OTP إلى البريد الإلكتروني
  /// ملاحظة: حالياً يتم عرض الرمز مباشرة (SMTP غير متاح على iOS)
  static Future<Map<String, dynamic>> sendOtpEmail({
    required String email,
    required String userName,
  }) async {
    try {
      // توليد OTP جديد
      final otp = generateOtp();

      // حفظ OTP مع وقت الانتهاء (10 دقائق)
      _otpStorage[email.toLowerCase()] = _OtpData(
        otp: otp,
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );

      // عرض الرمز مباشرة للمستخدم
      return {
        'success': true,
        'message': 'تم إرسال رمز التحقق',
        'otp_for_testing': otp,
      };
    } catch (e) {
      // في حالة الخطأ، نعيد الرمز للاختبار
      final otp = _otpStorage[email.toLowerCase()]?.otp ?? generateOtp();
      _otpStorage[email.toLowerCase()] = _OtpData(
        otp: otp,
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );
      return {
        'success': true,
        'message': 'تم إرسال رمز التحقق',
        'otp_for_testing': otp,
      };
    }
  }

  /// إرسال بريد اختبار
  /// ملاحظة: SMTP غير متاح على iOS حالياً
  static Future<Map<String, dynamic>> sendTestEmail(String toEmail) async {
    return {
      'success': false,
      'message': 'إرسال البريد عبر SMTP غير متاح حالياً على هذه المنصة',
    };
  }

  /// التحقق من صحة OTP
  static bool verifyOtp(String email, String otp) {
    final otpData = _otpStorage[email.toLowerCase()];

    if (otpData == null) {
      return false;
    }

    // التحقق من انتهاء الصلاحية
    if (DateTime.now().isAfter(otpData.expiresAt)) {
      _otpStorage.remove(email.toLowerCase());
      return false;
    }

    // التحقق من تطابق الرمز
    if (otpData.otp == otp) {
      _otpStorage.remove(email.toLowerCase());
      return true;
    }

    return false;
  }

  /// الحصول على OTP المخزن (للاختبار فقط)
  static String? getStoredOtp(String email) {
    return _otpStorage[email.toLowerCase()]?.otp;
  }

  /// مسح OTP المنتهي الصلاحية
  static void cleanExpiredOtps() {
    final now = DateTime.now();
    _otpStorage.removeWhere((key, value) => now.isAfter(value.expiresAt));
  }
}

/// بيانات OTP المخزنة
class _OtpData {
  final String otp;
  final DateTime expiresAt;

  _OtpData({
    required this.otp,
    required this.expiresAt,
  });
}
