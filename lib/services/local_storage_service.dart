import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'hive_storage_service.dart';

/// خدمة التخزين المحلي - تحفظ جميع البيانات على الهاتف
/// تستخدم Hive بدلاً من SharedPreferences لتوافق أفضل مع iPad
class LocalStorageService {
  // Cache keys
  static const String _keyProducts = 'cache_products';
  static const String _keyCategories = 'cache_categories';
  static const String _keyWorkouts = 'cache_workouts';
  static const String _keyExercises = 'cache_exercises';
  static const String _keyMeals = 'cache_meals';
  static const String _keyNutritionPlans = 'cache_nutrition_plans';
  static const String _keySessions = 'cache_sessions';
  static const String _keySubscriptions = 'cache_subscriptions';
  static const String _keyOrders = 'cache_orders';
  static const String _keyNotifications = 'cache_notifications';
  static const String _keyTrainers = 'cache_trainers';
  static const String _keyUserProfile = 'cache_user_profile';
  static const String _keyUserStats = 'cache_user_stats';
  static const String _keyTrainerClients = 'cache_trainer_clients';
  static const String _keyTrainerSessions = 'cache_trainer_sessions';
  static const String _keyTrainerStats = 'cache_trainer_stats';
  static const String _keyProgressData = 'cache_progress_data';
  static const String _keyCartItems = 'cache_cart_items';
  static const String _keyFavorites = 'cache_favorites';
  static const String _keyCacheTimestamps = 'cache_timestamps';

  // Cache duration in minutes
  static const int _defaultCacheDuration = 60; // 1 hour
  static const int _longCacheDuration = 1440; // 24 hours
  static const int _shortCacheDuration = 15; // 15 minutes

  /// Initialize the service (uses HiveStorageService)
  static Future<void> init() async {
    await HiveStorageService.init();
  }

  // ==================== Generic Cache Methods ====================

  /// Save data to cache with timestamp
  static Future<void> _saveToCache(String key, dynamic data, {int? durationMinutes}) async {
    try {
      final jsonData = json.encode(data);
      await HiveStorageService.setString(key, jsonData);

      // Save timestamp
      final timestamps = _getTimestamps();
      timestamps[key] = DateTime.now().millisecondsSinceEpoch;
      if (durationMinutes != null) {
        timestamps['${key}_duration'] = durationMinutes;
      }
      await HiveStorageService.setString(_keyCacheTimestamps, json.encode(timestamps));
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }

  /// Get data from cache if not expired
  static dynamic _getFromCache(String key, {int defaultDuration = _defaultCacheDuration}) {
    try {
      final jsonData = HiveStorageService.getString(key);
      if (jsonData == null) return null;

      // Check if cache is expired
      final timestamps = _getTimestamps();
      final timestamp = timestamps[key] as int?;
      if (timestamp == null) return json.decode(jsonData);

      final duration = timestamps['${key}_duration'] as int? ?? defaultDuration;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final isExpired = DateTime.now().difference(cacheTime).inMinutes > duration;

      if (isExpired) {
        // Return cached data but mark as stale (can be refreshed in background)
        return json.decode(jsonData);
      }

      return json.decode(jsonData);
    } catch (e) {
      debugPrint('Error getting from cache: $e');
      return null;
    }
  }

  /// Check if cache is expired
  static bool isCacheExpired(String key, {int defaultDuration = _defaultCacheDuration}) {
    try {
      final timestamps = _getTimestamps();
      final timestamp = timestamps[key] as int?;
      if (timestamp == null) return true;

      final duration = timestamps['${key}_duration'] as int? ?? defaultDuration;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(cacheTime).inMinutes > duration;
    } catch (e) {
      return true;
    }
  }

  /// Get cache timestamps
  static Map<String, dynamic> _getTimestamps() {
    try {
      final data = HiveStorageService.getString(_keyCacheTimestamps);
      if (data == null) return {};
      return json.decode(data) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Clear specific cache
  static Future<void> clearCache(String key) async {
    try {
      await HiveStorageService.remove(key);

      // Remove timestamp
      final timestamps = _getTimestamps();
      timestamps.remove(key);
      timestamps.remove('${key}_duration');
      await HiveStorageService.setString(_keyCacheTimestamps, json.encode(timestamps));
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Clear all cache
  static Future<void> clearAllCache() async {
    try {
      final keys = [
        _keyProducts, _keyCategories, _keyWorkouts, _keyExercises,
        _keyMeals, _keyNutritionPlans, _keySessions, _keySubscriptions,
        _keyOrders, _keyNotifications, _keyTrainers, _keyUserProfile,
        _keyUserStats, _keyTrainerClients, _keyTrainerSessions,
        _keyTrainerStats, _keyProgressData, _keyCartItems, _keyFavorites,
      ];

      for (final key in keys) {
        await HiveStorageService.remove(key);
      }
      await HiveStorageService.remove(_keyCacheTimestamps);
    } catch (e) {
      debugPrint('Error clearing all cache: $e');
    }
  }

  // ==================== Products & Shop ====================

  /// Save products to cache
  static Future<void> saveProducts(List<dynamic> products) async {
    await _saveToCache(_keyProducts, products, durationMinutes: _defaultCacheDuration);
  }

  /// Get cached products
  static List<dynamic>? getProducts() {
    final data = _getFromCache(_keyProducts);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  /// Save categories to cache
  static Future<void> saveCategories(List<dynamic> categories) async {
    await _saveToCache(_keyCategories, categories, durationMinutes: _longCacheDuration);
  }

  /// Get cached categories
  static List<dynamic>? getCategories() {
    final data = _getFromCache(_keyCategories, defaultDuration: _longCacheDuration);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  /// Save cart items
  static Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    await _saveToCache(_keyCartItems, items);
  }

  /// Get cart items
  static List<Map<String, dynamic>>? getCartItems() {
    final data = _getFromCache(_keyCartItems);
    if (data == null) return null;
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e))
    );
  }

  /// Save favorites
  static Future<void> saveFavorites(List<String> productIds) async {
    await _saveToCache(_keyFavorites, productIds);
  }

  /// Get favorites
  static List<String>? getFavorites() {
    final data = _getFromCache(_keyFavorites);
    if (data == null) return null;
    return List<String>.from(data);
  }

  /// Save orders
  static Future<void> saveOrders(List<dynamic> orders) async {
    await _saveToCache(_keyOrders, orders, durationMinutes: _shortCacheDuration);
  }

  /// Get cached orders
  static List<dynamic>? getOrders() {
    final data = _getFromCache(_keyOrders, defaultDuration: _shortCacheDuration);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  // ==================== Workouts & Exercises ====================

  /// Save workouts to cache
  static Future<void> saveWorkouts(List<dynamic> workouts) async {
    await _saveToCache(_keyWorkouts, workouts, durationMinutes: _defaultCacheDuration);
  }

  /// Get cached workouts
  static List<dynamic>? getWorkouts() {
    final data = _getFromCache(_keyWorkouts);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  /// Save exercises to cache
  static Future<void> saveExercises(List<dynamic> exercises) async {
    await _saveToCache(_keyExercises, exercises, durationMinutes: _longCacheDuration);
  }

  /// Get cached exercises
  static List<dynamic>? getExercises() {
    final data = _getFromCache(_keyExercises, defaultDuration: _longCacheDuration);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  // ==================== Nutrition & Meals ====================

  /// Save meals to cache
  static Future<void> saveMeals(List<dynamic> meals) async {
    await _saveToCache(_keyMeals, meals, durationMinutes: _defaultCacheDuration);
  }

  /// Get cached meals
  static List<dynamic>? getMeals() {
    final data = _getFromCache(_keyMeals);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  /// Save nutrition plans to cache
  static Future<void> saveNutritionPlans(List<dynamic> plans) async {
    await _saveToCache(_keyNutritionPlans, plans, durationMinutes: _defaultCacheDuration);
  }

  /// Get cached nutrition plans
  static List<dynamic>? getNutritionPlans() {
    final data = _getFromCache(_keyNutritionPlans);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  // ==================== Sessions ====================

  /// Save sessions to cache
  static Future<void> saveSessions(List<dynamic> sessions) async {
    await _saveToCache(_keySessions, sessions, durationMinutes: _shortCacheDuration);
  }

  /// Get cached sessions
  static List<dynamic>? getSessions() {
    final data = _getFromCache(_keySessions, defaultDuration: _shortCacheDuration);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  // ==================== Subscriptions ====================

  /// Save subscriptions to cache
  static Future<void> saveSubscriptions(List<dynamic> subscriptions) async {
    await _saveToCache(_keySubscriptions, subscriptions, durationMinutes: _shortCacheDuration);
  }

  /// Get cached subscriptions
  static List<dynamic>? getSubscriptions() {
    final data = _getFromCache(_keySubscriptions, defaultDuration: _shortCacheDuration);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  // ==================== Notifications ====================

  /// Save notifications to cache
  static Future<void> saveNotifications(List<dynamic> notifications) async {
    await _saveToCache(_keyNotifications, notifications, durationMinutes: _shortCacheDuration);
  }

  /// Get cached notifications
  static List<dynamic>? getNotifications() {
    final data = _getFromCache(_keyNotifications, defaultDuration: _shortCacheDuration);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  // ==================== Trainers ====================

  /// Save trainers to cache
  static Future<void> saveTrainers(List<dynamic> trainers) async {
    await _saveToCache(_keyTrainers, trainers, durationMinutes: _defaultCacheDuration);
  }

  /// Get cached trainers
  static List<dynamic>? getTrainers() {
    final data = _getFromCache(_keyTrainers);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  // ==================== User Data ====================

  /// Save user profile to cache
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _saveToCache(_keyUserProfile, profile, durationMinutes: _longCacheDuration);
  }

  /// Get cached user profile
  static Map<String, dynamic>? getUserProfile() {
    final data = _getFromCache(_keyUserProfile, defaultDuration: _longCacheDuration);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Save user stats to cache
  static Future<void> saveUserStats(Map<String, dynamic> stats) async {
    await _saveToCache(_keyUserStats, stats, durationMinutes: _shortCacheDuration);
  }

  /// Get cached user stats
  static Map<String, dynamic>? getUserStats() {
    final data = _getFromCache(_keyUserStats, defaultDuration: _shortCacheDuration);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Save progress data to cache
  static Future<void> saveProgressData(Map<String, dynamic> progress) async {
    await _saveToCache(_keyProgressData, progress, durationMinutes: _shortCacheDuration);
  }

  /// Get cached progress data
  static Map<String, dynamic>? getProgressData() {
    final data = _getFromCache(_keyProgressData, defaultDuration: _shortCacheDuration);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  // ==================== Trainer Data ====================

  /// Save trainer clients to cache
  static Future<void> saveTrainerClients(List<dynamic> clients) async {
    await _saveToCache(_keyTrainerClients, clients, durationMinutes: _shortCacheDuration);
  }

  /// Get cached trainer clients
  static List<dynamic>? getTrainerClients() {
    final data = _getFromCache(_keyTrainerClients, defaultDuration: _shortCacheDuration);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  /// Save trainer sessions to cache
  static Future<void> saveTrainerSessions(List<dynamic> sessions) async {
    await _saveToCache(_keyTrainerSessions, sessions, durationMinutes: _shortCacheDuration);
  }

  /// Get cached trainer sessions
  static List<dynamic>? getTrainerSessions() {
    final data = _getFromCache(_keyTrainerSessions, defaultDuration: _shortCacheDuration);
    if (data == null) return null;
    return List<dynamic>.from(data);
  }

  /// Save trainer stats to cache
  static Future<void> saveTrainerStats(Map<String, dynamic> stats) async {
    await _saveToCache(_keyTrainerStats, stats, durationMinutes: _shortCacheDuration);
  }

  /// Get cached trainer stats
  static Map<String, dynamic>? getTrainerStats() {
    final data = _getFromCache(_keyTrainerStats, defaultDuration: _shortCacheDuration);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  // ==================== Offline Support ====================

  /// Check if there's cached data available
  static bool hasCachedData() {
    return HiveStorageService.containsKey(_keyProducts) ||
           HiveStorageService.containsKey(_keyWorkouts) ||
           HiveStorageService.containsKey(_keyMeals);
  }

  /// Get cache size in bytes (approximate)
  static int getCacheSize() {
    try {
      int totalSize = 0;
      final keys = [
        _keyProducts, _keyCategories, _keyWorkouts, _keyExercises,
        _keyMeals, _keyNutritionPlans, _keySessions, _keySubscriptions,
        _keyOrders, _keyNotifications, _keyTrainers, _keyUserProfile,
        _keyUserStats, _keyTrainerClients, _keyTrainerSessions,
        _keyTrainerStats, _keyProgressData, _keyCartItems, _keyFavorites,
        _keyCacheTimestamps,
      ];
      for (final key in keys) {
        final value = HiveStorageService.getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Format cache size for display
  static String formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ==================== Simple Key-Value Storage ====================

  /// Save string value
  static Future<void> setString(String key, String value) async {
    await HiveStorageService.setString(key, value);
  }

  /// Get string value
  static String? getString(String key) {
    return HiveStorageService.getString(key);
  }

  /// Save int value
  static Future<void> setInt(String key, int value) async {
    await HiveStorageService.setInt(key, value);
  }

  /// Get int value
  static int? getInt(String key) {
    return HiveStorageService.getInt(key);
  }

  /// Save bool value
  static Future<void> setBool(String key, bool value) async {
    await HiveStorageService.setBool(key, value);
  }

  /// Get bool value
  static bool? getBool(String key) {
    return HiveStorageService.getBool(key);
  }

  /// Save double value
  static Future<void> setDouble(String key, double value) async {
    await HiveStorageService.setDouble(key, value);
  }

  /// Get double value
  static double? getDouble(String key) {
    return HiveStorageService.getDouble(key);
  }

  /// Remove a key
  static Future<void> remove(String key) async {
    await HiveStorageService.remove(key);
  }

  /// Check if key exists
  static bool containsKey(String key) {
    return HiveStorageService.containsKey(key);
  }
}
