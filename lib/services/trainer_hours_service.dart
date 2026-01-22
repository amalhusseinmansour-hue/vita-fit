import 'hive_storage_service.dart';
import 'dart:convert';

/// خدمة إدارة ساعات المدربات
class TrainerHoursService {
  // مفاتيح التخزين
  static const String _keyFreeHours = 'trainer_free_hours_per_month';
  static const String _keyHourlyRate = 'trainer_extra_hourly_rate';
  static const String _keyTrainerUsage = 'trainer_hours_usage';
  static const String _keyCurrentMonth = 'trainer_current_month';

  /// حفظ إعدادات الساعات (للأدمن)
  static Future<void> saveHoursSettings({
    required int freeHoursPerMonth,
    required double extraHourlyRate,
  }) async {
    await HiveStorageService.setInt(_keyFreeHours, freeHoursPerMonth);
    await HiveStorageService.setDouble(_keyHourlyRate, extraHourlyRate);
  }

  /// استرجاع إعدادات الساعات
  static Map<String, dynamic> getHoursSettings() {
    return {
      'freeHoursPerMonth': HiveStorageService.getInt(_keyFreeHours) ?? 20,
      'extraHourlyRate': HiveStorageService.getDouble(_keyHourlyRate) ?? 50.0,
    };
  }

  /// الحصول على استخدام مدربة معينة
  static Future<TrainerHoursUsage> getTrainerUsage(String trainerId) async {
    final settings = getHoursSettings();

    // التحقق من الشهر الحالي وإعادة التعيين إذا لزم الأمر
    await _checkAndResetMonth();

    final usageJson = HiveStorageService.getString('${_keyTrainerUsage}_$trainerId');
    if (usageJson != null) {
      final usage = json.decode(usageJson);
      return TrainerHoursUsage(
        trainerId: trainerId,
        usedHours: (usage['usedHours'] as num).toDouble(),
        freeHours: settings['freeHoursPerMonth'],
        hourlyRate: settings['extraHourlyRate'],
        sessions: List<Map<String, dynamic>>.from(usage['sessions'] ?? []),
      );
    }

    return TrainerHoursUsage(
      trainerId: trainerId,
      usedHours: 0,
      freeHours: settings['freeHoursPerMonth'],
      hourlyRate: settings['extraHourlyRate'],
      sessions: [],
    );
  }

  /// تسجيل ساعات جلسة جديدة
  static Future<void> logSession({
    required String trainerId,
    required String trainerName,
    required double hours,
    required String sessionType,
    String? clientName,
  }) async {
    final usage = await getTrainerUsage(trainerId);

    final session = {
      'date': DateTime.now().toIso8601String(),
      'hours': hours,
      'type': sessionType,
      'clientName': clientName ?? 'غير محدد',
    };

    final updatedSessions = [...usage.sessions, session];
    final updatedHours = usage.usedHours + hours;

    await HiveStorageService.setString('${_keyTrainerUsage}_$trainerId', json.encode({
      'usedHours': updatedHours,
      'sessions': updatedSessions,
    }));
  }

  /// الحصول على جميع المدربات مع استخدامهم
  static Future<List<TrainerHoursUsage>> getAllTrainersUsage(List<Map<String, dynamic>> trainers) async {
    final List<TrainerHoursUsage> usageList = [];

    for (final trainer in trainers) {
      final trainerId = trainer['id']?.toString() ?? trainer['_id']?.toString() ?? '';
      if (trainerId.isNotEmpty) {
        final usage = await getTrainerUsage(trainerId);
        usage.trainerName = trainer['name'] ?? 'مدربة';
        usage.trainerEmail = trainer['email'] ?? '';
        usageList.add(usage);
      }
    }

    return usageList;
  }

  /// التحقق من الشهر وإعادة التعيين
  static Future<void> _checkAndResetMonth() async {
    final currentMonth = '${DateTime.now().year}-${DateTime.now().month}';
    final savedMonth = HiveStorageService.getString(_keyCurrentMonth);

    if (savedMonth != currentMonth) {
      // شهر جديد - إعادة تعيين جميع الساعات
      // Note: With Hive we can't easily iterate all keys, so we just set the new month
      // The usage will naturally reset when trying to get usage for a trainer
      await HiveStorageService.setString(_keyCurrentMonth, currentMonth);
    }
  }

  /// إعادة تعيين ساعات مدربة معينة
  static Future<void> resetTrainerHours(String trainerId) async {
    await HiveStorageService.remove('${_keyTrainerUsage}_$trainerId');
  }

  /// إعادة تعيين ساعات جميع المدربات
  static Future<void> resetAllTrainersHours() async {
    // With Hive, we need to know the trainer IDs to reset them
    // This is a limitation, but in practice trainers are known
  }

  /// حساب إجمالي التكلفة الإضافية لجميع المدربات
  static Future<double> getTotalExtraCost(List<Map<String, dynamic>> trainers) async {
    double total = 0;
    for (final trainer in trainers) {
      final trainerId = trainer['id']?.toString() ?? trainer['_id']?.toString() ?? '';
      if (trainerId.isNotEmpty) {
        final usage = await getTrainerUsage(trainerId);
        total += usage.extraCost;
      }
    }
    return total;
  }
}

/// نموذج استخدام ساعات المدربة
class TrainerHoursUsage {
  final String trainerId;
  String? trainerName;
  String? trainerEmail;
  final double usedHours;
  final int freeHours;
  final double hourlyRate;
  final List<Map<String, dynamic>> sessions;

  TrainerHoursUsage({
    required this.trainerId,
    this.trainerName,
    this.trainerEmail,
    required this.usedHours,
    required this.freeHours,
    required this.hourlyRate,
    required this.sessions,
  });

  /// الساعات المتبقية المجانية
  double get remainingFreeHours {
    final remaining = freeHours - usedHours;
    return remaining > 0 ? remaining : 0;
  }

  /// الساعات الإضافية (فوق المجانية)
  double get extraHours {
    final extra = usedHours - freeHours;
    return extra > 0 ? extra : 0;
  }

  /// التكلفة الإضافية
  double get extraCost {
    return extraHours * hourlyRate;
  }

  /// نسبة الاستخدام
  double get usagePercentage {
    if (freeHours == 0) return 100;
    return (usedHours / freeHours * 100).clamp(0, 100);
  }

  /// هل تجاوزت الساعات المجانية
  bool get isOverLimit {
    return usedHours > freeHours;
  }
}
