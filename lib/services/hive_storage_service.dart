import 'package:hive_flutter/hive_flutter.dart';

/// Hive Storage Service - Replacement for SharedPreferences
/// This is compatible with iPad and doesn't cause crashes
class HiveStorageService {
  static const String _boxName = 'vitafit_storage';
  static Box? _box;
  static bool _initialized = false;

  /// Initialize Hive storage
  static Future<void> init() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();
      _box = await Hive.openBox(_boxName);
      _initialized = true;
    } catch (e) {
      print('Hive initialization error: $e');
    }
  }

  /// Get the storage box
  static Box get box {
    if (_box == null) {
      throw Exception('HiveStorageService not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Check if initialized
  static bool get isInitialized => _initialized;

  // ============ String Operations ============

  static Future<void> setString(String key, String value) async {
    await box.put(key, value);
  }

  static String? getString(String key) {
    return box.get(key) as String?;
  }

  // ============ Int Operations ============

  static Future<void> setInt(String key, int value) async {
    await box.put(key, value);
  }

  static int? getInt(String key) {
    return box.get(key) as int?;
  }

  // ============ Double Operations ============

  static Future<void> setDouble(String key, double value) async {
    await box.put(key, value);
  }

  static double? getDouble(String key) {
    return box.get(key) as double?;
  }

  // ============ Bool Operations ============

  static Future<void> setBool(String key, bool value) async {
    await box.put(key, value);
  }

  static bool? getBool(String key) {
    return box.get(key) as bool?;
  }

  // ============ List Operations ============

  static Future<void> setStringList(String key, List<String> value) async {
    await box.put(key, value);
  }

  static List<String>? getStringList(String key) {
    final value = box.get(key);
    if (value == null) return null;
    return (value as List).cast<String>();
  }

  // ============ Generic Operations ============

  static Future<void> setValue(String key, dynamic value) async {
    await box.put(key, value);
  }

  static dynamic getValue(String key) {
    return box.get(key);
  }

  // ============ Utility Operations ============

  static Future<void> remove(String key) async {
    await box.delete(key);
  }

  static Future<void> clear() async {
    await box.clear();
  }

  static bool containsKey(String key) {
    return box.containsKey(key);
  }

  static List<String> get keys {
    return box.keys.cast<String>().toList();
  }
}
