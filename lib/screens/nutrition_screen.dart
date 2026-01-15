import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/meal.dart';
import '../services/api_service.dart';
import 'meal_detail_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  List<Meal> todayMeals = [];
  List<Map<String, dynamic>> trainerMeals = [];
  bool _isLoading = true;
  String? trainerName;

  // الأهداف اليومية - تأتي من إعدادات المستخدم أو المدرب
  int targetCalories = 0;
  int targetProtein = 0;
  int targetCarbs = 0;
  int targetFats = 0;

  final List<String> dayNames = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // جلب خطة التغذية من المدرب
      final trainerMealsResult = await ApiService.getMyTrainerMeals();
      if (trainerMealsResult['success'] == true && trainerMealsResult['data'] != null) {
        trainerMeals = List<Map<String, dynamic>>.from(trainerMealsResult['data']['meals'] ?? []);
        trainerName = trainerMealsResult['data']['trainer']?['name'];

        // جلب الأهداف من المدرب
        final trainerGoals = trainerMealsResult['data']['goals'];
        if (trainerGoals != null) {
          targetCalories = trainerGoals['calories'] ?? 0;
          targetProtein = trainerGoals['protein'] ?? 0;
          targetCarbs = trainerGoals['carbs'] ?? 0;
          targetFats = trainerGoals['fats'] ?? 0;
        }
      }

      // إذا لم توجد خطة من المدرب، جلب الوجبات العامة
      if (trainerMeals.isEmpty) {
        final meals = await ApiService.getMeals();
        setState(() {
          todayMeals = meals.map((m) {
            final items = m['items'] as List<dynamic>? ?? [];
            return Meal(
              id: m['_id']?.toString() ?? '',
              name: m['name'] ?? '',
              description: m['notes'] ?? '',
              calories: m['calories'] ?? 0,
              protein: m['protein'] ?? 0,
              carbs: m['carbs'] ?? 0,
              fats: m['fats'] ?? 0,
              category: _getMealCategory(m['type']),
              imageUrl: '',
              ingredients: items.map((i) => i['name']?.toString() ?? '').toList(),
              prepTime: '${m['time'] ?? ''}',
              difficulty: 'متوسط',
            );
          }).toList();
        });
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getMealCategory(String? type) {
    switch (type) {
      case 'breakfast':
        return 'إفطار';
      case 'lunch':
        return 'غداء';
      case 'dinner':
        return 'عشاء';
      case 'snack':
        return 'سناك';
      default:
        return 'وجبة';
    }
  }

  @override
  Widget build(BuildContext context) {
    // حساب المجموع
    int totalCalories = todayMeals.fold(0, (sum, meal) => sum + meal.calories);
    int totalProtein = todayMeals.fold(0, (sum, meal) => sum + meal.protein);
    int totalCarbs = todayMeals.fold(0, (sum, meal) => sum + meal.carbs);
    int totalFats = todayMeals.fold(0, (sum, meal) => sum + meal.fats);

    if (_isLoading) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppTheme.primary),
                const SizedBox(height: AppTheme.md),
                const Text('جاري تحميل خطة التغذية...', style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.gradientSecondary,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          'تغذيتي 🥗',
                          style: TextStyle(
                            fontSize: AppTheme.fontXxl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(height: AppTheme.sm),
                        Text(
                          targetCalories > 0
                              ? 'هدفك: $targetCalories سعرة حرارية'
                              : 'تتبعي نظامك الغذائي',
                          style: const TextStyle(
                            fontSize: AppTheme.fontMd,
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // المحتوى
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ملخص السعرات
                      _buildCaloriesSummary(
                        totalCalories,
                        totalProtein,
                        totalCarbs,
                        totalFats,
                      ),

                      const SizedBox(height: AppTheme.lg),

                      // Macros Progress - فقط إذا كانت الأهداف محددة
                      if (targetProtein > 0 || targetCarbs > 0 || targetFats > 0)
                        _buildMacrosProgress(totalProtein, totalCarbs, totalFats),

                      if (targetProtein > 0 || targetCarbs > 0 || targetFats > 0)
                        const SizedBox(height: AppTheme.lg),

                      // خطة التغذية من المدرب
                      if (trainerMeals.isNotEmpty) ...[
                        _buildTrainerMealPlanSection(),
                        const SizedBox(height: AppTheme.lg),
                      ],

                      // وجبات اليوم (الوجبات العامة إذا لم توجد خطة من المدرب)
                      if (trainerMeals.isEmpty) ...[
                        const Text(
                          'وجبات اليوم',
                          style: TextStyle(
                            fontSize: AppTheme.fontLg,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.text,
                          ),
                        ),
                        const SizedBox(height: AppTheme.md),

                        // قائمة الوجبات
                        if (todayMeals.isEmpty)
                          _buildEmptyMealsState()
                        else
                          ...todayMeals.asMap().entries.map((entry) {
                            int index = entry.key;
                            Meal meal = entry.value;
                            return _buildMealCard(meal, index);
                          }),
                      ],

                      const SizedBox(height: AppTheme.lg),

                      // نصائح التغذية
                      _buildNutritionTips(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesSummary(
    int totalCalories,
    int totalProtein,
    int totalCarbs,
    int totalFats,
  ) {
    double progress = targetCalories > 0 ? totalCalories / targetCalories : 0;
    int remaining = targetCalories - totalCalories;
    bool hasGoals = targetCalories > 0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x26FF69B4), Color(0x26DDA0DD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: AppTheme.shadowGlow,
      ),
      padding: const EdgeInsets.all(AppTheme.lg),
      child: hasGoals
          ? Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'السعرات المستهلكة',
                          style: TextStyle(
                            fontSize: AppTheme.fontMd,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.xs),
                        Text(
                          '$totalCalories',
                          style: const TextStyle(
                            fontSize: AppTheme.fontXxl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          'من $targetCalories سعرة',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSm,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: progress > 1 ? 1 : progress,
                              strokeWidth: 12,
                              backgroundColor: AppTheme.white.withValues(alpha: 0.1),
                              valueColor: const AlwaysStoppedAnimation(
                                AppTheme.primary,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                remaining > 0 ? '$remaining' : '0',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontXl,
                                  fontWeight: AppTheme.fontBold,
                                  color: AppTheme.text,
                                ),
                              ),
                              Text(
                                remaining > 0 ? 'متبقي' : 'مكتمل',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontXs,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 48,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: AppTheme.md),
                const Text(
                  'لم يتم تحديد أهداف السعرات',
                  style: TextStyle(
                    fontSize: AppTheme.fontLg,
                    fontWeight: AppTheme.fontBold,
                    color: AppTheme.text,
                  ),
                ),
                const SizedBox(height: AppTheme.xs),
                const Text(
                  'سيقوم المدرب بتحديد أهدافك الغذائية',
                  style: TextStyle(
                    fontSize: AppTheme.fontSm,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildMacrosProgress(int protein, int carbs, int fats) {
    return Row(
      children: [
        Expanded(
          child: _buildMacroCard(
            'بروتين',
            protein,
            targetProtein,
            Icons.fitness_center,
            AppTheme.success,
          ),
        ),
        const SizedBox(width: AppTheme.sm),
        Expanded(
          child: _buildMacroCard(
            'كربوهيدرات',
            carbs,
            targetCarbs,
            Icons.grain,
            AppTheme.warning,
          ),
        ),
        const SizedBox(width: AppTheme.sm),
        Expanded(
          child: _buildMacroCard(
            'دهون',
            fats,
            targetFats,
            Icons.water_drop,
            AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard(
    String label,
    int current,
    int target,
    IconData icon,
    Color color,
  ) {
    double progress = target > 0 ? current / target : 0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      padding: const EdgeInsets.all(AppTheme.md),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: AppTheme.xs),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.fontXs,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.xs),
          Text(
            '$current\u062c',
            style: const TextStyle(
              fontSize: AppTheme.fontLg,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: AppTheme.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            child: LinearProgressIndicator(
              value: progress > 1 ? 1 : progress,
              minHeight: 4,
              backgroundColor: AppTheme.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildMealCard(Meal meal, int index) {
    return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.md),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealDetailScreen(meal: meal),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.md),
                child: Row(
                  children: [
                    // أيقونة الوجبة
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: AppTheme.gradientPrimary,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Icon(
                        _getMealIcon(meal.category),
                        size: 28,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),

                    // معلومات الوجبة
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  meal.name,
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontMd,
                                    fontWeight: AppTheme.fontSemibold,
                                    color: AppTheme.text,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.sm,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSm,
                                  ),
                                ),
                                child: Text(
                                  meal.category,
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontXs,
                                    color: AppTheme.primary,
                                    fontWeight: AppTheme.fontMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.xs),
                          Text(
                            meal.description,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSm,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTheme.sm),
                          Row(
                            children: [
                              _buildNutrientChip(
                                '${meal.calories} سعرة',
                                Icons.local_fire_department,
                                AppTheme.error,
                              ),
                              const SizedBox(width: AppTheme.sm),
                              _buildNutrientChip(
                                '${meal.protein}جم بروتين',
                                Icons.fitness_center,
                                AppTheme.success,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: (300 + index * 100).ms)
        .slideX(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
          delay: (300 + index * 100).ms,
        );
  }

  Widget _buildNutrientChip(String label, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontXs,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerMealPlanSection() {
    // تجميع الوجبات حسب نوعها
    final mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    final mealTypeNames = {'breakfast': 'الإفطار', 'lunch': 'الغداء', 'dinner': 'العشاء', 'snack': 'سناك'};
    final mealTypeIcons = {'breakfast': Icons.wb_sunny, 'lunch': Icons.wb_cloudy, 'dinner': Icons.nightlight_round, 'snack': Icons.cookie};

    // فلترة وجبات اليوم الحالي
    final todayDayOfWeek = DateTime.now().weekday % 7;
    final todayTrainerMeals = trainerMeals.where((m) => m['day_of_week'] == null || m['day_of_week'] == todayDayOfWeek).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.gradientPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'خطة تغذيتك اليومية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
                if (trainerName != null)
                  Text(
                    'من المدربة: $trainerName',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: 16),

        // عرض الوجبات حسب النوع
        ...mealTypes.map((mealType) {
          final typeMeals = todayTrainerMeals.where((m) => m['meal_type'] == mealType).toList();
          if (typeMeals.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 12),
                child: Row(
                  children: [
                    Icon(mealTypeIcons[mealType], color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      mealTypeNames[mealType] ?? mealType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                  ],
                ),
              ),
              ...typeMeals.map((meal) => _buildTrainerMealCard(meal)),
            ],
          );
        }),

        // إذا لم توجد وجبات لليوم
        if (todayTrainerMeals.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Column(
              children: [
                Icon(Icons.spa, size: 40, color: AppTheme.primary),
                SizedBox(height: 8),
                Text(
                  'يوم راحة من النظام الغذائي',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTrainerMealCard(Map<String, dynamic> meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal['meal_name_ar'] ?? meal['meal_name'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text,
                      ),
                    ),
                    if (meal['description_ar'] != null || meal['description'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          meal['description_ar'] ?? meal['description'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              if (meal['time'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule, size: 14, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        meal['time'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientValueChip('سعرات', '${meal['calories'] ?? 0}', AppTheme.primary),
              _buildNutrientValueChip('بروتين', '${meal['protein'] ?? 0}g', Colors.blue),
              _buildNutrientValueChip('كارب', '${meal['carbs'] ?? 0}g', Colors.orange),
              _buildNutrientValueChip('دهون', '${meal['fats'] ?? 0}g', Colors.purple),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1);
  }

  Widget _buildNutrientValueChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMealsState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.xl),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 40,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.md),
          const Text(
            'لم يتم تحديد خطة غذائية بعد',
            style: TextStyle(
              fontSize: AppTheme.fontLg,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          const Text(
            'تواصلي مع مدربتك لإضافة خطة غذائية مخصصة لك',
            style: TextStyle(
              fontSize: AppTheme.fontSm,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildNutritionTips() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.gradientSoft,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppTheme.warning, size: 24),
              const SizedBox(width: AppTheme.sm),
              const Text(
                'نصائح التغذية اليوم',
                style: TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          _buildTipItem('اشربي 8 أكواب من الماء يومياً', Icons.water_drop),
          const SizedBox(height: AppTheme.sm),
          _buildTipItem('تناولي وجبة خفيفة كل 3-4 ساعات', Icons.schedule),
          const SizedBox(height: AppTheme.sm),
          _buildTipItem('أضيفي الخضروات إلى كل وجبة', Icons.eco),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 600.ms);
  }

  Widget _buildTipItem(String tip, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: AppTheme.sm),
        Expanded(
          child: Text(
            tip,
            style: const TextStyle(
              fontSize: AppTheme.fontSm,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getMealIcon(String category) {
    switch (category) {
      case 'إفطار':
        return Icons.free_breakfast;
      case 'غداء':
        return Icons.lunch_dining;
      case 'عشاء':
        return Icons.dinner_dining;
      case 'سناك':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }
}
