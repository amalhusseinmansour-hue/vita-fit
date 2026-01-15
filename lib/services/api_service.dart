import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'demo_service.dart';
import 'local_storage_service.dart';
import 'database_service.dart';

class ApiService {
  // Base URL is now managed in ApiConfig
  // To switch between Emulator and Physical Device, edit lib/config/api_config.dart
  static String get baseUrl => ApiConfig.baseUrl;

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Remove token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_type');
    await prefs.remove('user_data');
  }

  // Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', token);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  // Save user type
  static Future<void> saveUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', userType);
  }

  // Get user type
  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }

  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(userData));
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_data');
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Get headers with token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generic request method for admin and other API calls
  static Future<Map<String, dynamic>> request({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final headers = await getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');

    http.Response response;

    switch (method.toUpperCase()) {
      case 'POST':
        response = await http.post(
          url,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          url,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers);
        break;
      case 'PATCH':
        response = await http.patch(
          url,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
        break;
      default:
        response = await http.get(url, headers: headers);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return json.decode(response.body);
    } else {
      final error = response.body.isNotEmpty
          ? json.decode(response.body)
          : {'message': 'Request failed with status ${response.statusCode}'};
      throw Exception(error['message'] ?? 'Request failed');
    }
  }

  // Get trainee profile
  static Future<Map<String, dynamic>> getProfile() async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'profile': {
          'name': 'مستخدم تجريبي',
          'email': 'demo@vitafit.online',
          'phone': '0501234567',
          'height': 165,
          'current_weight': 60,
        }
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trainee/profile'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update profile (trainee or trainer)
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    double? height,
    double? currentWeight,
    double? targetWeight,
    String? activityLevel,
    String? specialization,
    String? bio,
    int? experienceYears,
    double? hourlyRate,
  }) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم تحديث الملف الشخصي'};
    }

    try {
      final headers = await getHeaders();
      final userType = await getUserType();
      final isTrainer = userType == 'trainer';

      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;

      if (isTrainer) {
        // Trainer specific fields
        if (specialization != null) body['specialization'] = specialization;
        if (bio != null) body['bio'] = bio;
        if (experienceYears != null) body['experience_years'] = experienceYears;
        if (hourlyRate != null) body['hourly_rate'] = hourlyRate;
      } else {
        // Trainee specific fields
        if (height != null) body['height'] = height.toInt();
        if (currentWeight != null) body['current_weight'] = currentWeight;
        if (targetWeight != null) body['target_weight'] = targetWeight;
        if (activityLevel != null) body['activity_level'] = activityLevel;
      }

      final endpoint = isTrainer ? '/trainer/profile' : '/trainee/profile';

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(body),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    int? age,
    String? gender,
    double? height,
    double? weight,
  }) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.registerUser(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: 'user',
      );
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/trainee/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          if (phone != null) 'phone': phone,
          if (gender != null) 'gender': gender,
          if (height != null) 'height': height,
          if (weight != null) 'weight': weight,
        }),
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      print('📥 Register response: $data');

      // Handle validation errors
      if (data['success'] == false && data['errors'] != null) {
        // Convert validation errors to readable message
        final errors = data['errors'] as Map<String, dynamic>;
        final errorMessages = <String>[];
        errors.forEach((key, value) {
          if (value is List) {
            errorMessages.addAll(value.map((e) => e.toString()));
          } else {
            errorMessages.add(value.toString());
          }
        });
        return {
          'success': false,
          'message': errorMessages.join('\n'),
        };
      }

      // Token can be in data.token or data.data.token
      if (data['success'] == true) {
        final token = data['token'] ?? data['data']?['token'];
        if (token != null) {
          await saveToken(token);
        }
        // Normalize response to have data wrapper
        return {
          'success': true,
          'message': data['message'] ?? 'تم إنشاء الحساب بنجاح',
          'data': {
            'token': token,
            'user': data['user'] ?? data['data']?['user'],
          }
        };
      }
      return data;
    } catch (e) {
      print('❌ Register error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Login - unified endpoint for all users
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String userType = 'trainee', // 'trainee', 'trainer', 'admin'
  }) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.login(email, password);
    }

    try {
      // Use endpoint based on user type
      String endpoint;
      if (userType == 'trainer') {
        endpoint = '$baseUrl/auth/trainer/login';
      } else {
        endpoint = '$baseUrl/auth/trainee/login';
      }

      print('🔄 Attempting to connect to: $endpoint');

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConfig.timeout);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      final data = json.decode(response.body);

      // Handle validation errors
      if (data['success'] == false && data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final errorMessages = <String>[];
        errors.forEach((key, value) {
          if (value is List) {
            errorMessages.addAll(value.map((e) => e.toString()));
          } else {
            errorMessages.add(value.toString());
          }
        });
        return {
          'success': false,
          'message': errorMessages.join('\n'),
        };
      }

      // Token can be directly in response or inside data
      if (data['success'] == true) {
        final token = data['token'] ?? data['data']?['token'];
        final user = data['user'] ?? data['data']?['user'];
        if (token != null) {
          await saveToken(token);
          await saveUserType(userType);
          if (user != null) {
            await saveUserData(user);
          }
        }
        // Normalize response to have data wrapper
        return {
          'success': true,
          'message': data['message'] ?? 'تم تسجيل الدخول بنجاح',
          'data': {
            'token': token,
            'user': user,
            'user_type': userType,
          }
        };
      }

      // Return error message
      return {
        'success': false,
        'message': data['message'] ?? 'فشل تسجيل الدخول',
      };
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال: ${e.toString()}',
      };
    }
  }

  // Forgot Password - Send OTP
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    if (ApiConfig.isDemoMode) {
      // إرسال OTP فعلياً إلى البريد الإلكتروني
      return await DemoService.sendOtpEmail(email);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email}),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    if (ApiConfig.isDemoMode) {
      // التحقق من OTP فعلياً
      return await DemoService.verifyOtpCode(email, otp);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'otp': otp,
        }),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String password,
  ) async {
    if (ApiConfig.isDemoMode) {
      // تحديث كلمة المرور فعلياً في وضع Demo
      return await DemoService.updateUserPassword(email, password);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': password,
        }),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Verify Email with code
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-email'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'code': code,
        }),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Resend verification code
  static Future<Map<String, dynamic>> resendVerification({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/resend-verification'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email}),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Refresh access token
  static Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return {'success': false, 'message': 'No refresh token'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'refreshToken': refreshToken}),
      ).timeout(ApiConfig.timeout);

      final result = json.decode(response.body);
      if (result['success'] == true && result['data']?['token'] != null) {
        await saveToken(result['data']['token']);
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get current user
  static Future<Map<String, dynamic>> getMe() async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.successResponse();
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: headers,
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update password
  static Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.successResponse();
    }

    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/auth/updatepassword'),
        headers: headers,
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      await removeToken();
      return await DemoService.successResponse();
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: headers,
      );

      await removeToken();
      return json.decode(response.body);
    } catch (e) {
      await removeToken();
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Workouts ==========

  // Get all workouts
  static Future<List<dynamic>> getWorkouts({bool forceRefresh = false}) async {
    // Try to get from SQLite database first
    if (!forceRefresh) {
      try {
        final dbWorkouts = await DatabaseService.getWorkouts();
        if (dbWorkouts.isNotEmpty) {
          return dbWorkouts;
        }
      } catch (e) {
        debugPrint('Database error: $e');
      }
    }

    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      final workouts = await DemoService.getWorkouts();
      await DatabaseService.saveWorkouts(workouts);
      return workouts;
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/workouts'),
        headers: headers,
      );

      final data = json.decode(response.body);
      final workouts = data['success'] ? (data['data'] ?? []) : [];

      // Save to SQLite database
      if (workouts.isNotEmpty) {
        await DatabaseService.saveWorkouts(workouts);
      }

      return workouts;
    } catch (e) {
      // On error, return data from database
      try {
        return await DatabaseService.getWorkouts();
      } catch (_) {
        return [];
      }
    }
  }

  // Get live classes for training screen
  static Future<List<dynamic>> getLiveClasses() async {
    if (ApiConfig.isDemoMode) {
      return [
        {
          'id': '1',
          'title': 'يوغا صباحية',
          'instructor': 'سارة أحمد',
          'time': '08:00 ص',
          'duration': 45,
          'level': 'مبتدئ',
          'participants': 234,
          'category': 'yoga',
          'isLive': true,
        },
        {
          'id': '2',
          'title': 'كارديو حارق',
          'instructor': 'ليلى محمد',
          'time': '10:00 ص',
          'duration': 30,
          'level': 'متقدم',
          'participants': 189,
          'category': 'cardio',
          'isLive': false,
        },
        {
          'id': '3',
          'title': 'تمارين المقاومة',
          'instructor': 'كابتن سارة',
          'time': '02:00 م',
          'duration': 50,
          'level': 'متوسط',
          'participants': 156,
          'category': 'strength',
          'isLive': false,
        },
        {
          'id': '4',
          'title': 'زومبا راقصة',
          'instructor': 'مريم علي',
          'time': '05:00 م',
          'duration': 60,
          'level': 'مبتدئ',
          'participants': 298,
          'category': 'cardio',
          'isLive': true,
        },
        {
          'id': '5',
          'title': 'بيلاتس للمرونة',
          'instructor': 'دينا حسن',
          'time': '07:00 م',
          'duration': 40,
          'level': 'متوسط',
          'participants': 167,
          'category': 'yoga',
          'isLive': false,
        },
      ];
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/live-classes'),
        headers: headers,
      );

      final data = json.decode(response.body);
      return data['success'] ? (data['data'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  // Create workout
  static Future<Map<String, dynamic>> createWorkout(Map<String, dynamic> workout) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.successResponse();
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/workouts'),
        headers: headers,
        body: json.encode(workout),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update workout
  static Future<Map<String, dynamic>> updateWorkout(String id, Map<String, dynamic> workout) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.successResponse();
    }

    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/workouts/$id'),
        headers: headers,
        body: json.encode(workout),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Delete workout
  static Future<Map<String, dynamic>> deleteWorkout(String id) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.successResponse();
    }

    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/workouts/$id'),
        headers: headers,
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Meals ==========

  // Get all meals
  static Future<List<dynamic>> getMeals({bool forceRefresh = false}) async {
    // Try to get from SQLite database first
    if (!forceRefresh) {
      try {
        final dbMeals = await DatabaseService.getMeals();
        if (dbMeals.isNotEmpty) {
          return dbMeals;
        }
      } catch (e) {
        debugPrint('Database error: $e');
      }
    }

    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      final meals = await DemoService.getMeals();
      await DatabaseService.saveMeals(meals);
      return meals;
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/meals'),
        headers: headers,
      );

      final data = json.decode(response.body);
      final meals = data['success'] ? (data['data'] ?? []) : [];

      // Save to SQLite database
      if (meals.isNotEmpty) {
        await DatabaseService.saveMeals(meals);
      }

      return meals;
    } catch (e) {
      // On error, return data from database
      try {
        return await DatabaseService.getMeals();
      } catch (_) {
        return [];
      }
    }
  }

  // Get nutrition goals from trainer/admin settings
  static Future<Map<String, dynamic>> getNutritionGoals() async {
    if (ApiConfig.isDemoMode) {
      // في وضع Demo، إرجاع قيم فارغة (المدرب لم يحدد أهداف)
      return {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0};
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/nutrition/goals'),
        headers: headers,
      );

      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return Map<String, dynamic>.from(data['data']);
      }
      return {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0};
    } catch (e) {
      return {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0};
    }
  }

  // Create meal
  static Future<Map<String, dynamic>> createMeal(Map<String, dynamic> meal) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.successResponse();
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/meals'),
        headers: headers,
        body: json.encode(meal),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get daily nutrition
  static Future<Map<String, dynamic>> getDailyNutrition() async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.getDailyNutrition();
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/meals/daily-nutrition'),
        headers: headers,
      );

      final data = json.decode(response.body);
      return data['success'] ? (data['data'] ?? {}) : {};
    } catch (e) {
      return {};
    }
  }

  // ========== Subscriptions ==========

  // Subscribe to plan
  static Future<Map<String, dynamic>> subscribe({
    required String plan,
    required String planName,
    required double price,
  }) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.successResponse();
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/subscribe'),
        headers: headers,
        body: json.encode({
          'plan': plan,
          'planName': planName,
          'price': price,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get my subscription
  static Future<Map<String, dynamic>> getMySubscription() async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.getMySubscription();
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/my-subscription'),
        headers: headers,
      );

      final data = json.decode(response.body);
      return data['success'] ? (data['data'] ?? {}) : {};
    } catch (e) {
      return {};
    }
  }

  // ========== Classes ==========

  // Get all classes (fitness sessions)
  static Future<List<dynamic>> getClasses() async {
    if (ApiConfig.isDemoMode) {
      // في وضع Demo، إرجاع قائمة فارغة (لا توجد حصص)
      return [];
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/classes'),
        headers: headers,
      );

      final data = json.decode(response.body);
      return data['success'] ? (data['data'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  // ========== Trainers ==========

  // Get all trainers
  static Future<List<dynamic>> getTrainers({String? specialization}) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.getTrainers();
    }

    try {
      String url = '$baseUrl/trainers';
      if (specialization != null) {
        url += '?specialization=$specialization';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data['success'] ? (data['data'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  // Get trainer by ID
  static Future<Map<String, dynamic>> getTrainer(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trainers/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data['success'] ? (data['data'] ?? {}) : {};
    } catch (e) {
      return {};
    }
  }

  // ========== Workshops ==========

  // Get all workshops
  static Future<List<dynamic>> getWorkshops({String? category, bool upcoming = false}) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.getWorkshops();
    }

    try {
      String url = '$baseUrl/workshops';
      List<String> params = [];
      if (category != null) params.add('category=$category');
      if (upcoming) params.add('upcoming=true');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      return data['success'] ? (data['data'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  // Register for workshop
  static Future<Map<String, dynamic>> registerForWorkshop(String id) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.successResponse();
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/workshops/$id/register'),
        headers: headers,
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get my workshops
  static Future<List<dynamic>> getMyWorkshops() async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.getWorkshops();
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/workshops/user/my-workshops'),
        headers: headers,
      );

      final data = json.decode(response.body);
      return data['success'] ? (data['data'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  // ========== Progress ==========

  // Get all progress entries
  static Future<List<dynamic>> getProgress() async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.getProgress();
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/progress'),
        headers: headers,
      );

      final data = json.decode(response.body);
      return data['success'] ? (data['data'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  // Create progress entry
  static Future<Map<String, dynamic>> createProgress(Map<String, dynamic> progress) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.successResponse();
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/progress'),
        headers: headers,
        body: json.encode(progress),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get progress statistics
  static Future<Map<String, dynamic>> getProgressStats() async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.getProgressStats();
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/progress/stats/summary'),
        headers: headers,
      );

      final data = json.decode(response.body);
      return data['success'] ? (data['data'] ?? {}) : {};
    } catch (e) {
      return {};
    }
  }

  // Get weight history
  static Future<List<dynamic>> getWeightHistory({int days = 30}) async {
    // استخدام البيانات التجريبية في وضع Demo
    if (ApiConfig.isDemoMode) {
      return await DemoService.getWeightHistory();
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/progress/stats/weight-history?days=$days'),
        headers: headers,
      );

      final data = json.decode(response.body);
      return data['success'] ? (data['data'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  // ========== Admin API ==========

  // Get admin dashboard statistics
  static Future<Map<String, dynamic>> getAdminStats() async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'data': {
          'totalUsers': 150,
          'activeUsers': 120,
          'totalTrainers': 12,
          'activeTrainers': 10,
          'totalSubscriptions': 85,
          'activeSubscriptions': 70,
          'totalRevenue': 45000.0,
          'monthlyRevenue': 12500.0,
          'totalOrders': 40,
          'pendingOrders': 5,
        }
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Admin Users Management ==========

  // Get all users (admin)
  static Future<Map<String, dynamic>> getAdminUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? role,
  }) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'data': [
          {'id': '1', 'name': 'أحمد محمد', 'email': 'ahmed@example.com', 'phone': '0501234567', 'role': 'user', 'isActive': true, 'subscription': 'Gold', 'createdAt': '2024-01-15'},
          {'id': '2', 'name': 'سارة علي', 'email': 'sara@example.com', 'phone': '0507654321', 'role': 'user', 'isActive': true, 'subscription': 'Silver', 'createdAt': '2024-02-20'},
          {'id': '3', 'name': 'محمد خالد', 'email': 'mohamed@example.com', 'phone': '0509876543', 'role': 'user', 'isActive': false, 'subscription': 'Basic', 'createdAt': '2024-03-10'},
          {'id': '4', 'name': 'فاطمة أحمد', 'email': 'fatima@example.com', 'phone': '0503456789', 'role': 'user', 'isActive': true, 'subscription': 'Diamond', 'createdAt': '2024-01-05'},
          {'id': '5', 'name': 'عمر حسن', 'email': 'omar@example.com', 'phone': '0502345678', 'role': 'user', 'isActive': true, 'subscription': 'Gold', 'createdAt': '2024-04-01'},
        ],
        'pagination': {'total': 150, 'page': page, 'limit': limit, 'pages': 8}
      };
    }

    try {
      final headers = await getHeaders();
      String url = '$baseUrl/admin/users?page=$page&limit=$limit';
      if (search != null && search.isNotEmpty) url += '&search=$search';
      if (status != null) url += '&status=$status';
      if (role != null) url += '&role=$role';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get user by ID (admin)
  static Future<Map<String, dynamic>> getAdminUser(String id) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'data': {
          'id': id,
          'name': 'أحمد محمد',
          'email': 'ahmed@example.com',
          'phone': '0501234567',
          'role': 'user',
          'isActive': true,
          'subscription': {'plan': 'Gold', 'status': 'active', 'expiresAt': '2025-01-15'},
          'stats': {'totalWorkouts': 45, 'totalCaloriesBurned': 12500},
          'createdAt': '2024-01-15',
        }
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users/$id'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update user (admin)
  static Future<Map<String, dynamic>> updateAdminUser(String id, Map<String, dynamic> data) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم تحديث المستخدم بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$id'),
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Delete user (admin)
  static Future<Map<String, dynamic>> deleteAdminUser(String id) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم حذف المستخدم بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$id'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Toggle user status (admin)
  static Future<Map<String, dynamic>> toggleUserStatus(String id, bool isActive) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': isActive ? 'تم تفعيل الحساب' : 'تم تعطيل الحساب'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$id/status'),
        headers: headers,
        body: json.encode({'isActive': isActive}),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Admin Trainers Management ==========

  // Get all trainers (admin)
  static Future<Map<String, dynamic>> getAdminTrainers({
    int page = 1,
    int limit = 20,
    String? search,
    String? specialization,
    bool? isActive,
  }) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'data': [
          {'id': '1', 'name': 'كابتن أحمد', 'email': 'captain.ahmed@gym.com', 'phone': '0551234567', 'specialization': 'قوة', 'experience': 8, 'rating': 4.8, 'clientsCount': 15, 'isActive': true, 'certifications': ['NASM', 'ACE']},
          {'id': '2', 'name': 'كابتن سارة', 'email': 'captain.sara@gym.com', 'phone': '0557654321', 'specialization': 'يوغا', 'experience': 5, 'rating': 4.9, 'clientsCount': 12, 'isActive': true, 'certifications': ['RYT 500']},
          {'id': '3', 'name': 'كابتن محمد', 'email': 'captain.mohamed@gym.com', 'phone': '0559876543', 'specialization': 'كارديو', 'experience': 6, 'rating': 4.7, 'clientsCount': 18, 'isActive': true, 'certifications': ['ISSA', 'CPR']},
          {'id': '4', 'name': 'كابتن نورة', 'email': 'captain.noura@gym.com', 'phone': '0553456789', 'specialization': 'تغذية', 'experience': 4, 'rating': 4.6, 'clientsCount': 10, 'isActive': false, 'certifications': ['RD', 'CDE']},
        ],
        'pagination': {'total': 12, 'page': page, 'limit': limit, 'pages': 1}
      };
    }

    try {
      final headers = await getHeaders();
      String url = '$baseUrl/admin/trainers?page=$page&limit=$limit';
      if (search != null && search.isNotEmpty) url += '&search=$search';
      if (specialization != null) url += '&specialization=$specialization';
      if (isActive != null) url += '&isActive=$isActive';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Create trainer (admin)
  static Future<Map<String, dynamic>> createAdminTrainer(Map<String, dynamic> data) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم إضافة المدرب بنجاح', 'data': {'id': DateTime.now().millisecondsSinceEpoch.toString(), ...data}};
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/trainers'),
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update trainer (admin)
  static Future<Map<String, dynamic>> updateAdminTrainer(String id, Map<String, dynamic> data) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم تحديث المدرب بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/trainers/$id'),
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Delete trainer (admin)
  static Future<Map<String, dynamic>> deleteAdminTrainer(String id) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم حذف المدرب بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/trainers/$id'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Assign client to trainer (admin)
  static Future<Map<String, dynamic>> assignClientToTrainer(String trainerId, String clientId) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم تعيين العميل للمدرب بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/trainers/$trainerId/assign-client'),
        headers: headers,
        body: json.encode({'clientId': clientId}),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Admin Subscriptions Management ==========

  // Get all subscriptions (admin)
  static Future<Map<String, dynamic>> getAdminSubscriptions({
    int page = 1,
    int limit = 20,
    String? status,
    String? plan,
  }) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'data': [
          {'id': '1', 'userId': '1', 'userName': 'أحمد محمد', 'plan': 'Gold', 'price': 299.0, 'status': 'active', 'startDate': '2024-12-01', 'endDate': '2025-03-01'},
          {'id': '2', 'userId': '2', 'userName': 'سارة علي', 'plan': 'Silver', 'price': 199.0, 'status': 'active', 'startDate': '2024-11-15', 'endDate': '2025-02-15'},
          {'id': '3', 'userId': '3', 'userName': 'محمد خالد', 'plan': 'Basic', 'price': 99.0, 'status': 'expired', 'startDate': '2024-09-01', 'endDate': '2024-12-01'},
        ],
        'pagination': {'total': 85, 'page': page, 'limit': limit, 'pages': 5}
      };
    }

    try {
      final headers = await getHeaders();
      String url = '$baseUrl/admin/subscriptions?page=$page&limit=$limit';
      if (status != null) url += '&status=$status';
      if (plan != null) url += '&plan=$plan';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update subscription (admin)
  static Future<Map<String, dynamic>> updateAdminSubscription(String id, Map<String, dynamic> data) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم تحديث الاشتراك بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/subscriptions/$id'),
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Cancel subscription (admin)
  static Future<Map<String, dynamic>> cancelAdminSubscription(String id) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم إلغاء الاشتراك بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/subscriptions/$id'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Admin Subscription Plans Management ==========

  // Get subscription plans
  static Future<Map<String, dynamic>> getSubscriptionPlans() async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'data': [
          {'id': '1', 'name': 'Basic', 'nameAr': 'الأساسية', 'price': 99.0, 'duration': 30, 'features': ['تمارين أساسية', 'متابعة التقدم'], 'isActive': true},
          {'id': '2', 'name': 'Silver', 'nameAr': 'الفضية', 'price': 199.0, 'duration': 30, 'features': ['جميع مميزات الأساسية', 'خطة غذائية', 'دعم عبر الواتساب'], 'isActive': true},
          {'id': '3', 'name': 'Gold', 'nameAr': 'الذهبية', 'price': 299.0, 'duration': 30, 'features': ['جميع مميزات الفضية', 'مدرب شخصي', 'جلسات مباشرة'], 'isActive': true},
          {'id': '4', 'name': 'Diamond', 'nameAr': 'الماسية', 'price': 499.0, 'duration': 30, 'features': ['جميع مميزات الذهبية', 'أولوية الحجز', 'استشارات غير محدودة'], 'isActive': true},
        ]
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/plans'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update subscription plan
  static Future<Map<String, dynamic>> updateSubscriptionPlan(String id, Map<String, dynamic> data) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم تحديث الخطة بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/plans/$id'),
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Subscribe to a plan
  static Future<Map<String, dynamic>> subscribeToPlan(String planId) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'success': true,
        'message': 'تم الاشتراك بنجاح! مرحباً بك في VitaFit',
        'data': {
          'subscriptionId': 'sub_${DateTime.now().millisecondsSinceEpoch}',
          'planId': planId,
          'status': 'active',
          'startDate': DateTime.now().toIso8601String(),
          'endDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        }
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/subscribe'),
        headers: headers,
        body: json.encode({'planId': planId}),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Admin Products Management ==========

  // Get all products (admin)
  static Future<Map<String, dynamic>> getAdminProducts({
    int page = 1,
    int limit = 20,
    String? category,
    bool? inStock,
  }) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'data': [
          {'id': '1', 'name': 'بروتين واي', 'nameEn': 'Whey Protein', 'price': 250.0, 'category': 'مكملات', 'stock': 50, 'isActive': true, 'image': ''},
          {'id': '2', 'name': 'كرياتين', 'nameEn': 'Creatine', 'price': 120.0, 'category': 'مكملات', 'stock': 35, 'isActive': true, 'image': ''},
          {'id': '3', 'name': 'حزام رفع الأثقال', 'nameEn': 'Weightlifting Belt', 'price': 180.0, 'category': 'معدات', 'stock': 20, 'isActive': true, 'image': ''},
          {'id': '4', 'name': 'قفازات تدريب', 'nameEn': 'Training Gloves', 'price': 85.0, 'category': 'معدات', 'stock': 0, 'isActive': false, 'image': ''},
        ],
        'pagination': {'total': 24, 'page': page, 'limit': limit, 'pages': 2}
      };
    }

    try {
      final headers = await getHeaders();
      String url = '$baseUrl/admin/products?page=$page&limit=$limit';
      if (category != null) url += '&category=$category';
      if (inStock != null) url += '&inStock=$inStock';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Create product (admin)
  static Future<Map<String, dynamic>> createAdminProduct(Map<String, dynamic> data) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم إضافة المنتج بنجاح', 'data': {'id': DateTime.now().millisecondsSinceEpoch.toString(), ...data}};
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/admin/products'),
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update product (admin)
  static Future<Map<String, dynamic>> updateAdminProduct(String id, Map<String, dynamic> data) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم تحديث المنتج بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/products/$id'),
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Delete product (admin)
  static Future<Map<String, dynamic>> deleteAdminProduct(String id) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم حذف المنتج بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/products/$id'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Admin Settings Management ==========

  // Get app settings
  static Future<Map<String, dynamic>> getAppSettings({String? group}) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'data': {
          'general': {
            'appName': 'VitaFit',
            'appNameAr': 'فيتافيت',
            'supportEmail': 'support@vitafit.online',
            'supportPhone': '+966500000000',
          },
          'appearance': {
            'primaryColor': '#4CAF50',
            'secondaryColor': '#2196F3',
            'darkMode': false,
          },
          'notifications': {
            'emailEnabled': true,
            'smsEnabled': true,
            'pushEnabled': true,
          },
          'app_version': {
            'currentVersion': '1.0.0',
            'minVersion': '1.0.0',
            'updateUrl': 'https://play.google.com/store/apps/details?id=com.vitafit.app',
            'forceUpdate': false,
          },
        }
      };
    }

    try {
      final headers = await getHeaders();
      String url = '$baseUrl/admin/settings';
      if (group != null) url += '?group=$group';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update app settings
  static Future<Map<String, dynamic>> updateAppSettings(String group, Map<String, dynamic> settings) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم حفظ الإعدادات بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/settings/$group'),
        headers: headers,
        body: json.encode(settings),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Admin Reports ==========

  // Get reports data
  static Future<Map<String, dynamic>> getAdminReports({
    required String reportType,
    String? startDate,
    String? endDate,
  }) async {
    if (ApiConfig.isDemoMode) {
      switch (reportType) {
        case 'users':
          return {
            'success': true,
            'data': {
              'totalUsers': 150,
              'newUsersThisMonth': 25,
              'activeUsers': 120,
              'usersByPlan': {'Basic': 40, 'Silver': 50, 'Gold': 45, 'Diamond': 15},
              'userGrowth': [
                {'month': 'يناير', 'count': 100},
                {'month': 'فبراير', 'count': 115},
                {'month': 'مارس', 'count': 130},
                {'month': 'أبريل', 'count': 150},
              ],
            }
          };
        case 'revenue':
          return {
            'success': true,
            'data': {
              'totalRevenue': 45000.0,
              'monthlyRevenue': 12500.0,
              'revenueByPlan': {'Basic': 4000, 'Silver': 10000, 'Gold': 18000, 'Diamond': 13000},
              'revenueGrowth': [
                {'month': 'يناير', 'amount': 8000},
                {'month': 'فبراير', 'amount': 9500},
                {'month': 'مارس', 'amount': 11000},
                {'month': 'أبريل', 'amount': 12500},
              ],
            }
          };
        case 'trainers':
          return {
            'success': true,
            'data': {
              'totalTrainers': 12,
              'activeTrainers': 10,
              'totalSessions': 450,
              'averageRating': 4.7,
              'topTrainers': [
                {'name': 'كابتن أحمد', 'sessions': 85, 'rating': 4.9},
                {'name': 'كابتن سارة', 'sessions': 72, 'rating': 4.8},
                {'name': 'كابتن محمد', 'sessions': 68, 'rating': 4.7},
              ],
            }
          };
        default:
          return {'success': true, 'data': {}};
      }
    }

    try {
      final headers = await getHeaders();
      String url = '$baseUrl/admin/reports/$reportType';
      List<String> params = [];
      if (startDate != null) params.add('startDate=$startDate');
      if (endDate != null) params.add('endDate=$endDate');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Admin Orders Management ==========

  // Get all orders (admin)
  static Future<Map<String, dynamic>> getAdminOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'data': [
          {'id': '1', 'userId': '1', 'userName': 'أحمد محمد', 'total': 450.0, 'status': 'pending', 'itemsCount': 2, 'createdAt': '2024-12-25'},
          {'id': '2', 'userId': '2', 'userName': 'سارة علي', 'total': 250.0, 'status': 'completed', 'itemsCount': 1, 'createdAt': '2024-12-24'},
          {'id': '3', 'userId': '4', 'userName': 'فاطمة أحمد', 'total': 180.0, 'status': 'shipped', 'itemsCount': 1, 'createdAt': '2024-12-23'},
        ],
        'pagination': {'total': 40, 'page': page, 'limit': limit, 'pages': 2}
      };
    }

    try {
      final headers = await getHeaders();
      String url = '$baseUrl/admin/orders?page=$page&limit=$limit';
      if (status != null) url += '&status=$status';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update order status (admin)
  static Future<Map<String, dynamic>> updateOrderStatus(String id, String status) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم تحديث حالة الطلب بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/orders/$id/status'),
        headers: headers,
        body: json.encode({'status': status}),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Admin Categories Management ==========

  // Get all categories (admin)
  static Future<Map<String, dynamic>> getAdminCategories() async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'data': [
          {'id': 1, 'name': 'Supplements', 'name_ar': 'المكملات الغذائية', 'slug': 'supplements', 'is_active': true, 'sort_order': 1},
          {'id': 2, 'name': 'Equipment', 'name_ar': 'المعدات الرياضية', 'slug': 'equipment', 'is_active': true, 'sort_order': 2},
          {'id': 3, 'name': 'Apparel', 'name_ar': 'الملابس الرياضية', 'slug': 'apparel', 'is_active': true, 'sort_order': 3},
        ]
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Create category (admin)
  static Future<Map<String, dynamic>> createAdminCategory(Map<String, dynamic> data) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم إضافة الفئة بنجاح', 'data': {'id': DateTime.now().millisecondsSinceEpoch, ...data}};
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/categories'),
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update category (admin)
  static Future<Map<String, dynamic>> updateAdminCategory(int id, Map<String, dynamic> data) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم تحديث الفئة بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/categories/$id'),
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Delete category (admin)
  static Future<Map<String, dynamic>> deleteAdminCategory(int id) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم حذف الفئة بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/categories/$id'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Admin Coupons Management ==========

  // Get all coupons (admin)
  static Future<Map<String, dynamic>> getAdminCoupons() async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'data': [
          {'id': 1, 'code': 'WELCOME10', 'type': 'percentage', 'value': 10, 'min_order': 100, 'is_active': true, 'used_count': 25},
          {'id': 2, 'code': 'NEWYEAR25', 'type': 'percentage', 'value': 25, 'min_order': 500, 'is_active': true, 'used_count': 15},
          {'id': 3, 'code': 'FLAT50', 'type': 'fixed', 'value': 50, 'min_order': 300, 'is_active': true, 'used_count': 10},
        ]
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/coupons'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Create coupon (admin)
  static Future<Map<String, dynamic>> createAdminCoupon(Map<String, dynamic> data) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم إضافة الكوبون بنجاح', 'data': {'id': DateTime.now().millisecondsSinceEpoch, ...data}};
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/coupons'),
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update coupon (admin)
  static Future<Map<String, dynamic>> updateAdminCoupon(int id, Map<String, dynamic> data) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم تحديث الكوبون بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/coupons/$id'),
        headers: headers,
        body: json.encode(data),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Delete coupon (admin)
  static Future<Map<String, dynamic>> deleteAdminCoupon(int id) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم حذف الكوبون بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/coupons/$id'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Admin Order Details ==========

  // Get order details (admin)
  static Future<Map<String, dynamic>> getAdminOrderDetails(String id) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'data': {
          'id': id,
          'order_number': 'ORD-2024-001',
          'user': {'id': 1, 'name': 'أحمد محمد', 'email': 'ahmed@example.com', 'phone': '0501234567'},
          'items': [
            {'id': 1, 'product_name': 'بروتين واي', 'price': 250.0, 'quantity': 1, 'total': 250.0},
            {'id': 2, 'product_name': 'كرياتين', 'price': 120.0, 'quantity': 2, 'total': 240.0},
          ],
          'subtotal': 490.0,
          'discount': 49.0,
          'shipping_cost': 50.0,
          'total': 491.0,
          'status': 'pending',
          'payment_status': 'paid',
          'payment_method': 'card',
          'shipping_address': 'القاهرة - مصر الجديدة',
          'notes': '',
          'created_at': '2024-12-25T10:30:00Z',
        }
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Products (User) ==========

  // Get all products for users
  static Future<List<dynamic>> getProducts({String? category, bool forceRefresh = false}) async {
    // Try to get from SQLite database first (if not forcing refresh)
    if (!forceRefresh) {
      try {
        final dbProducts = await DatabaseService.getProducts(category: category);
        if (dbProducts.isNotEmpty) {
          return dbProducts;
        }
      } catch (e) {
        debugPrint('Database error: $e');
      }
    }

    if (ApiConfig.isDemoMode) {
      final products = [
        {
          'id': '1',
          'name': 'بنطال رياضي مرن',
          'description': 'بنطال رياضي عالي الجودة مناسب لجميع التمارين',
          'price': 199.00,
          'discount': 20,
          'category': 'ملابس',
          'images': ['https://images.unsplash.com/photo-1506629082955-511b1aa562c8?w=400'],
          'rating': 4.5,
          'reviews': 89,
          'sizes': ['S', 'M', 'L', 'XL'],
          'colors': ['أسود', 'وردي', 'رمادي'],
          'inStock': true,
          'stock': 45,
        },
        {
          'id': '2',
          'name': 'سجادة يوغا متطورة',
          'description': 'سجادة يوغا مضادة للانزلاق بسمك مثالي',
          'price': 149.00,
          'category': 'معدات',
          'images': ['https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400'],
          'rating': 4.8,
          'reviews': 156,
          'sizes': ['واحد'],
          'colors': ['بنفسجي', 'وردي', 'أزرق'],
          'inStock': true,
          'stock': 78,
        },
        {
          'id': '3',
          'name': 'بروتين نباتي',
          'description': 'مكمل بروتين نباتي طبيعي 100%',
          'price': 249.00,
          'discount': 15,
          'category': 'مكملات',
          'images': ['https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400'],
          'rating': 4.7,
          'reviews': 234,
          'sizes': ['500g', '1kg'],
          'colors': ['فانيلا', 'شوكولاتة', 'فراولة'],
          'inStock': true,
          'stock': 120,
        },
        {
          'id': '4',
          'name': 'حزام تمرين مقاومة',
          'description': 'مجموعة أحزمة مقاومة متعددة المستويات',
          'price': 89.00,
          'category': 'معدات',
          'images': ['https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400'],
          'rating': 4.6,
          'reviews': 67,
          'sizes': ['واحد'],
          'colors': ['متعدد'],
          'inStock': true,
          'stock': 34,
        },
        {
          'id': '5',
          'name': 'قفازات تمرين',
          'description': 'قفازات تمرين مريحة ومتينة لحماية اليدين',
          'price': 59.00,
          'discount': 10,
          'category': 'إكسسوارات',
          'images': ['https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400'],
          'rating': 4.3,
          'reviews': 45,
          'sizes': ['S', 'M', 'L'],
          'colors': ['أسود', 'وردي'],
          'inStock': true,
          'stock': 56,
        },
        {
          'id': '6',
          'name': 'زجاجة ماء رياضية',
          'description': 'زجاجة ماء 750 مل مع علامات قياس',
          'price': 45.00,
          'category': 'إكسسوارات',
          'images': ['https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400'],
          'rating': 4.4,
          'reviews': 78,
          'sizes': ['750ml'],
          'colors': ['شفاف', 'وردي', 'أزرق'],
          'inStock': true,
          'stock': 150,
        },
        {
          'id': '7',
          'name': 'توب رياضي',
          'description': 'توب رياضي مريح وعصري للتمارين',
          'price': 129.00,
          'discount': 25,
          'category': 'ملابس',
          'images': ['https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=400'],
          'rating': 4.6,
          'reviews': 112,
          'sizes': ['S', 'M', 'L', 'XL'],
          'colors': ['أسود', 'أبيض', 'وردي'],
          'inStock': true,
          'stock': 67,
        },
        {
          'id': '8',
          'name': 'دمبل قابل للتعديل',
          'description': 'دمبل 5-25 كجم قابل للتعديل',
          'price': 599.00,
          'category': 'معدات',
          'images': ['https://images.unsplash.com/photo-1638536532686-d610adfc8e5c?w=400'],
          'rating': 4.9,
          'reviews': 89,
          'sizes': ['5-25kg'],
          'colors': ['أسود'],
          'inStock': true,
          'stock': 23,
        },
      ];

      // Save to SQLite database
      await DatabaseService.saveProducts(products);

      if (category != null && category.isNotEmpty && category != 'الكل') {
        return products.where((p) => p['category'] == category).toList();
      }
      return products;
    }

    try {
      String url = '$baseUrl/products';
      if (category != null && category.isNotEmpty) {
        url += '?category=$category';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      final products = data['success'] == true ? (data['data'] ?? []) : [];

      // Save to SQLite database
      if (products.isNotEmpty) {
        await DatabaseService.saveProducts(products);
      }

      return products;
    } catch (e) {
      // On error, try to return data from database
      try {
        final dbProducts = await DatabaseService.getProducts(category: category);
        if (dbProducts.isNotEmpty) {
          return dbProducts;
        }
      } catch (_) {}
      return [];
    }
  }

  // ========== Orders ==========

  // Create order
  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
    required String shippingCity,
    required String phone,
    required String paymentMethod,
    String? notes,
    String? couponCode,
  }) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'message': 'تم إنشاء الطلب بنجاح',
        'data': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'order_number': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
          'status': 'pending',
        }
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
        body: json.encode({
          'items': items,
          'shipping_address': shippingAddress,
          'shipping_city': shippingCity,
          'phone': phone,
          'payment_method': paymentMethod,
          'notes': notes,
          'coupon_code': couponCode,
        }),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get user orders
  static Future<List<dynamic>> getMyOrders({bool forceRefresh = false}) async {
    // Try to get from SQLite database first
    if (!forceRefresh) {
      try {
        final dbOrders = await DatabaseService.getOrders();
        if (dbOrders.isNotEmpty) {
          return dbOrders;
        }
      } catch (e) {
        debugPrint('Database error: $e');
      }
    }

    if (ApiConfig.isDemoMode) {
      final orders = [
        {
          'id': '1',
          'order_number': 'ORD-2024-001',
          'total': 350.0,
          'status': 'delivered',
          'created_at': '2024-12-20',
          'items_count': 2,
        },
        {
          'id': '2',
          'order_number': 'ORD-2024-002',
          'total': 150.0,
          'status': 'pending',
          'created_at': '2024-12-25',
          'items_count': 1,
        },
      ];
      await DatabaseService.saveOrders(orders);
      return orders;
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/orders/my-orders'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      final orders = data['success'] == true ? (data['data'] ?? []) : [];

      // Save to SQLite database
      if (orders.isNotEmpty) {
        await DatabaseService.saveOrders(orders);
      }

      return orders;
    } catch (e) {
      // On error, return data from database
      try {
        return await DatabaseService.getOrders();
      } catch (_) {
        return [];
      }
    }
  }

  // ========== Online Sessions ==========

  // Get user's sessions
  static Future<List<dynamic>> getMySessions() async {
    if (ApiConfig.isDemoMode) {
      return await DemoService.getOnlineSessions();
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/sessions/my-sessions'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      return data['success'] == true ? (data['data'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  // ========== Trainer Sessions Management ==========

  // Get trainer's sessions organized by day
  static Future<List<dynamic>> getTrainerSessions({bool forceRefresh = false}) async {
    // Try to get from SQLite database first
    if (!forceRefresh) {
      try {
        final dbSessions = await DatabaseService.getSessions();
        if (dbSessions.isNotEmpty) {
          return dbSessions;
        }
      } catch (e) {
        debugPrint('Database error: $e');
      }
    }

    if (ApiConfig.isDemoMode) {
      final now = DateTime.now();
      final demoSessions = [
        {
          'id': '1',
          'title': 'جلسة تمارين القوة',
          'day': 'السبت',
          'time': '09:00 ص',
          'duration': 45,
          'type': 'group',
          'max_participants': 10,
          'participants_count': 6,
          'is_online': true,
          'meeting_url': 'https://zoom.us/j/1234567890',
          'meeting_id': '123 456 7890',
          'meeting_password': 'vitafit123',
          'notes': 'احضري أوزان خفيفة وسجادة يوغا',
          'status': 'scheduled',
          'scheduled_at': now.add(const Duration(days: 2, hours: 9)).toIso8601String(),
        },
        {
          'id': '2',
          'title': 'جلسة كارديو حارقة',
          'day': 'الأحد',
          'time': '06:00 م',
          'duration': 30,
          'type': 'group',
          'max_participants': 15,
          'participants_count': 12,
          'is_online': true,
          'meeting_url': 'https://zoom.us/j/9876543210',
          'meeting_id': '987 654 3210',
          'meeting_password': 'cardio2024',
          'notes': 'تمارين عالية الكثافة - للياقة المتوسطة فما فوق',
          'status': 'scheduled',
          'scheduled_at': now.add(const Duration(days: 3, hours: 18)).toIso8601String(),
        },
        {
          'id': '3',
          'title': 'يوغا للاسترخاء',
          'day': 'الثلاثاء',
          'time': '08:00 م',
          'duration': 60,
          'type': 'group',
          'max_participants': 20,
          'participants_count': 8,
          'is_online': true,
          'meeting_url': 'https://zoom.us/j/5555555555',
          'meeting_id': '555 555 5555',
          'meeting_password': 'yoga2024',
          'notes': 'جلسة يوغا هادئة للاسترخاء وتخفيف التوتر',
          'status': 'scheduled',
          'scheduled_at': now.add(const Duration(days: 5, hours: 20)).toIso8601String(),
        },
        {
          'id': '4',
          'title': 'جلسة خاصة - نورة',
          'day': 'الخميس',
          'time': '10:00 ص',
          'duration': 45,
          'type': 'individual',
          'max_participants': 1,
          'participants_count': 1,
          'is_online': false,
          'notes': 'جلسة تدريب شخصي - تركيز على تقوية الظهر',
          'status': 'scheduled',
          'scheduled_at': now.add(const Duration(days: 7, hours: 10)).toIso8601String(),
        },
      ];
      // Save demo sessions to database
      await DatabaseService.saveSessions(demoSessions);
      return demoSessions;
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/sessions'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      final sessions = data['success'] == true ? (data['data'] ?? []) : [];

      // Save to SQLite database
      if (sessions.isNotEmpty) {
        await DatabaseService.saveSessions(sessions);
      }

      return sessions;
    } catch (e) {
      // On error, return data from database
      try {
        return await DatabaseService.getSessions();
      } catch (_) {
        return [];
      }
    }
  }

  // Create a new trainer session
  static Future<Map<String, dynamic>> createTrainerSession(Map<String, dynamic> session) async {
    if (ApiConfig.isDemoMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'success': true,
        'message': 'تم إنشاء الجلسة بنجاح',
        'data': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          ...session,
          'status': 'scheduled',
          'participants_count': 0,
        }
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/trainer/sessions'),
        headers: headers,
        body: json.encode(session),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Update trainer session
  static Future<Map<String, dynamic>> updateTrainerSession(String id, Map<String, dynamic> session) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'message': 'تم تحديث الجلسة بنجاح',
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/trainer/sessions/$id'),
        headers: headers,
        body: json.encode(session),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Delete trainer session
  static Future<Map<String, dynamic>> deleteTrainerSession(String id) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'message': 'تم حذف الجلسة بنجاح',
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/trainer/sessions/$id'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get trainer reports and statistics
  static Future<Map<String, dynamic>> getTrainerReports() async {
    if (ApiConfig.isDemoMode) {
      // Get clients and sessions to calculate stats
      final clients = await getTrainerClients();
      final sessions = await getTrainerSessions();

      final totalClients = clients.length;
      final activeClients = clients.where((c) {
        final lastSession = c['last_session'];
        if (lastSession == null) return false;
        final lastDate = DateTime.tryParse(lastSession);
        if (lastDate == null) return false;
        return DateTime.now().difference(lastDate).inDays <= 30;
      }).length;

      final totalSessions = sessions.length;
      final completedSessions = (totalSessions * 0.85).round();

      // Calculate total participants
      int totalParticipants = 0;
      for (var session in sessions) {
        totalParticipants += (session['participants_count'] as int?) ?? 0;
      }

      return {
        'stats': {
          'totalClients': totalClients,
          'activeClients': activeClients > 0 ? activeClients : totalClients,
          'completedSessions': completedSessions,
          'totalSessions': totalSessions + completedSessions,
          'averageRating': 4.8,
          'totalReviews': totalClients * 2,
          'monthlyEarnings': (totalClients * 650) + (totalSessions * 150),
          'thisWeekSessions': (totalSessions * 0.3).round(),
          'cancelledSessions': (totalSessions * 0.05).round(),
          'postponedSessions': (totalSessions * 0.03).round(),
          'clientSatisfaction': 92,
        },
        'monthlyData': [
          {'month': 'سبتمبر', 'sessions': 28 + totalSessions, 'earnings': 12000},
          {'month': 'أكتوبر', 'sessions': 35 + totalSessions, 'earnings': 15000},
          {'month': 'نوفمبر', 'sessions': 40 + totalSessions, 'earnings': 17500},
          {'month': 'ديسمبر', 'sessions': 38 + totalSessions, 'earnings': 16500},
        ],
        'topClients': clients.take(3).toList().asMap().entries.map((entry) {
          final idx = entry.key;
          final client = entry.value;
          final sessions = (client['total_sessions'] as int?) ?? 0;
          return {
            'name': client['name'] ?? 'متدربة',
            'sessions': sessions,
            'progress': (60 + sessions).clamp(0, 100),
            'rating': (5.0 - (idx * 0.1)),
          };
        }).toList(),
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/reports'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      return data['success'] == true ? (data['data'] ?? {}) : {};
    } catch (e) {
      return {};
    }
  }

  // Get trainer stats for more screen
  static Future<Map<String, dynamic>> getTrainerStats({bool forceRefresh = false}) async {
    // Try to get from SQLite database cache first
    if (!forceRefresh) {
      try {
        final cached = await DatabaseService.getFromCache('trainer_stats');
        if (cached != null) {
          return Map<String, dynamic>.from(cached);
        }
      } catch (e) {
        debugPrint('Database error: $e');
      }
    }

    if (ApiConfig.isDemoMode) {
      final clients = await getTrainerClients();
      final sessions = await getTrainerSessions();

      final totalClients = clients.length;
      final activeClients = clients.where((c) {
        final lastSession = c['last_session'];
        if (lastSession == null) return false;
        final lastDate = DateTime.tryParse(lastSession);
        if (lastDate == null) return false;
        return DateTime.now().difference(lastDate).inDays <= 30;
      }).length;

      final completedSessions = sessions.where((s) => s['status'] == 'completed').length;

      final stats = {
        'success': true,
        'total_clients': totalClients,
        'active_clients': activeClients > 0 ? activeClients : totalClients,
        'sessions_given': completedSessions > 0 ? completedSessions : sessions.length,
      };
      await DatabaseService.saveToCache('trainer_stats', stats, expiresInMinutes: 15);
      return stats;
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/stats'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      final stats = json.decode(response.body);

      // Save to database cache
      if (stats['success'] == true) {
        await DatabaseService.saveToCache('trainer_stats', stats, expiresInMinutes: 15);
      }

      return stats;
    } catch (e) {
      // On error, return data from database cache
      try {
        final cached = await DatabaseService.getFromCache('trainer_stats');
        if (cached != null) {
          return Map<String, dynamic>.from(cached);
        }
      } catch (_) {}
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get trainer's trainees (clients)
  static Future<List<dynamic>> getTrainerClients({bool forceRefresh = false}) async {
    // Try to get from SQLite database first
    if (!forceRefresh) {
      try {
        final dbClients = await DatabaseService.getClients();
        if (dbClients.isNotEmpty) {
          return dbClients;
        }
      } catch (e) {
        debugPrint('Database error: $e');
      }
    }

    if (ApiConfig.isDemoMode) {
      final clients = [
        {
          'id': '1',
          'name': 'نورة أحمد',
          'email': 'noura@example.com',
          'phone': '0501234567',
          'subscription': 'Gold',
          'joined_at': '2024-10-15',
          'last_session': '2024-12-25',
          'total_sessions': 24,
        },
        {
          'id': '2',
          'name': 'سارة محمد',
          'email': 'sara@example.com',
          'phone': '0507654321',
          'subscription': 'Diamond',
          'joined_at': '2024-09-01',
          'last_session': '2024-12-28',
          'total_sessions': 36,
        },
        {
          'id': '3',
          'name': 'فاطمة علي',
          'email': 'fatima@example.com',
          'phone': '0509876543',
          'subscription': 'Silver',
          'joined_at': '2024-11-20',
          'last_session': '2024-12-20',
          'total_sessions': 12,
        },
      ];
      await DatabaseService.saveClients(clients);
      return clients;
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/clients'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      final clients = data['success'] == true ? (data['data'] ?? []) : [];

      // Save to SQLite database
      if (clients.isNotEmpty) {
        await DatabaseService.saveClients(clients);
      }

      return clients;
    } catch (e) {
      // On error, return data from database
      try {
        return await DatabaseService.getClients();
      } catch (_) {
        return [];
      }
    }
  }

  // Create exercise for trainee (trainer only)
  static Future<Map<String, dynamic>> createExerciseForTrainee({
    required String traineeId,
    required String name,
    String? description,
    String category = 'strength',
    String difficulty = 'medium',
    int sets = 3,
    int reps = 12,
    int? duration,
    int restSeconds = 60,
    String? notes,
  }) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'message': 'تم إضافة التمرين بنجاح',
        'data': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': name,
          'trainee_id': traineeId,
        }
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/trainer/exercises'),
        headers: headers,
        body: json.encode({
          'trainee_id': traineeId,
          'name': name,
          'description': description,
          'category': category,
          'difficulty': difficulty,
          'sets': sets,
          'reps': reps,
          'duration': duration,
          'rest_seconds': restSeconds,
          'notes': notes,
        }),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Create meal for trainee (trainer only)
  static Future<Map<String, dynamic>> createMealForTrainee({
    required String traineeId,
    required String name,
    String? description,
    String mealType = 'lunch',
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? ingredients,
    String? instructions,
    String? notes,
  }) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'message': 'تم إضافة الوجبة بنجاح',
        'data': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': name,
          'trainee_id': traineeId,
        }
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/trainer/meals'),
        headers: headers,
        body: json.encode({
          'trainee_id': traineeId,
          'name': name,
          'description': description,
          'meal_type': mealType,
          'calories': calories,
          'protein': protein,
          'carbs': carbs,
          'fat': fat,
          'ingredients': ingredients,
          'instructions': instructions,
          'notes': notes,
        }),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Book a session with trainer
  static Future<Map<String, dynamic>> bookSession({
    required String trainerId,
    required DateTime scheduledAt,
    required int durationMinutes,
    String? notes,
  }) async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'message': 'تم حجز الجلسة بنجاح',
        'data': {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'status': 'pending',
        }
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/sessions/book'),
        headers: headers,
        body: json.encode({
          'trainer_id': trainerId,
          'scheduled_at': scheduledAt.toIso8601String(),
          'duration_minutes': durationMinutes,
          'notes': notes,
        }),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== FCM Token ==========

  // Update FCM token for push notifications
  static Future<Map<String, dynamic>> updateFcmToken(String token) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم تحديث التوكن بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/fcm-token'),
        headers: headers,
        body: json.encode({'fcmToken': token}),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Ratings & Feedback ==========

  // Submit app rating
  static Future<Map<String, dynamic>> submitRating({
    required int rating,
    String? review,
  }) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'شكراً لتقييمك!'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/ratings'),
        headers: headers,
        body: json.encode({
          'rating': rating,
          'review': review,
          'type': 'app',
        }),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Submit feedback/suggestion
  static Future<Map<String, dynamic>> submitFeedback({
    required String type,
    required String subject,
    required String message,
    String? email,
  }) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم إرسال ملاحظاتك بنجاح!'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: headers,
        body: json.encode({
          'type': type,
          'subject': subject,
          'message': message,
          'email': email,
        }),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get FAQ
  static Future<List<dynamic>> getFAQ() async {
    if (ApiConfig.isDemoMode) {
      return [
        {
          'id': 1,
          'question': 'كيف أبدأ التمارين؟',
          'answer': 'بعد تسجيل الدخول، اذهبي إلى قسم التمارين واختاري البرنامج المناسب لك. يمكنك البدء بالتمارين الأساسية ثم التدرج.',
        },
        {
          'id': 2,
          'question': 'كيف أتواصل مع المدربة؟',
          'answer': 'يمكنك التواصل مع المدربة من خلال الجلسات الأونلاين أو عبر الرسائل داخل التطبيق.',
        },
        {
          'id': 3,
          'question': 'كيف أغير اشتراكي؟',
          'answer': 'اذهبي إلى المزيد > الاشتراكات لعرض وتغيير خطة اشتراكك الحالية.',
        },
        {
          'id': 4,
          'question': 'هل يمكنني إلغاء طلبي؟',
          'answer': 'يمكنك إلغاء الطلب خلال ساعة من تقديمه. بعد ذلك، تواصلي مع خدمة العملاء.',
        },
        {
          'id': 5,
          'question': 'كيف أتتبع تقدمي؟',
          'answer': 'اذهبي إلى المزيد > تتبع التقدم لعرض إحصائياتك وقياساتك.',
        },
      ];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/faq'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      return data['success'] == true ? (data['data'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  // ========== FCM Token Management ==========

  // Update FCM token
  static Future<Map<String, dynamic>> updateFCMToken(String token) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true, 'message': 'تم تحديث رمز الإشعارات'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/user/fcm-token'),
        headers: headers,
        body: json.encode({'fcm_token': token}),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get notifications
  static Future<List<dynamic>> getNotifications() async {
    if (ApiConfig.isDemoMode) {
      final now = DateTime.now();
      return [
        {
          'id': '1',
          'title': 'تذكير بجلستك',
          'body': 'جلستك مع كابتن سارة بعد ساعتين. لا تنسي الاستعداد!',
          'type': 'session',
          'read': false,
          'created_at': now.subtract(const Duration(minutes: 30)).toIso8601String(),
        },
        {
          'id': '2',
          'title': 'تذكير بالتمرين',
          'body': 'حان وقت تمرينك اليومي! تمارين الجزء العلوي في انتظارك.',
          'type': 'workout_reminder',
          'read': false,
          'created_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          'id': '3',
          'title': 'تحديث خطة التغذية',
          'body': 'تم تحديث خطة وجباتك لهذا الأسبوع. اطلعي على التفاصيل.',
          'type': 'nutrition',
          'read': false,
          'created_at': now.subtract(const Duration(hours: 5)).toIso8601String(),
        },
        {
          'id': '4',
          'title': 'خصم خاص لك!',
          'body': 'احصلي على خصم 25% على جميع منتجات البروتين. العرض ساري لمدة 48 ساعة!',
          'type': 'promotion',
          'read': true,
          'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'id': '5',
          'title': 'تم شحن طلبك',
          'body': 'طلبك #ORD-2024-002 في الطريق إليك. متوقع الوصول خلال 2-3 أيام.',
          'type': 'order',
          'read': true,
          'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        },
        {
          'id': '6',
          'title': 'مبروك! إنجاز جديد',
          'body': 'أكملتِ 24 تمرين هذا الشهر! استمري بهذا الأداء الرائع.',
          'type': 'achievement',
          'read': true,
          'created_at': now.subtract(const Duration(days: 3)).toIso8601String(),
        },
        {
          'id': '7',
          'title': 'تجديد الاشتراك',
          'body': 'اشتراكك سينتهي بعد 30 يوم. جددي الآن واحصلي على شهر إضافي مجاناً!',
          'type': 'subscription',
          'read': true,
          'created_at': now.subtract(const Duration(days: 5)).toIso8601String(),
        },
      ];
    }

    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      final data = json.decode(response.body);
      return data['success'] == true ? (data['data'] ?? []) : [];
    } catch (e) {
      return [];
    }
  }

  // Mark notification as read
  static Future<Map<String, dynamic>> markNotificationRead(String id) async {
    if (ApiConfig.isDemoMode) {
      return {'success': true};
    }

    try {
      final headers = await getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$id/read'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Mark all notifications as read
  static Future<Map<String, dynamic>> markAllNotificationsRead() async {
    if (ApiConfig.isDemoMode) {
      return {'success': true};
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Account Deletion ==========

  // Delete user account
  static Future<Map<String, dynamic>> deleteAccount({
    required String password,
    String? reason,
    String? feedback,
  }) async {
    if (ApiConfig.isDemoMode) {
      // Simulate password check
      if (password != 'demo123') {
        return {'success': false, 'message': 'كلمة المرور غير صحيحة'};
      }
      return {'success': true, 'message': 'تم حذف الحساب بنجاح'};
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/user/delete-account'),
        headers: headers,
        body: json.encode({
          'password': password,
          'reason': reason,
          'feedback': feedback,
        }),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Request account data export
  static Future<Map<String, dynamic>> requestDataExport() async {
    if (ApiConfig.isDemoMode) {
      return {
        'success': true,
        'message': 'سيتم إرسال بياناتك إلى بريدك الإلكتروني خلال 24 ساعة'
      };
    }

    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/user/export-data'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Smart Plan ==========

  // Save smart plan data
  static Future<Map<String, dynamic>> saveSmartPlan({
    String? name,
    int? age,
    double? height,
    double? currentWeight,
    double? targetWeight,
    String? healthCondition,
    String? previousInjuries,
    String? surgeries,
    String? medications,
    String? allergies,
    String? activityLevel,
    double? bmr,
    double? tdee,
    double? waist,
    double? hips,
    double? chest,
    double? arm,
    double? thigh,
    String? trainingType,
    String? subscriptionType,
    int? trainerId,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/smartplan/save'),
        headers: headers,
        body: json.encode({
          'name': name,
          'age': age,
          'height': height,
          'current_weight': currentWeight,
          'target_weight': targetWeight,
          'health_condition': healthCondition,
          'previous_injuries': previousInjuries,
          'surgeries': surgeries,
          'medications': medications,
          'allergies': allergies,
          'activity_level': activityLevel,
          'bmr': bmr,
          'tdee': tdee,
          'waist': waist,
          'hips': hips,
          'chest': chest,
          'arm': arm,
          'thigh': thigh,
          'training_type': trainingType,
          'subscription_type': subscriptionType,
          'trainer_id': trainerId,
        }),
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get smart plan data
  static Future<Map<String, dynamic>> getSmartPlanData() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/smartplan/my-data'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get trainee stats (consecutive days, completed sessions, weight loss)
  static Future<Map<String, dynamic>> getTraineeStats() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trainee/stats'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Send trainer request (trainee requests to be trained by a specific trainer)
  static Future<Map<String, dynamic>> sendTrainerRequest(String trainerId) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/trainer-requests'),
        headers: headers,
        body: json.encode({'trainer_id': trainerId}),
      ).timeout(ApiConfig.timeout);

      debugPrint('📤 Sending trainer request for trainer: $trainerId');
      debugPrint('📥 Response: ${response.body}');

      return json.decode(response.body);
    } catch (e) {
      debugPrint('❌ Error sending trainer request: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get pending trainer requests (for trainer dashboard)
  static Future<Map<String, dynamic>> getTrainerRequests() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trainer/requests'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Accept/Reject trainer request
  static Future<Map<String, dynamic>> respondToTrainerRequest(int requestId, String action) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/trainer/requests/$requestId/$action'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // ========== Trainee Plans (Trainer-Assigned) ==========

  // Get my workouts (assigned by trainer)
  static Future<Map<String, dynamic>> getMyTrainerWorkouts() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trainee-plans/my-workouts'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get my meals (assigned by trainer)
  static Future<Map<String, dynamic>> getMyTrainerMeals() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trainee-plans/my-meals'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }

  // Get trainee nutrition goals from trainer plans
  static Future<Map<String, dynamic>> getTraineeNutritionGoals() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/trainee-plans/nutrition-goals'),
        headers: headers,
      ).timeout(ApiConfig.timeout);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم: $e'};
    }
  }
}
