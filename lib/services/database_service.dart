import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// خدمة قاعدة البيانات المحلية SQLite
/// تعمل مثل MySQL لكن على الموبايل
class DatabaseService {
  static Database? _database;
  static const String _dbName = 'vitafit.db';
  static const int _dbVersion = 1;

  // ==================== Database Initialization ====================

  /// Get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create all tables
  static Future<void> _onCreate(Database db, int version) async {
    // جدول المستخدمين
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE,
        phone TEXT,
        avatar TEXT,
        type TEXT DEFAULT 'trainee',
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // جدول المنتجات
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        discount INTEGER DEFAULT 0,
        category TEXT,
        images TEXT,
        rating REAL DEFAULT 0,
        reviews INTEGER DEFAULT 0,
        sizes TEXT,
        colors TEXT,
        in_stock INTEGER DEFAULT 1,
        stock INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // جدول سلة التسوق
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL,
        quantity INTEGER DEFAULT 1,
        size TEXT,
        color TEXT,
        created_at TEXT,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // جدول المفضلة
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL UNIQUE,
        created_at TEXT,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');

    // جدول الطلبات
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        order_number TEXT,
        total REAL,
        status TEXT DEFAULT 'pending',
        shipping_address TEXT,
        shipping_city TEXT,
        phone TEXT,
        payment_method TEXT,
        notes TEXT,
        items_count INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // جدول عناصر الطلب
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        product_id TEXT,
        product_name TEXT,
        quantity INTEGER,
        price REAL,
        size TEXT,
        color TEXT,
        FOREIGN KEY (order_id) REFERENCES orders(id)
      )
    ''');

    // جدول التمارين
    await db.execute('''
      CREATE TABLE workouts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        difficulty TEXT,
        duration INTEGER,
        calories INTEGER,
        image TEXT,
        video_url TEXT,
        exercises TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // جدول التمارين الفردية
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        difficulty TEXT,
        sets INTEGER,
        reps INTEGER,
        duration INTEGER,
        rest_seconds INTEGER,
        image TEXT,
        video_url TEXT,
        instructions TEXT,
        created_at TEXT
      )
    ''');

    // جدول الوجبات
    await db.execute('''
      CREATE TABLE meals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        type TEXT,
        calories INTEGER,
        protein REAL,
        carbs REAL,
        fats REAL,
        image TEXT,
        ingredients TEXT,
        instructions TEXT,
        prep_time INTEGER,
        created_at TEXT
      )
    ''');

    // جدول سجل الوجبات اليومية
    await db.execute('''
      CREATE TABLE meal_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meal_id TEXT,
        meal_name TEXT,
        meal_type TEXT,
        calories INTEGER,
        protein REAL,
        carbs REAL,
        fats REAL,
        date TEXT,
        created_at TEXT
      )
    ''');

    // جدول المدربات
    await db.execute('''
      CREATE TABLE trainers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        avatar TEXT,
        specialization TEXT,
        experience_years INTEGER,
        rating REAL,
        clients_count INTEGER,
        bio TEXT,
        created_at TEXT
      )
    ''');

    // جدول المتدربات (للمدربة)
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        subscription TEXT,
        joined_at TEXT,
        last_session TEXT,
        total_sessions INTEGER DEFAULT 0,
        progress REAL DEFAULT 0,
        notes TEXT,
        created_at TEXT
      )
    ''');

    // جدول الجلسات
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        day TEXT,
        time TEXT,
        duration INTEGER,
        type TEXT,
        max_participants INTEGER,
        participants_count INTEGER DEFAULT 0,
        is_online INTEGER DEFAULT 0,
        meeting_url TEXT,
        meeting_id TEXT,
        meeting_password TEXT,
        notes TEXT,
        status TEXT DEFAULT 'scheduled',
        scheduled_at TEXT,
        created_at TEXT
      )
    ''');

    // جدول الاشتراكات
    await db.execute('''
      CREATE TABLE subscriptions (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT,
        price REAL,
        duration_months INTEGER,
        features TEXT,
        status TEXT DEFAULT 'active',
        start_date TEXT,
        end_date TEXT,
        created_at TEXT
      )
    ''');

    // جدول الإشعارات
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT,
        body TEXT,
        type TEXT,
        data TEXT,
        is_read INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    // جدول تقدم المستخدم
    await db.execute('''
      CREATE TABLE progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL,
        height REAL,
        body_fat REAL,
        muscle_mass REAL,
        waist REAL,
        chest REAL,
        arms REAL,
        notes TEXT,
        date TEXT,
        created_at TEXT
      )
    ''');

    // جدول الأهداف
    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        target_value REAL,
        current_value REAL,
        unit TEXT,
        deadline TEXT,
        status TEXT DEFAULT 'active',
        created_at TEXT
      )
    ''');

    // جدول الإعدادات
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT,
        updated_at TEXT
      )
    ''');

    // جدول الكاش
    await db.execute('''
      CREATE TABLE cache (
        key TEXT PRIMARY KEY,
        value TEXT,
        expires_at TEXT,
        created_at TEXT
      )
    ''');

    debugPrint('Database tables created successfully');
  }

  /// Upgrade database
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here
    if (oldVersion < 2) {
      // Migration from v1 to v2
    }
  }

  // ==================== Generic CRUD Operations ====================

  /// Insert a record
  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    data['created_at'] = DateTime.now().toIso8601String();
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Insert multiple records
  static Future<void> insertAll(String table, List<Map<String, dynamic>> dataList) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (var data in dataList) {
      data['created_at'] = now;
      batch.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  /// Update a record
  static Future<int> update(String table, Map<String, dynamic> data, String where, List<dynamic> whereArgs) async {
    final db = await database;
    data['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  /// Delete a record
  static Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Query records
  static Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Raw SQL query
  static Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Clear a table
  static Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  /// Clear all tables
  static Future<void> clearAllTables() async {
    final tables = [
      'products', 'cart_items', 'favorites', 'orders', 'order_items',
      'workouts', 'exercises', 'meals', 'meal_logs', 'trainers',
      'clients', 'sessions', 'subscriptions', 'notifications',
      'progress', 'goals', 'cache'
    ];

    for (var table in tables) {
      await clearTable(table);
    }
  }

  // ==================== Products ====================

  /// Save products
  static Future<void> saveProducts(List<dynamic> products) async {
    final productMaps = products.map((p) => {
      'id': p['id'].toString(),
      'name': p['name'],
      'description': p['description'],
      'price': p['price'],
      'discount': p['discount'] ?? 0,
      'category': p['category'],
      'images': json.encode(p['images'] ?? []),
      'rating': p['rating'] ?? 0,
      'reviews': p['reviews'] ?? 0,
      'sizes': json.encode(p['sizes'] ?? []),
      'colors': json.encode(p['colors'] ?? []),
      'in_stock': (p['inStock'] ?? p['in_stock'] ?? true) ? 1 : 0,
      'stock': p['stock'] ?? 0,
    }).toList();

    await insertAll('products', productMaps);
  }

  /// Get all products
  static Future<List<Map<String, dynamic>>> getProducts({String? category}) async {
    String? where;
    List<dynamic>? whereArgs;

    if (category != null && category.isNotEmpty && category != 'الكل') {
      where = 'category = ?';
      whereArgs = [category];
    }

    final results = await query('products', where: where, whereArgs: whereArgs);

    return results.map((p) => {
      ...p,
      'images': json.decode(p['images'] ?? '[]'),
      'sizes': json.decode(p['sizes'] ?? '[]'),
      'colors': json.decode(p['colors'] ?? '[]'),
      'inStock': p['in_stock'] == 1,
    }).toList();
  }

  // ==================== Cart ====================

  /// Add to cart
  static Future<void> addToCart(String productId, {int quantity = 1, String? size, String? color}) async {
    await insert('cart_items', {
      'product_id': productId,
      'quantity': quantity,
      'size': size,
      'color': color,
    });
  }

  /// Get cart items
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    return await rawQuery('''
      SELECT c.*, p.name, p.price, p.discount, p.images
      FROM cart_items c
      LEFT JOIN products p ON c.product_id = p.id
    ''');
  }

  /// Update cart quantity
  static Future<void> updateCartQuantity(int id, int quantity) async {
    await update('cart_items', {'quantity': quantity}, 'id = ?', [id]);
  }

  /// Remove from cart
  static Future<void> removeFromCart(int id) async {
    await delete('cart_items', 'id = ?', [id]);
  }

  /// Clear cart
  static Future<void> clearCart() async {
    await clearTable('cart_items');
  }

  // ==================== Favorites ====================

  /// Add to favorites
  static Future<void> addToFavorites(String productId) async {
    await insert('favorites', {'product_id': productId});
  }

  /// Remove from favorites
  static Future<void> removeFromFavorites(String productId) async {
    await delete('favorites', 'product_id = ?', [productId]);
  }

  /// Get favorites
  static Future<List<String>> getFavoriteIds() async {
    final results = await query('favorites');
    return results.map((f) => f['product_id'].toString()).toList();
  }

  /// Check if favorite
  static Future<bool> isFavorite(String productId) async {
    final results = await query('favorites', where: 'product_id = ?', whereArgs: [productId]);
    return results.isNotEmpty;
  }

  // ==================== Orders ====================

  /// Save orders
  static Future<void> saveOrders(List<dynamic> orders) async {
    final orderMaps = orders.map((o) => {
      'id': o['id'].toString(),
      'order_number': o['order_number'],
      'total': o['total'],
      'status': o['status'],
      'items_count': o['items_count'],
      'created_at': o['created_at'],
    }).toList();

    await insertAll('orders', orderMaps);
  }

  /// Get orders
  static Future<List<Map<String, dynamic>>> getOrders() async {
    return await query('orders', orderBy: 'created_at DESC');
  }

  // ==================== Workouts ====================

  /// Save workouts
  static Future<void> saveWorkouts(List<dynamic> workouts) async {
    final workoutMaps = workouts.map((w) => {
      'id': w['id'].toString(),
      'name': w['name'],
      'description': w['description'],
      'category': w['category'],
      'difficulty': w['difficulty'],
      'duration': w['duration'],
      'calories': w['calories'],
      'image': w['image'],
      'exercises': json.encode(w['exercises'] ?? []),
    }).toList();

    await insertAll('workouts', workoutMaps);
  }

  /// Get workouts
  static Future<List<Map<String, dynamic>>> getWorkouts() async {
    final results = await query('workouts');
    return results.map((w) => {
      ...w,
      'exercises': json.decode(w['exercises'] ?? '[]'),
    }).toList();
  }

  // ==================== Meals ====================

  /// Save meals
  static Future<void> saveMeals(List<dynamic> meals) async {
    final mealMaps = meals.map((m) => {
      'id': m['id'].toString(),
      'name': m['name'],
      'description': m['description'],
      'type': m['type'],
      'calories': m['calories'],
      'protein': m['protein'],
      'carbs': m['carbs'],
      'fats': m['fats'],
      'image': m['image'],
      'ingredients': json.encode(m['ingredients'] ?? []),
      'instructions': m['instructions'],
      'prep_time': m['prep_time'],
    }).toList();

    await insertAll('meals', mealMaps);
  }

  /// Get meals
  static Future<List<Map<String, dynamic>>> getMeals() async {
    final results = await query('meals');
    return results.map((m) => {
      ...m,
      'ingredients': json.decode(m['ingredients'] ?? '[]'),
    }).toList();
  }

  /// Log a meal
  static Future<void> logMeal(Map<String, dynamic> meal, String mealType, String date) async {
    await insert('meal_logs', {
      'meal_id': meal['id'],
      'meal_name': meal['name'],
      'meal_type': mealType,
      'calories': meal['calories'],
      'protein': meal['protein'],
      'carbs': meal['carbs'],
      'fats': meal['fats'],
      'date': date,
    });
  }

  /// Get meal logs for date
  static Future<List<Map<String, dynamic>>> getMealLogs(String date) async {
    return await query('meal_logs', where: 'date = ?', whereArgs: [date]);
  }

  // ==================== Clients (for Trainer) ====================

  /// Save clients
  static Future<void> saveClients(List<dynamic> clients) async {
    final clientMaps = clients.map((c) => {
      'id': c['id'].toString(),
      'name': c['name'],
      'email': c['email'],
      'phone': c['phone'],
      'subscription': c['subscription'],
      'joined_at': c['joined_at'],
      'last_session': c['last_session'],
      'total_sessions': c['total_sessions'] ?? 0,
    }).toList();

    await insertAll('clients', clientMaps);
  }

  /// Get clients
  static Future<List<Map<String, dynamic>>> getClients() async {
    return await query('clients', orderBy: 'name ASC');
  }

  // ==================== Sessions ====================

  /// Save sessions
  static Future<void> saveSessions(List<dynamic> sessions) async {
    final sessionMaps = sessions.map((s) => {
      'id': s['id'].toString(),
      'title': s['title'],
      'day': s['day'],
      'time': s['time'],
      'duration': s['duration'],
      'type': s['type'],
      'max_participants': s['max_participants'],
      'participants_count': s['participants_count'] ?? 0,
      'is_online': (s['is_online'] ?? false) ? 1 : 0,
      'meeting_url': s['meeting_url'],
      'meeting_id': s['meeting_id'],
      'meeting_password': s['meeting_password'],
      'notes': s['notes'],
      'status': s['status'],
      'scheduled_at': s['scheduled_at'],
    }).toList();

    await insertAll('sessions', sessionMaps);
  }

  /// Get sessions
  static Future<List<Map<String, dynamic>>> getSessions() async {
    final results = await query('sessions', orderBy: 'scheduled_at ASC');
    return results.map((s) => {
      ...s,
      'is_online': s['is_online'] == 1,
    }).toList();
  }

  // ==================== Progress ====================

  /// Save progress
  static Future<void> saveProgress(Map<String, dynamic> progress) async {
    await insert('progress', {
      'weight': progress['weight'],
      'height': progress['height'],
      'body_fat': progress['body_fat'],
      'muscle_mass': progress['muscle_mass'],
      'waist': progress['waist'],
      'chest': progress['chest'],
      'arms': progress['arms'],
      'notes': progress['notes'],
      'date': progress['date'] ?? DateTime.now().toIso8601String().split('T')[0],
    });
  }

  /// Get progress history
  static Future<List<Map<String, dynamic>>> getProgressHistory() async {
    return await query('progress', orderBy: 'date DESC', limit: 30);
  }

  // ==================== Trainers ====================

  /// Save trainers
  static Future<void> saveTrainers(List<dynamic> trainers) async {
    final trainerMaps = trainers.map((t) => {
      'id': t['id'].toString(),
      'name': t['name'],
      'email': t['email'],
      'phone': t['phone'],
      'avatar': t['avatar'],
      'specialization': t['specialization'],
      'experience_years': t['experience_years'],
      'rating': t['rating'],
      'clients_count': t['clients_count'],
      'bio': t['bio'],
    }).toList();

    await insertAll('trainers', trainerMaps);
  }

  /// Get trainers
  static Future<List<Map<String, dynamic>>> getTrainers() async {
    return await query('trainers', orderBy: 'rating DESC');
  }

  // ==================== Cache ====================

  /// Save to cache
  static Future<void> saveToCache(String key, dynamic value, {int expiresInMinutes = 60}) async {
    final expiresAt = DateTime.now().add(Duration(minutes: expiresInMinutes));
    await insert('cache', {
      'key': key,
      'value': json.encode(value),
      'expires_at': expiresAt.toIso8601String(),
    });
  }

  /// Get from cache
  static Future<dynamic> getFromCache(String key) async {
    final results = await query('cache', where: 'key = ?', whereArgs: [key]);
    if (results.isEmpty) return null;

    final cache = results.first;
    final expiresAt = DateTime.parse(cache['expires_at']);

    if (DateTime.now().isAfter(expiresAt)) {
      await delete('cache', 'key = ?', [key]);
      return null;
    }

    return json.decode(cache['value']);
  }

  /// Clear expired cache
  static Future<void> clearExpiredCache() async {
    final now = DateTime.now().toIso8601String();
    await delete('cache', 'expires_at < ?', [now]);
  }

  // ==================== Settings ====================

  /// Save setting
  static Future<void> saveSetting(String key, String value) async {
    await insert('settings', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get setting
  static Future<String?> getSetting(String key) async {
    final results = await query('settings', where: 'key = ?', whereArgs: [key]);
    if (results.isEmpty) return null;
    return results.first['value'];
  }

  // ==================== User ====================

  /// Save current user
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await insert('users', {
      'id': user['id'],
      'name': user['name'],
      'email': user['email'],
      'phone': user['phone'],
      'avatar': user['avatar'],
      'type': user['type'],
    });
  }

  /// Get current user
  static Future<Map<String, dynamic>?> getUser() async {
    final results = await query('users', limit: 1);
    if (results.isEmpty) return null;
    return results.first;
  }

  /// Clear user data (on logout)
  static Future<void> clearUserData() async {
    await clearTable('users');
    await clearTable('cart_items');
    await clearTable('favorites');
    await clearTable('meal_logs');
    await clearTable('progress');
    await clearTable('goals');
    await clearTable('notifications');
  }

  // ==================== Database Info ====================

  /// Get database size
  static Future<int> getDatabaseSize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    // Note: Getting actual file size requires platform-specific code
    // This is a placeholder
    return 0;
  }

  /// Get record count for table
  static Future<int> getRecordCount(String table) async {
    final result = await rawQuery('SELECT COUNT(*) as count FROM $table');
    return result.first['count'] as int;
  }

  /// Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
