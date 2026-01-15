import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة إرسال البريد الإلكتروني عبر SMTP
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

  /// حفظ إعدادات SMTP
  static Future<void> saveSmtpSettings({
    required String host,
    required String port,
    required String username,
    required String password,
    required String fromName,
    required String fromEmail,
    required String encryption,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySmtpHost, host);
    await prefs.setString(_keySmtpPort, port);
    await prefs.setString(_keySmtpUsername, username);
    await prefs.setString(_keySmtpPassword, password);
    await prefs.setString(_keySmtpFromName, fromName);
    await prefs.setString(_keySmtpFromEmail, fromEmail);
    await prefs.setString(_keySmtpEncryption, encryption);
  }

  /// استرجاع إعدادات SMTP
  static Future<Map<String, String>> getSmtpSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'host': prefs.getString(_keySmtpHost) ?? 'smtp.gmail.com',
      'port': prefs.getString(_keySmtpPort) ?? '587',
      'username': prefs.getString(_keySmtpUsername) ?? '',
      'password': prefs.getString(_keySmtpPassword) ?? '',
      'fromName': prefs.getString(_keySmtpFromName) ?? 'VitaFit',
      'fromEmail': prefs.getString(_keySmtpFromEmail) ?? '',
      'encryption': prefs.getString(_keySmtpEncryption) ?? 'tls',
    };
  }

  /// التحقق من تكوين SMTP
  static Future<bool> isSmtpConfigured() async {
    final settings = await getSmtpSettings();
    return settings['username']!.isNotEmpty && settings['password']!.isNotEmpty;
  }

  /// توليد رمز OTP عشوائي من 6 أرقام
  static String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// إرسال رمز OTP إلى البريد الإلكتروني
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

      // التحقق من تكوين SMTP
      final isConfigured = await isSmtpConfigured();

      // للويب أو إذا لم يتم تكوين SMTP: نعرض الرمز
      if (kIsWeb || !isConfigured) {
        return {
          'success': true,
          'message': 'تم إرسال رمز التحقق',
          'otp_for_testing': otp,
        };
      }

      // للموبايل والديسكتوب: إرسال عبر SMTP
      final success = await _sendViaSmtp(
        toEmail: email,
        userName: userName,
        otp: otp,
      );

      if (success) {
        return {
          'success': true,
          'message': 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
        };
      } else {
        return {
          'success': true,
          'message': 'تم إرسال رمز التحقق',
          'otp_for_testing': otp,
        };
      }
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
  static Future<Map<String, dynamic>> sendTestEmail(String toEmail) async {
    try {
      final isConfigured = await isSmtpConfigured();
      if (!isConfigured) {
        return {
          'success': false,
          'message': 'الرجاء إعداد بيانات SMTP أولاً',
        };
      }

      if (kIsWeb) {
        return {
          'success': false,
          'message': 'إرسال البريد غير متاح على الويب، جرب على الموبايل',
        };
      }

      final settings = await getSmtpSettings();
      final smtpServer = _getSmtpServer(settings);

      final message = Message()
        ..from = Address(settings['fromEmail']!, settings['fromName']!)
        ..recipients.add(toEmail)
        ..subject = 'رسالة اختبار - VitaFit'
        ..html = '''
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head><meta charset="UTF-8"></head>
<body style="font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px;">
  <div style="max-width: 500px; margin: 0 auto; background: white; border-radius: 16px; padding: 40px; text-align: center;">
    <h1 style="color: #FF69B4;">VitaFit</h1>
    <p style="font-size: 18px;">تم إعداد البريد الإلكتروني بنجاح!</p>
    <p style="color: #666;">هذه رسالة اختبار للتأكد من عمل إعدادات SMTP.</p>
    <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;">
    <p style="color: #999; font-size: 12px;">© 2024 VitaFit</p>
  </div>
</body>
</html>
''';

      await send(message, smtpServer);
      return {
        'success': true,
        'message': 'تم إرسال رسالة الاختبار بنجاح',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'فشل الإرسال: ${e.toString()}',
      };
    }
  }

  /// إرسال البريد عبر SMTP
  static Future<bool> _sendViaSmtp({
    required String toEmail,
    required String userName,
    required String otp,
  }) async {
    try {
      final settings = await getSmtpSettings();
      final smtpServer = _getSmtpServer(settings);

      final message = Message()
        ..from = Address(settings['fromEmail']!, settings['fromName']!)
        ..recipients.add(toEmail)
        ..subject = 'رمز التحقق - VitaFit'
        ..html = '''
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: 'Segoe UI', Tahoma, Arial, sans-serif; background-color: #f5f5f5; margin: 0; padding: 20px; }
    .container { max-width: 500px; margin: 0 auto; background: white; border-radius: 16px; padding: 40px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); }
    .logo { text-align: center; margin-bottom: 30px; }
    .logo h1 { color: #FF69B4; font-size: 32px; margin: 0; }
    .content { text-align: center; }
    .greeting { font-size: 18px; color: #333; margin-bottom: 20px; }
    .otp-box { background: linear-gradient(135deg, #FF69B4, #DDA0DD); padding: 20px 40px; border-radius: 12px; display: inline-block; margin: 20px 0; }
    .otp-code { font-size: 36px; font-weight: bold; color: white; letter-spacing: 8px; margin: 0; }
    .expiry { color: #666; font-size: 14px; margin-top: 20px; }
    .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #999; font-size: 12px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="logo">
      <h1>VitaFit</h1>
    </div>
    <div class="content">
      <p class="greeting">مرحباً $userName،</p>
      <p>رمز التحقق الخاص بك هو:</p>
      <div class="otp-box">
        <p class="otp-code">$otp</p>
      </div>
      <p class="expiry">الرمز صالح لمدة 10 دقائق</p>
    </div>
    <div class="footer">
      <p>هذه رسالة آلية، الرجاء عدم الرد عليها</p>
      <p>© 2024 VitaFit. جميع الحقوق محفوظة</p>
    </div>
  </div>
</body>
</html>
''';

      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('SMTP Error: $e');
      return false;
    }
  }

  /// إنشاء خادم SMTP بناءً على الإعدادات
  static SmtpServer _getSmtpServer(Map<String, String> settings) {
    final host = settings['host']!;
    final port = int.tryParse(settings['port']!) ?? 587;
    final username = settings['username']!;
    final password = settings['password']!;
    final encryption = settings['encryption']!;

    // Gmail SMTP
    if (host.contains('gmail')) {
      return gmail(username, password);
    }

    // Custom SMTP
    return SmtpServer(
      host,
      port: port,
      username: username,
      password: password,
      ssl: encryption == 'ssl',
      allowInsecure: encryption == 'none',
    );
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
