import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive Storage Service - Replacement for SharedPreferences
/// This is compatible with iPad and doesn't cause crashes
class HiveStorageService {
  static const String _boxName = 'vitafit_storage';
  static Box? _box;
  static bool _initialized = false;

  /// Initialize Hive storage
  static Future<void> init() async {
    if (_initialized && _box != null) return;

    try {
      await Hive.initFlutter();
    } catch (e) {
      debugPrint('Hive.initFlutter error (may already be initialized): $e');
      // Continue - Hive might already be initialized
    }

    try {
      _box = await Hive.openBox(_boxName);
      _initialized = true;
      debugPrint('Hive initialized successfully');
      return;
    } catch (e) {
      debugPrint('Hive open box error: $e');
    }

    // Try to recover by deleting corrupted box
    try {
      await Hive.deleteBoxFromDisk(_boxName);
      _box = await Hive.openBox(_boxName);
      _initialized = true;
      debugPrint('Hive recovered after deleting corrupted box');
      return;
    } catch (e2) {
      debugPrint('Hive recovery failed: $e2');
    }

    // Last resort: try with a different box name
    try {
      _box = await Hive.openBox('${_boxName}_v2');
      _initialized = true;
      debugPrint('Hive opened with alternative box name');
    } catch (e3) {
      debugPrint('Hive final recovery failed: $e3');
      _initialized = false;
      _box = null;
    }
  }

  /// Get the storage box (returns null if not initialized)
  static Box? get box => _box;

  /// Check if initialized
  static bool get isInitialized => _initialized && _box != null;

  // ============ String Operations ============

  static Future<void> setString(String key, String value) async {
    if (_box == null) {
      debugPrint('HiveStorageService: Cannot set string, not initialized');
      return;
    }
    await _box!.put(key, value);
  }

  static String? getString(String key) {
    if (_box == null) {
      debugPrint('HiveStorageService: Cannot get string, not initialized');
      return null;
    }
    try {
      return _box!.get(key) as String?;
    } catch (e) {
      debugPrint('HiveStorageService getString error: $e');
      return null;
    }
  }

  // ============ Int Operations ============

  static Future<void> setInt(String key, int value) async {
    if (_box == null) return;
    await _box!.put(key, value);
  }

  static int? getInt(String key) {
    if (_box == null) return null;
    try {
      return _box!.get(key) as int?;
    } catch (e) {
      debugPrint('HiveStorageService getInt error: $e');
      return null;
    }
  }

  // ============ Double Operations ============

  static Future<void> setDouble(String key, double value) async {
    if (_box == null) return;
    await _box!.put(key, value);
  }

  static double? getDouble(String key) {
    if (_box == null) return null;
    try {
      return _box!.get(key) as double?;
    } catch (e) {
      debugPrint('HiveStorageService getDouble error: $e');
      return null;
    }
  }

  // ============ Bool Operations ============

  static Future<void> setBool(String key, bool value) async {
    if (_box == null) return;
    await _box!.put(key, value);
  }

  static bool? getBool(String key) {
    if (_box == null) return null;
    try {
      return _box!.get(key) as bool?;
    } catch (e) {
      debugPrint('HiveStorageService getBool error: $e');
      return null;
    }
  }

  // ============ List Operations ============

  static Future<void> setStringList(String key, List<String> value) async {
    if (_box == null) return;
    await _box!.put(key, value);
  }

  static List<String>? getStringList(String key) {
    if (_box == null) return null;
    try {
      final value = _box!.get(key);
      if (value == null) return null;
      return (value as List).cast<String>();
    } catch (e) {
      debugPrint('HiveStorageService getStringList error: $e');
      return null;
    }
  }

  // ============ Generic Operations ============

  static Future<void> setValue(String key, dynamic value) async {
    if (_box == null) return;
    await _box!.put(key, value);
  }

  static dynamic getValue(String key) {
    if (_box == null) return null;
    try {
      return _box!.get(key);
    } catch (e) {
      debugPrint('HiveStorageService getValue error: $e');
      return null;
    }
  }

  // ============ Utility Operations ============

  static Future<void> remove(String key) async {
    if (_box == null) return;
    await _box!.delete(key);
  }

  static Future<void> clear() async {
    if (_box == null) return;
    await _box!.clear();
  }

  static bool containsKey(String key) {
    if (_box == null) return false;
    return _box!.containsKey(key);
  }

  static List<String> get keys {
    if (_box == null) return [];
    return _box!.keys.cast<String>().toList();
  }
}
