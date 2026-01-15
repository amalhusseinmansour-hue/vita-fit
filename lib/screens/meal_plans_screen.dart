import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class MealPlansScreen extends StatefulWidget {
  const MealPlansScreen({super.key});

  @override
  State<MealPlansScreen> createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  List<dynamic> _meals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMealPlans();
  }

  Future<void> _loadMealPlans() async {
    setState(() => _isLoading = true);
    try {
      final meals = await ApiService.getMeals();
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getTodayMeals() {
    // إرجاع الوجبات من API فقط - بدون بيانات تجريبية
    if (_meals.isEmpty) {
      return [];
    }
    return _meals.map((m) => {
      'type': m['name'] ?? 'وجبة',
      'time': m['time'] ?? '12:00',
      'icon': _getMealIcon(m['name'] ?? ''),
      'color': _getMealColor(m['name'] ?? ''),
      'foods': (m['ingredients'] as List?)?.map((i) => {
        'name': i['name'] ?? '',
        'calories': i['calories'] ?? 0,
      }).toList() ?? [],
      'totalCalories': m['calories'] ?? 0,
      'isCompleted': m['completed'] ?? false,
    }).toList().cast<Map<String, dynamic>>();
  }

  String _getMealIcon(String mealType) {
    if (mealType.contains('إفطار') || mealType.contains('فطور')) return 'wb_sunny';
    if (mealType.contains('غداء')) return 'restaurant';
    if (mealType.contains('عشاء')) return 'nightlight';
    if (mealType.contains('خفيفة') || mealType.contains('سناك')) return 'local_cafe';
    return 'restaurant';
  }

  String _getMealColor(String mealType) {
    if (mealType.contains('إفطار') || mealType.contains('فطور')) return 'warning';
    if (mealType.contains('غداء')) return 'success';
    if (mealType.contains('عشاء')) return 'primary';
    return 'info';
  }

  @override
  Widget build(BuildContext context) {
    final todayMeals = _getTodayMeals();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                pinned: true,
                backgroundColor: AppTheme.surface,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: AppTheme.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'الخطط الغذائية',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: AppTheme.fontLg,
                    fontWeight: AppTheme.fontBold,
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Daily Summary
                      const Text(
                        'ملخص اليوم',
                        style: TextStyle(
                          fontSize: AppTheme.fontXl,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.white,
                        ),
                      ).animate().fadeIn(),
                      const SizedBox(height: AppTheme.md),
                      _buildDailySummary(todayMeals).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: AppTheme.xl),

                      // Today's Meals
                      const Text(
                        'وجبات اليوم',
                        style: TextStyle(
                          fontSize: AppTheme.fontXl,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.white,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: AppTheme.md),

                      // عرض الوجبات أو رسالة فارغة
                      if (todayMeals.isEmpty)
                        _buildEmptyState()
                      else
                        ...todayMeals.asMap().entries.map((entry) {
                          final index = entry.key;
                          final meal = entry.value;
                          return _buildMealCard(
                            mealType: meal['type'],
                            time: meal['time'],
                            icon: _getIconData(meal['icon']),
                            color: _getColorData(meal['color']),
                            foods: List<Map<String, dynamic>>.from(meal['foods']),
                            totalCalories: meal['totalCalories'],
                            isCompleted: meal['isCompleted'],
                            delay: 250 + (index * 50),
                          );
                        }),
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.xl),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.md),
          const Text(
            'لا توجد وجبات',
            style: TextStyle(
              fontSize: AppTheme.fontLg,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          const Text(
            'لم يضع المدرب خطة غذائية لك بعد',
            style: TextStyle(
              fontSize: AppTheme.fontMd,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'restaurant':
        return Icons.restaurant;
      case 'cookie':
        return Icons.cookie;
      case 'nightlight':
        return Icons.nightlight;
      default:
        return Icons.restaurant;
    }
  }

  Color _getColorData(String colorName) {
    switch (colorName) {
      case 'warning':
        return AppTheme.warning;
      case 'info':
        return AppTheme.info;
      case 'success':
        return AppTheme.success;
      case 'primary':
        return AppTheme.primary;
      case 'error':
        return AppTheme.error;
      default:
        return AppTheme.primary;
    }
  }

  Widget _buildDailySummary(List<Map<String, dynamic>> meals) {
    final totalConsumed = meals.where((m) => m['isCompleted'] == true)
        .fold(0, (sum, m) => sum + (m['totalCalories'] as int));
    final totalTarget = meals.fold(0, (sum, m) => sum + (m['totalCalories'] as int));
    final progress = totalTarget > 0 ? totalConsumed / totalTarget : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppTheme.lg),
      decoration: BoxDecoration(
        gradient: AppTheme.gradientPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowLg,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNutrientInfo('سعرة', '$totalConsumed', '$totalTarget', AppTheme.error),
              _buildNutrientInfo('بروتين', '${(totalConsumed * 0.25 / 4).round()}', '${(totalTarget * 0.25 / 4).round()}', AppTheme.success),
              _buildNutrientInfo('كارب', '${(totalConsumed * 0.45 / 4).round()}', '${(totalTarget * 0.45 / 4).round()}', AppTheme.warning),
              _buildNutrientInfo('دهون', '${(totalConsumed * 0.3 / 9).round()}', '${(totalTarget * 0.3 / 9).round()}', AppTheme.info),
            ],
          ),
          const SizedBox(height: AppTheme.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppTheme.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.white),
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          Text(
            'متبقي ${totalTarget - totalConsumed} سعرة حرارية',
            style: const TextStyle(
              fontSize: AppTheme.fontMd,
              color: AppTheme.white,
              fontWeight: AppTheme.fontBold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(
      String label, String current, String target, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontSm,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          current,
          style: TextStyle(
            fontSize: AppTheme.fontXl,
            fontWeight: AppTheme.fontBold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '/ $target',
          style: TextStyle(
            fontSize: AppTheme.fontXs,
            color: AppTheme.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard({
    required String mealType,
    required String time,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> foods,
    required int totalCalories,
    required bool isCompleted,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isCompleted
              ? AppTheme.success.withValues(alpha: 0.3)
              : AppTheme.border,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(AppTheme.md),
          childrenPadding: const EdgeInsets.only(
            right: AppTheme.md,
            left: AppTheme.md,
            bottom: AppTheme.md,
          ),
          leading: Container(
            padding: const EdgeInsets.all(AppTheme.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          title: Text(
            mealType,
            style: const TextStyle(
              fontSize: AppTheme.fontLg,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.white,
            ),
          ),
          subtitle: Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 14,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                time,
                style: const TextStyle(
                  fontSize: AppTheme.fontSm,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: AppTheme.md),
              const Icon(
                Icons.local_fire_department,
                size: 14,
                color: AppTheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                '$totalCalories سعرة',
                style: const TextStyle(
                  fontSize: AppTheme.fontSm,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          trailing: isCompleted
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.sm,
                    vertical: AppTheme.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: AppTheme.success),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.success,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'تم',
                        style: TextStyle(
                          fontSize: AppTheme.fontXs,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                )
              : const Icon(
                  Icons.expand_more,
                  color: AppTheme.textSecondary,
                ),
          children: [
            ...foods.map(
              (food) => Container(
                margin: const EdgeInsets.only(bottom: AppTheme.sm),
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.restaurant,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.sm),
                    Expanded(
                      child: Text(
                        food['name'],
                        style: const TextStyle(
                          fontSize: AppTheme.fontMd,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.sm,
                        vertical: AppTheme.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        '${food['calories']} سعرة',
                        style: const TextStyle(
                          fontSize: AppTheme.fontXs,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isCompleted)
              const SizedBox(height: AppTheme.sm),
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding:
                        const EdgeInsets.symmetric(vertical: AppTheme.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: const Text(
                    'تسجيل الوجبة',
                    style: TextStyle(
                      fontSize: AppTheme.fontMd,
                      fontWeight: AppTheme.fontBold,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
        );
  }

  Widget _buildSuggestedPlan({
    required String title,
    required String description,
    required int meals,
    required String duration,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.md),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientPrimary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: AppTheme.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: AppTheme.fontLg,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSm,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.sm),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.sm,
                              vertical: AppTheme.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              '$meals وجبات',
                              style: const TextStyle(
                                fontSize: AppTheme.fontXs,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.sm,
                              vertical: AppTheme.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.info.withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              duration,
                              style: const TextStyle(
                                fontSize: AppTheme.fontXs,
                                color: AppTheme.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
        );
  }
}
