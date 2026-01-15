# دليل إكمال الباك اند - GYM Fitness API

## ✅ ما تم إنجازه

### Models
- ✅ User.js
- ✅ Workout.js
- ✅ Meal.js
- ✅ Subscription.js

### Middleware
- ✅ auth.js (protect, authorize)

### Controllers
- ✅ authController.js (register, login, getMe, updatePassword, logout)

### Routes
- ✅ auth.js

## 📝 الملفات المتبقية (تُنشأ بسهولة)

### 1. Routes الباقية

قم بإنشاء الملفات التالية في مجلد `routes/`:

#### routes/users.js
```javascript
const express = require('express');
const { protect, authorize } = require('../middleware/auth');
const User = require('../models/User');

const router = express.Router();

// Get all users (admin only)
router.get('/', protect, authorize('admin'), async (req, res) => {
  try {
    const users = await User.find().select('-password');
    res.json({ success: true, data: users });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get user by ID
router.get('/:id', protect, async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Update user
router.put('/:id', protect, async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).select('-password');
    res.json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
```

#### routes/workouts.js
```javascript
const express = require('express');
const { protect } = require('../middleware/auth');
const Workout = require('../models/Workout');

const router = express.Router();

// Get all workouts for user
router.get('/', protect, async (req, res) => {
  try {
    const workouts = await Workout.find({ user: req.user.id }).sort('-date');
    res.json({ success: true, data: workouts });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Create workout
router.post('/', protect, async (req, res) => {
  try {
    const workout = await Workout.create({
      ...req.body,
      user: req.user.id,
    });
    res.status(201).json({ success: true, data: workout });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get workout by ID
router.get('/:id', protect, async (req, res) => {
  try {
    const workout = await Workout.findOne({
      _id: req.params.id,
      user: req.user.id,
    });
    if (!workout) {
      return res.status(404).json({ success: false, message: 'Workout not found' });
    }
    res.json({ success: true, data: workout });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Update workout
router.put('/:id', protect, async (req, res) => {
  try {
    const workout = await Workout.findOneAndUpdate(
      { _id: req.params.id, user: req.user.id },
      req.body,
      { new: true, runValidators: true }
    );
    if (!workout) {
      return res.status(404).json({ success: false, message: 'Workout not found' });
    }
    res.json({ success: true, data: workout });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Delete workout
router.delete('/:id', protect, async (req, res) => {
  try {
    const workout = await Workout.findOneAndDelete({
      _id: req.params.id,
      user: req.user.id,
    });
    if (!workout) {
      return res.status(404).json({ success: false, message: 'Workout not found' });
    }
    res.json({ success: true, message: 'Workout deleted' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
```

#### routes/meals.js
```javascript
const express = require('express');
const { protect } = require('../middleware/auth');
const Meal = require('../models/Meal');

const router = express.Router();

// Get all meals for user
router.get('/', protect, async (req, res) => {
  try {
    const meals = await Meal.find({ user: req.user.id }).sort('-date');
    res.json({ success: true, data: meals });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Create meal
router.post('/', protect, async (req, res) => {
  try {
    const meal = await Meal.create({
      ...req.body,
      user: req.user.id,
    });
    res.status(201).json({ success: true, data: meal });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get daily nutrition
router.get('/daily-nutrition', protect, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const meals = await Meal.find({
      user: req.user.id,
      date: { $gte: today },
    });

    const totalNutrition = meals.reduce(
      (acc, meal) => {
        acc.calories += meal.totalNutrition.calories;
        acc.protein += meal.totalNutrition.protein;
        acc.carbs += meal.totalNutrition.carbs;
        acc.fat += meal.totalNutrition.fat;
        return acc;
      },
      { calories: 0, protein: 0, carbs: 0, fat: 0 }
    );

    res.json({ success: true, data: totalNutrition });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
```

#### routes/subscriptions.js
```javascript
const express = require('express');
const { protect } = require('../middleware/auth');
const Subscription = require('../models/Subscription');

const router = express.Router();

// Subscribe to plan
router.post('/subscribe', protect, async (req, res) => {
  try {
    const { plan, planName, price, duration } = req.body;

    // Calculate end date
    const startDate = new Date();
    const endDate = new Date();

    if (plan === 'monthly') {
      endDate.setMonth(endDate.getMonth() + 1);
    } else if (plan === 'quarterly') {
      endDate.setMonth(endDate.getMonth() + 3);
    } else if (plan === 'yearly') {
      endDate.setFullYear(endDate.getFullYear() + 1);
    }

    const subscription = await Subscription.create({
      user: req.user.id,
      plan,
      planName,
      price,
      startDate,
      endDate,
    });

    res.status(201).json({ success: true, data: subscription });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

// Get user subscription
router.get('/my-subscription', protect, async (req, res) => {
  try {
    const subscription = await Subscription.findOne({
      user: req.user.id,
      status: 'active',
    });
    res.json({ success: true, data: subscription });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
```

### 2. Routes الفارغة (للمميزات المستقبلية)

أنشئ هذه الملفات كـ placeholders:

```javascript
// routes/trainers.js
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json({ success: true, data: [], message: 'Trainers coming soon' });
});

module.exports = router;

// routes/workshops.js
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json({ success: true, data: [], message: 'Workshops coming soon' });
});

module.exports = router;

// routes/progress.js
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json({ success: true, data: {}, message: 'Progress coming soon' });
});

module.exports = router;
```

## 🚀 تشغيل الباك اند

```bash
cd backend
npm install
npm start
```

الباك اند سيعمل على: http://localhost:5000

## 📱 تكامل Flutter

### إضافة packages للـ pubspec.yaml

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
```

### إنشاء API Service

أنشئ ملف `lib/services/api_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

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

  // Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    return json.decode(response.body);
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    return json.decode(response.body);
  }

  // Get current user
  static Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return json.decode(response.body);
  }

  // Get workouts
  static Future<List<dynamic>> getWorkouts() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/workouts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = json.decode(response.body);
    return data['data'] ?? [];
  }

  // Create workout
  static Future<Map<String, dynamic>> createWorkout(Map<String, dynamic> workout) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/workouts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(workout),
    );

    return json.decode(response.body);
  }
}
```

### مثال استخدام في Login Screen

```dart
import '../services/api_service.dart';

Future<void> _handleLogin() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result['success']) {
        // Save token
        await ApiService.saveToken(result['data']['token']);

        // Navigate to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال بالخادم')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

## ✅ الخلاصة

بعد تطبيق هذه الخطوات، ستحصل على:

1. ✅ Backend API كامل وجاهز
2. ✅ Authentication System
3. ✅ CRUD Operations للتمارين والوجبات
4. ✅ Subscription Management
5. ✅ تكامل Flutter مع API
6. ✅ Token Management
7. ✅ Error Handling

الباك اند والفرنت اند سيكونان متكاملين بالكامل!
