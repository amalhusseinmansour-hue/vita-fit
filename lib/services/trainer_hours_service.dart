import 'package:shared_preferences/shared_preferences.dart';
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFreeHours, freeHoursPerMonth);
    await prefs.setDouble(_keyHourlyRate, extraHourlyRate);
  }

  /// استرجاع إعدادات الساعات
  static Future<Map<String, dynamic>> getHoursSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'freeHoursPerMonth': prefs.getInt(_keyFreeHours) ?? 20,
      'extraHourlyRate': prefs.getDouble(_keyHourlyRate) ?? 50.0,
    };
  }

  /// الحصول على استخدام مدربة معينة
  static Future<TrainerHoursUsage> getTrainerUsage(String trainerId) async {
    final prefs = await SharedPreferences.getInstance();
    final settings = await getHoursSettings();

    // التحقق من الشهر الحالي وإعادة التعيين إذا لزم الأمر
    await _checkAndResetMonth();

    final usageJson = prefs.getString('${_keyTrainerUsage}_$trainerId');
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
    final prefs = await SharedPreferences.getInstance();
    final usage = await getTrainerUsage(trainerId);

    final session = {
      'date': DateTime.now().toIso8601String(),
      'hours': hours,
      'type': sessionType,
      'clientName': clientName ?? 'غير محدد',
    };

    final updatedSessions = [...usage.sessions, session];
    final updatedHours = usage.usedHours + hours;

    await prefs.setString('${_keyTrainerUsage}_$trainerId', json.encode({
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
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = '${DateTime.now().year}-${DateTime.now().month}';
    final savedMonth = prefs.getString(_keyCurrentMonth);

    if (savedMonth != currentMonth) {
      // شهر جديد - إعادة تعيين جميع الساعات
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_keyTrainerUsage)) {
          await prefs.remove(key);
        }
      }
      await prefs.setString(_keyCurrentMonth, currentMonth);
    }
  }

  /// إعادة تعيين ساعات مدربة معينة
  static Future<void> resetTrainerHours(String trainerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_keyTrainerUsage}_$trainerId');
  }

  /// إعادة تعيين ساعات جميع المدربات
  static Future<void> resetAllTrainersHours() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyTrainerUsage)) {
        await prefs.remove(key);
      }
    }
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
