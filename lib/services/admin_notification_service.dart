import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';

class AdminNotificationService {
  // Admin contact info
  // WhatsApp: wa.me requires number without 00 prefix
  static const String adminWhatsApp = '971528344410';
  static const String adminEmail = 'vitafit.uae@gmail.com';

  /// Send in-app notification to admin panel
  static Future<Map<String, dynamic>> sendInAppNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      return await ApiService.request(
        endpoint: '/admin/notifications',
        method: 'POST',
        body: {
          'title': title,
          'message': message,
          'type': type,
          if (data != null) 'data': data,
        },
      );
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Send email notification to admin (handled by backend)
  static Future<Map<String, dynamic>> sendEmailNotification({
    required String subject,
    required String body,
  }) async {
    try {
      return await ApiService.request(
        endpoint: '/admin/notifications/email',
        method: 'POST',
        body: {
          'to': adminEmail,
          'subject': subject,
          'body': body,
        },
      );
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Open WhatsApp with pre-filled message to admin
  static Future<bool> sendWhatsAppNotification({
    required String message,
  }) async {
    final encodedMessage = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$adminWhatsApp?text=$encodedMessage');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      // WhatsApp not available
    }
    return false;
  }

  /// Notify admin about new trainer registration through all channels
  static Future<void> notifyNewTrainerRegistration({
    required String trainerName,
    required String trainerEmail,
    required String trainerPhone,
    required String specialty,
    required int experienceYears,
    required String bio,
  }) async {
    final message = '''
طلب تسجيل مدربة جديدة

الاسم: $trainerName
البريد الإلكتروني: $trainerEmail
رقم الجوال: $trainerPhone
التخصص: $specialty
سنوات الخبرة: $experienceYears
نبذة: $bio
''';

    // 1. In-app notification (to admin panel)
    await sendInAppNotification(
      title: 'طلب تسجيل مدربة جديدة',
      message: 'تم استلام طلب تسجيل من $trainerName',
      type: 'trainer_registration',
      data: {
        'trainer_name': trainerName,
        'trainer_email': trainerEmail,
        'trainer_phone': trainerPhone,
        'specialty': specialty,
        'experience_years': experienceYears,
        'bio': bio,
      },
    );

    // 2. Email notification (handled by backend)
    await sendEmailNotification(
      subject: 'طلب تسجيل مدربة جديدة - $trainerName',
      body: message,
    );

    // 3. WhatsApp notification (opens WhatsApp app)
    await sendWhatsAppNotification(message: message);
  }
}
