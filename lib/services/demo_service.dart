import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'email_service.dart';

/// Demo Service - يوفر بيانات فعلية للعرض
class DemoService {
  static const String _registeredUsersKey = 'demo_registered_users';
  static bool _isInitialized = false;

  // المستخدمين
  static final Map<String, Map<String, dynamic>> demoUsers = {
    'admin@vitafit.com': {
      'email': 'admin@vitafit.com',
      'password': 'Admin@2024',
      'role': 'admin',
      'name': 'نورة العتيبي',
      'phone': '0501234567',
      'token': 'vitafit_admin_token_secure_2024',
      'avatar': 'assets/images/admin_avatar.png',
    },
    'coach@vitafit.com': {
      'email': 'coach@vitafit.com',
      'password': 'Coach@2024',
      'role': 'trainer',
      'name': 'كابتن سارة الحربي',
      'phone': '0559876543',
      'token': 'vitafit_trainer_token_secure_2024',
      'specialization': 'تدريب لياقة وتغذية',
      'experience': '7 سنوات',
      'rating': 4.9,
      'bio': 'مدربة معتمدة دولياً متخصصة في تدريب السيدات',
      'certifications': ['ACE Certified', 'NASM-CPT', 'Precision Nutrition'],
      'avatar': 'assets/images/trainer_avatar.png',
    },
    'user@vitafit.com': {
      'email': 'user@vitafit.com',
      'password': 'User@2024',
      'role': 'user',
      'name': 'ريم محمد',
      'phone': '0551112233',
      'token': 'vitafit_user_token_secure_2024',
      'avatar': 'assets/images/user_avatar.png',
      'height': 165,
      'weight': 68,
      'targetWeight': 58,
      'age': 28,
      'subscription': {
        'plan': 'premium',
        'planName': 'الباقة المميزة',
        'status': 'active',
        'startDate': '2024-12-01',
        'endDate': '2025-12-01',
        'features': [
          'جلسات تدريب شخصية غير محدودة',
          'خطة تغذية مخصصة',
          'متابعة يومية مع المدربة',
          'جلسات أونلاين عبر Zoom',
          'دخول لجميع الورش والفعاليات',
        ],
      },
    },
    // حساب المستخدم المسجل
    'loloamoola1992@gmail.com': {
      'email': 'loloamoola1992@gmail.com',
      'password': '33510421',
      'role': 'user',
      'name': 'لولو',
      'phone': '',
      'token': 'vitafit_user_lolo_token_2024',
      'avatar': '',
    },
  };

  // تهيئة الخدمة وتحميل المستخدمين المسجلين
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUsers = prefs.getString(_registeredUsersKey);

      if (savedUsers != null) {
        final Map<String, dynamic> decoded = jsonDecode(savedUsers);
        decoded.forEach((email, userData) {
          if (!demoUsers.containsKey(email)) {
            demoUsers[email] = Map<String, dynamic>.from(userData);
          }
        });
        print('✅ تم تحميل ${decoded.length} مستخدم مسجل');
      }
    } catch (e) {
      print('⚠️ خطأ في تحميل المستخدمين: $e');
    }

    _isInitialized = true;
  }

  // حفظ المستخدمين المسجلين
  static Future<void> _saveRegisteredUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // فقط حفظ المستخدمين الجدد (غير الافتراضيين)
      final Map<String, dynamic> newUsers = {};
      demoUsers.forEach((email, data) {
        if (!['admin@vitafit.com', 'coach@vitafit.com', 'user@vitafit.com'].contains(email)) {
          newUsers[email] = data;
        }
      });
      await prefs.setString(_registeredUsersKey, jsonEncode(newUsers));
    } catch (e) {
      print('⚠️ خطأ في حفظ المستخدمين: $e');
    }
  }

  // Validate login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    await initialize(); // تأكد من تحميل المستخدمين
    await Future.delayed(const Duration(milliseconds: 800));

    final user = demoUsers[email.toLowerCase()];
    if (user != null && user['password'] == password) {
      return {
        'success': true,
        'data': {
          'token': user['token'],
          'user': {
            'id': 'user_${user['role']}_${DateTime.now().millisecondsSinceEpoch}',
            '_id': 'user_${user['role']}_${DateTime.now().millisecondsSinceEpoch}',
            'name': user['name'],
            'email': user['email'],
            'phone': user['phone'],
            'role': user['role'],
            'avatar': user['avatar'],
            if (user['specialization'] != null) 'specialization': user['specialization'],
            if (user['experience'] != null) 'experience': user['experience'],
            if (user['rating'] != null) 'rating': user['rating'],
            if (user['bio'] != null) 'bio': user['bio'],
            if (user['height'] != null) 'height': user['height'],
            if (user['weight'] != null) 'weight': user['weight'],
            if (user['targetWeight'] != null) 'targetWeight': user['targetWeight'],
            if (user['subscription'] != null) 'subscription': user['subscription'],
          }
        }
      };
    }

    return {
      'success': false,
      'message': 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
    };
  }

  // برنامج التمارين الأسبوعي
  static Future<List<dynamic>> getWorkouts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      {
        '_id': '1',
        'name': 'تمارين الكارديو الصباحية',
        'type': 'cardio',
        'duration': 45,
        'caloriesBurned': 320,
        'difficulty': 'متوسط',
        'exercises': [
          {'name': 'إحماء وتمدد', 'sets': 1, 'reps': 0, 'duration': 5, 'calories': 25},
          {'name': 'المشي السريع', 'sets': 1, 'reps': 0, 'duration': 15, 'calories': 120},
          {'name': 'تمارين HIIT', 'sets': 4, 'reps': 10, 'duration': 15, 'calories': 150},
          {'name': 'تهدئة وتمدد', 'sets': 1, 'reps': 0, 'duration': 10, 'calories': 25},
        ],
        'completed': true,
        'date': now.subtract(const Duration(days: 1)).toIso8601String(),
        'trainer': 'كابتن سارة',
        'notes': 'ممتاز! حافظي على هذا المستوى',
      },
      {
        '_id': '2',
        'name': 'تمارين القوة - الجزء العلوي',
        'type': 'strength',
        'duration': 50,
        'caloriesBurned': 280,
        'difficulty': 'متقدم',
        'exercises': [
          {'name': 'تمرين الضغط', 'sets': 3, 'reps': 12, 'duration': 0, 'calories': 50},
          {'name': 'رفع الدمبل', 'sets': 3, 'reps': 15, 'duration': 0, 'calories': 60},
          {'name': 'تمرين البلانك', 'sets': 3, 'reps': 0, 'duration': 1, 'calories': 40},
          {'name': 'تمرين الذراعين', 'sets': 3, 'reps': 12, 'duration': 0, 'calories': 45},
          {'name': 'تمرين الكتف', 'sets': 3, 'reps': 12, 'duration': 0, 'calories': 45},
        ],
        'completed': false,
        'date': now.toIso8601String(),
        'trainer': 'كابتن سارة',
        'notes': 'ركزي على الفورم الصحيح',
      },
      {
        '_id': '3',
        'name': 'يوغا واسترخاء',
        'type': 'yoga',
        'duration': 40,
        'caloriesBurned': 150,
        'difficulty': 'مبتدئ',
        'exercises': [
          {'name': 'تنفس عميق', 'sets': 1, 'reps': 0, 'duration': 5, 'calories': 10},
          {'name': 'وضعية الطفل', 'sets': 1, 'reps': 0, 'duration': 5, 'calories': 15},
          {'name': 'وضعية الكوبرا', 'sets': 3, 'reps': 0, 'duration': 3, 'calories': 25},
          {'name': 'وضعية المحارب', 'sets': 2, 'reps': 0, 'duration': 5, 'calories': 40},
          {'name': 'تأمل', 'sets': 1, 'reps': 0, 'duration': 10, 'calories': 20},
        ],
        'completed': false,
        'date': now.add(const Duration(days: 1)).toIso8601String(),
        'trainer': 'كابتن سارة',
        'notes': 'جلسة استرخاء بعد أسبوع مكثف',
      },
      {
        '_id': '4',
        'name': 'تمارين القوة - الجزء السفلي',
        'type': 'strength',
        'duration': 55,
        'caloriesBurned': 350,
        'difficulty': 'متقدم',
        'exercises': [
          {'name': 'سكوات', 'sets': 4, 'reps': 15, 'duration': 0, 'calories': 80},
          {'name': 'لانجز', 'sets': 3, 'reps': 12, 'duration': 0, 'calories': 70},
          {'name': 'ديدليفت', 'sets': 3, 'reps': 10, 'duration': 0, 'calories': 90},
          {'name': 'تمرين الأرداف', 'sets': 3, 'reps': 15, 'duration': 0, 'calories': 60},
          {'name': 'تمرين السمانة', 'sets': 3, 'reps': 20, 'duration': 0, 'calories': 50},
        ],
        'completed': false,
        'date': now.add(const Duration(days: 2)).toIso8601String(),
        'trainer': 'كابتن سارة',
        'notes': 'زيدي الأوزان تدريجياً',
      },
    ];
  }

  // خطة الوجبات اليومية - ترجع قائمة فارغة (يضيفها المدرب)
  static Future<List<dynamic>> getMeals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // إرجاع قائمة فارغة - الوجبات تأتي من المدرب
    return [];
  }

  // المدربات - ترجع قائمة فارغة (يضيفها الأدمن)
  static Future<List<dynamic>> getTrainers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // إرجاع قائمة فارغة - المدربين يضيفهم الأدمن
    return [];
  }

  // الورش والفعاليات - ترجع قائمة فارغة (يضيفها الأدمن)
  static Future<List<dynamic>> getWorkshops() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // إرجاع قائمة فارغة - الورش يضيفها الأدمن
    return [];
  }

  // بيانات التقدم
  static Future<List<dynamic>> getProgress() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      {
        '_id': '1',
        'weight': 68.0,
        'bodyFat': 28.5,
        'muscleMass': 42.2,
        'waist': 82,
        'hips': 98,
        'chest': 92,
        'arm': 28,
        'thigh': 58,
        'date': now.subtract(const Duration(days: 30)).toIso8601String(),
        'notes': 'بداية البرنامج',
      },
      {
        '_id': '2',
        'weight': 66.5,
        'bodyFat': 27.0,
        'muscleMass': 43.0,
        'waist': 79,
        'hips': 96,
        'chest': 91,
        'arm': 28.5,
        'thigh': 57,
        'date': now.subtract(const Duration(days: 15)).toIso8601String(),
        'notes': 'تحسن ملحوظ في الخصر',
      },
      {
        '_id': '3',
        'weight': 65.0,
        'bodyFat': 25.5,
        'muscleMass': 44.0,
        'waist': 76,
        'hips': 94,
        'chest': 90,
        'arm': 29,
        'thigh': 56,
        'date': now.toIso8601String(),
        'notes': 'نتائج ممتازة! استمري',
      },
    ];
  }

  // الاشتراك الحالي
  static Future<Map<String, dynamic>> getMySubscription() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'id': 'sub_premium_2024',
      'plan': 'premium',
      'planName': 'الباقة المميزة',
      'status': 'active',
      'startDate': '2024-12-01',
      'endDate': '2025-12-01',
      'price': 1200.0,
      'monthlyPrice': 100.0,
      'daysRemaining': 337,
      'features': [
        'جلسات تدريب شخصية غير محدودة',
        'خطة تغذية مخصصة ومتابعة أسبوعية',
        'جلسات أونلاين عبر Zoom',
        'دخول لجميع الورش والفعاليات',
        'دعم واتساب مباشر مع المدربة',
        'تقارير تقدم شهرية',
      ],
      'trainer': {
        'name': 'كابتن سارة الحربي',
        'phone': '0559876543',
        'whatsapp': '966559876543',
      },
    };
  }

// إرسال رمز OTP إلى البريد الإلكتروني
  static Future<Map<String, dynamic>> sendOtpEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = demoUsers[email.toLowerCase()];

    if (user == null) {
      return {
        'success': false,
        'message': 'البريد الإلكتروني غير مسجل',
      };
    }

    // إرسال OTP عبر البريد الإلكتروني
    final result = await EmailService.sendOtpEmail(
      email: email,
      userName: user['name'] ?? 'المستخدم',
    );

    return result;
  }

  // التحقق من رمز OTP
  static Future<Map<String, dynamic>> verifyOtpCode(String email, String otp) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (EmailService.verifyOtp(email, otp)) {
      return {
        'success': true,
        'message': 'تم التحقق بنجاح',
      };
    }

    return {
      'success': false,
      'message': 'رمز التحقق غير صحيح أو منتهي الصلاحية',
    };
  }

  // تحديث كلمة المرور في وضع Demo
  static Future<Map<String, dynamic>> updateUserPassword(String email, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final user = demoUsers[email.toLowerCase()];
    if (user != null) {
      user['password'] = newPassword;
      return {
        'success': true,
        'message': 'تم تغيير كلمة المرور بنجاح',
      };
    }
    return {
      'success': false,
      'message': 'المستخدم غير موجود',
    };
  }

  // تسجيل مستخدم جديد
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'user',
  }) async {
    await initialize(); // تأكد من تحميل المستخدمين أولاً
    await Future.delayed(const Duration(milliseconds: 800));

    final emailLower = email.toLowerCase();

    // التحقق من عدم وجود المستخدم مسبقاً
    if (demoUsers.containsKey(emailLower)) {
      return {
        'success': false,
        'message': 'البريد الإلكتروني مسجل مسبقاً',
      };
    }

    // إضافة المستخدم الجديد
    demoUsers[emailLower] = {
      'email': emailLower,
      'password': password,
      'role': role,
      'name': name,
      'phone': phone ?? '',
      'token': 'vitafit_${role}_token_${DateTime.now().millisecondsSinceEpoch}',
      'avatar': '',
    };

    // حفظ المستخدم في التخزين الدائم
    await _saveRegisteredUsers();

    print('✅ تم تسجيل مستخدم جديد: $emailLower');

    return {
      'success': true,
      'message': 'تم التسجيل بنجاح',
      'data': {
        'token': demoUsers[emailLower]!['token'],
        'user': {
          'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
          'name': name,
          'email': emailLower,
          'phone': phone ?? '',
          'role': role,
        }
      }
    };
  }

  // استجابة نجاح
  static Future<Map<String, dynamic>> successResponse([String message = 'تمت العملية بنجاح']) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'success': true,
      'message': message,
    };
  }

  // ملخص التغذية اليومية
  static Future<Map<String, dynamic>> getDailyNutrition() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'date': DateTime.now().toIso8601String(),
      'totalCalories': 1730,
      'targetCalories': 1800,
      'remainingCalories': 70,
      'protein': 125,
      'targetProtein': 130,
      'carbs': 180,
      'targetCarbs': 200,
      'fats': 58,
      'targetFats': 60,
      'water': 6,
      'targetWater': 8,
      'mealsCompleted': 3,
      'totalMeals': 5,
      'percentageComplete': 85,
    };
  }

  // إحصائيات التقدم
  static Future<Map<String, dynamic>> getProgressStats() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'currentWeight': 65.0,
      'startWeight': 68.0,
      'targetWeight': 58.0,
      'weightLost': 3.0,
      'weightRemaining': 7.0,
      'percentageToGoal': 30,
      'currentBodyFat': 25.5,
      'startBodyFat': 28.5,
      'bodyFatLost': 3.0,
      'currentMuscleMass': 44.0,
      'startMuscleMass': 42.2,
      'muscleMassGained': 1.8,
      'workoutsCompleted': 24,
      'totalWorkoutMinutes': 1080,
      'caloriesBurned': 7200,
      'streakDays': 12,
      'bestStreak': 15,
    };
  }

  // سجل الوزن
  static Future<List<dynamic>> getWeightHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      {'date': now.subtract(const Duration(days: 30)).toIso8601String(), 'weight': 68.0},
      {'date': now.subtract(const Duration(days: 27)).toIso8601String(), 'weight': 67.8},
      {'date': now.subtract(const Duration(days: 24)).toIso8601String(), 'weight': 67.5},
      {'date': now.subtract(const Duration(days: 21)).toIso8601String(), 'weight': 67.2},
      {'date': now.subtract(const Duration(days: 18)).toIso8601String(), 'weight': 66.8},
      {'date': now.subtract(const Duration(days: 15)).toIso8601String(), 'weight': 66.5},
      {'date': now.subtract(const Duration(days: 12)).toIso8601String(), 'weight': 66.2},
      {'date': now.subtract(const Duration(days: 9)).toIso8601String(), 'weight': 65.8},
      {'date': now.subtract(const Duration(days: 6)).toIso8601String(), 'weight': 65.5},
      {'date': now.subtract(const Duration(days: 3)).toIso8601String(), 'weight': 65.2},
      {'date': now.toIso8601String(), 'weight': 65.0},
    ];
  }

  // الجلسات الأونلاين مع روابط Zoom فعلية
  static Future<List<dynamic>> getOnlineSessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      {
        'id': 'session_1',
        'title': 'جلسة تدريب شخصية',
        'trainer_name': 'كابتن سارة الحربي',
        'trainer_phone': '0559876543',
        'scheduled_at': now.add(const Duration(hours: 2)).toIso8601String(),
        'duration_minutes': 45,
        'status': 'scheduled',
        'type': 'personal_training',
        'meeting_url': 'https://zoom.us/j/vitafit-personal-session',
        'meeting_id': '123 456 7890',
        'meeting_password': 'vitafit',
        'notes': 'تمارين الجزء العلوي - أحضري الدمبل',
      },
      {
        'id': 'session_2',
        'title': 'جلسة يوغا جماعية',
        'trainer_name': 'كابتن منى القحطاني',
        'trainer_phone': '0551234567',
        'scheduled_at': now.add(const Duration(days: 1, hours: 8)).toIso8601String(),
        'duration_minutes': 60,
        'status': 'scheduled',
        'type': 'group_yoga',
        'meeting_url': 'https://zoom.us/j/vitafit-yoga-class',
        'meeting_id': '987 654 3210',
        'meeting_password': 'yoga2024',
        'notes': 'جلسة صباحية - يوغا للمبتدئات',
      },
      {
        'id': 'session_3',
        'title': 'استشارة تغذية',
        'trainer_name': 'كابتن سارة الحربي',
        'trainer_phone': '0559876543',
        'scheduled_at': now.add(const Duration(days: 2, hours: 4)).toIso8601String(),
        'duration_minutes': 30,
        'status': 'scheduled',
        'type': 'nutrition_consultation',
        'meeting_url': 'https://zoom.us/j/vitafit-nutrition-consult',
        'meeting_id': '456 789 0123',
        'meeting_password': 'nutrition',
        'notes': 'مراجعة خطة التغذية الأسبوعية',
      },
      {
        'id': 'session_4',
        'title': 'جلسة تدريب HIIT',
        'trainer_name': 'كابتن سارة الحربي',
        'trainer_phone': '0559876543',
        'scheduled_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        'duration_minutes': 45,
        'status': 'completed',
        'type': 'hiit_training',
        'meeting_url': 'https://zoom.us/j/vitafit-hiit',
        'meeting_id': '111 222 3333',
        'meeting_password': 'hiit2024',
        'notes': 'جلسة ممتازة! أداء رائع',
        'rating': 5,
        'feedback': 'كانت الجلسة مكثفة ومفيدة جداً',
      },
    ];
  }

  // الإشعارات
  static Future<List<dynamic>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      {
        'id': '1',
        'title': 'تذكير بالجلسة',
        'body': 'جلستك مع كابتن سارة بعد ساعتين',
        'type': 'session_reminder',
        'read': false,
        'date': now.toIso8601String(),
      },
      {
        'id': '2',
        'title': 'تحديث خطة التغذية',
        'body': 'تم تحديث خطة وجباتك لهذا الأسبوع',
        'type': 'nutrition_update',
        'read': false,
        'date': now.subtract(const Duration(hours: 3)).toIso8601String(),
      },
      {
        'id': '3',
        'title': 'مبروك!',
        'body': 'وصلتي لهدف الأسبوع - 3 تمارين مكتملة',
        'type': 'achievement',
        'read': true,
        'date': now.subtract(const Duration(days: 1)).toIso8601String(),
      },
      {
        'id': '4',
        'title': 'ورشة جديدة',
        'body': 'سجلي الآن في ورشة التغذية الصحية',
        'type': 'workshop',
        'read': true,
        'date': now.subtract(const Duration(days: 2)).toIso8601String(),
      },
    ];
  }

  // الطلبات من المتجر
  static Future<List<dynamic>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      {
        'id': 'ORD-2024-001',
        'date': now.subtract(const Duration(days: 5)).toIso8601String(),
        'status': 'delivered',
        'statusText': 'تم التوصيل',
        'total': 285.0,
        'items': [
          {'name': 'بروتين نباتي - شوكولاتة', 'quantity': 1, 'price': 249.0},
          {'name': 'شيكر رياضي', 'quantity': 1, 'price': 36.0},
        ],
        'address': 'الرياض - حي النرجس',
        'paymentMethod': 'بطاقة ائتمان',
      },
      {
        'id': 'ORD-2024-002',
        'date': now.subtract(const Duration(days: 2)).toIso8601String(),
        'status': 'shipped',
        'statusText': 'جاري التوصيل',
        'total': 199.0,
        'items': [
          {'name': 'بنطال رياضي مرن', 'quantity': 1, 'price': 159.0},
          {'name': 'ربطة شعر رياضية', 'quantity': 2, 'price': 40.0},
        ],
        'address': 'الرياض - حي النرجس',
        'paymentMethod': 'الدفع عند الاستلام',
        'trackingNumber': 'SA123456789',
      },
    ];
  }
}
