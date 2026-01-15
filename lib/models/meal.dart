/// نموذج بيانات الوجبة - Meal Model
class Meal {
  final String id;
  final String name;
  final String description;
  final int calories;
  final int protein; // بالجرام
  final int carbs; // بالجرام
  final int fats; // بالجرام
  final String category; // إفطار، غداء، عشاء، سناك
  final String imageUrl;
  final List<String> ingredients;
  final String prepTime; // وقت التحضير
  final String difficulty; // سهل، متوسط، صعب
  final String time; // الوقت (مثل: 08:00 ص)
  final String type; // نوع الوجبة (إفطار، غداء، عشاء، سناك)

  const Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.category,
    required this.imageUrl,
    required this.ingredients,
    required this.prepTime,
    required this.difficulty,
    this.time = '08:00 ص',
    this.type = 'إفطار',
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      calories: json['calories'] as int,
      protein: json['protein'] as int,
      carbs: json['carbs'] as int,
      fats: json['fats'] as int,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      prepTime: json['prepTime'] as String,
      difficulty: json['difficulty'] as String,
      time: json['time'] as String? ?? '08:00 ص',
      type: json['type'] as String? ?? 'إفطار',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'category': category,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'prepTime': prepTime,
      'difficulty': difficulty,
      'time': time,
      'type': type,
    };
  }
}

/// نموذج بيانات الخطة الغذائية اليومية - Daily Meal Plan
class DailyMealPlan {
  final String date;
  final List<Meal> meals;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFats;

  const DailyMealPlan({
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
  });
}
