import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/meal.dart';

class MealDetailScreen extends StatefulWidget {
  final Meal meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  bool isFavorite = false;
  int servings = 1;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar مع الصورة
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.gradientPrimary,
                      ),
                      child: Center(
                        child: Icon(
                          _getMealIcon(widget.meal.name),
                          size: 120,
                          color: AppTheme.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    // Overlay gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.background.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                    // معلومات الوقت
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.card.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.meal.time,
                              style: const TextStyle(
                                fontSize: AppTheme.fontMd,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.background.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: AppTheme.text),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.background.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: isFavorite ? AppTheme.primary : AppTheme.text,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                ),
              ],
            ),

            // المحتوى
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.meal.name,
                            style: const TextStyle(
                              fontSize: AppTheme.fontXxl,
                              fontWeight: AppTheme.fontBold,
                              color: AppTheme.text,
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.md,
                            vertical: AppTheme.sm,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.gradientSoft,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            widget.meal.type,
                            style: const TextStyle(
                              fontSize: AppTheme.fontSm,
                              fontWeight: AppTheme.fontBold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.xl),

                    // المعلومات الغذائية
                    const Text(
                      'القيم الغذائية',
                      style: TextStyle(
                        fontSize: AppTheme.fontLg,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),

                    // السعرات الحرارية الكبيرة
                    Container(
                      padding: const EdgeInsets.all(AppTheme.lg),
                      decoration: BoxDecoration(
                        gradient: AppTheme.gradientPrimary,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        boxShadow: AppTheme.shadowMd,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إجمالي السعرات',
                                style: TextStyle(
                                  fontSize: AppTheme.fontMd,
                                  color: AppTheme.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'لكل حصة',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSm,
                                  color: AppTheme.white,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${widget.meal.calories * servings}',
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: AppTheme.fontBold,
                                  color: AppTheme.white,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  ' كالوري',
                                  style: TextStyle(
                                    fontSize: AppTheme.fontLg,
                                    color: AppTheme.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).scale(
                          begin: const Offset(0.9, 0.9),
                          delay: 200.ms,
                        ),
                    const SizedBox(height: AppTheme.md),

                    // الماكروز
                    Row(
                      children: [
                        Expanded(
                          child: _buildMacroCard(
                            label: 'بروتين',
                            value: '${widget.meal.protein * servings}g',
                            icon: Icons.egg,
                            color: AppTheme.primary,
                            delay: 0,
                          ),
                        ),
                        const SizedBox(width: AppTheme.sm),
                        Expanded(
                          child: _buildMacroCard(
                            label: 'كربوهيدرات',
                            value: '${widget.meal.carbs * servings}g',
                            icon: Icons.grain,
                            color: AppTheme.warning,
                            delay: 100,
                          ),
                        ),
                        const SizedBox(width: AppTheme.sm),
                        Expanded(
                          child: _buildMacroCard(
                            label: 'دهون',
                            value: '${widget.meal.fats * servings}g',
                            icon: Icons.water_drop,
                            color: AppTheme.info,
                            delay: 200,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.xl),

                    // عدد الحصص
                    const Text(
                      'عدد الحصص',
                      style: TextStyle(
                        fontSize: AppTheme.fontLg,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: servings > 1
                                ? () {
                                    setState(() {
                                      servings--;
                                    });
                                  }
                                : null,
                            color: AppTheme.primary,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.lg,
                            ),
                            child: Text(
                              '$servings',
                              style: const TextStyle(
                                fontSize: AppTheme.fontXl,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.text,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: servings < 10
                                ? () {
                                    setState(() {
                                      servings++;
                                    });
                                  }
                                : null,
                            color: AppTheme.primary,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: AppTheme.xl),

                    // المكونات
                    const Text(
                      'المكونات',
                      style: TextStyle(
                        fontSize: AppTheme.fontLg,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                    ..._getIngredients(widget.meal.name)
                        .asMap()
                        .entries
                        .map(
                          (entry) => _buildIngredientItem(
                            entry.value,
                            entry.key,
                          ),
                        ),
                    const SizedBox(height: AppTheme.xl),

                    // طريقة التحضير
                    const Text(
                      'طريقة التحضير',
                      style: TextStyle(
                        fontSize: AppTheme.fontLg,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                    ..._getPreparationSteps(widget.meal.name)
                        .asMap()
                        .entries
                        .map(
                          (entry) => _buildPreparationStep(
                            entry.value,
                            entry.key + 1,
                          ),
                        ),
                    const SizedBox(height: AppTheme.xl),

                    // نصائح
                    Container(
                      padding: const EdgeInsets.all(AppTheme.lg),
                      decoration: BoxDecoration(
                        color: AppTheme.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(
                          color: AppTheme.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.info,
                            size: 24,
                          ),
                          const SizedBox(width: AppTheme.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'نصيحة',
                                  style: TextStyle(
                                    fontSize: AppTheme.fontMd,
                                    fontWeight: AppTheme.fontBold,
                                    color: AppTheme.info,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.xs),
                                Text(
                                  _getTip(widget.meal.name),
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontMd,
                                    color: AppTheme.text,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        // زر إضافة للخطة الغذائية
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(AppTheme.lg),
          decoration: BoxDecoration(
            color: AppTheme.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.gradientPrimary,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                boxShadow: AppTheme.shadowMd,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تمت إضافة ${widget.meal.name} للخطة الغذائية'),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle,
                          color: AppTheme.white,
                        ),
                        SizedBox(width: AppTheme.sm),
                        Text(
                          'أضف للخطة الغذائية',
                          style: TextStyle(
                            fontSize: AppTheme.fontLg,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(
                  begin: 1,
                  end: 0,
                  duration: 600.ms,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacroCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: AppTheme.sm),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.fontXs,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTheme.fontMd,
              fontWeight: AppTheme.fontBold,
              color: color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (300 + delay).ms).scale(
          begin: const Offset(0.8, 0.8),
          delay: (300 + delay).ms,
        );
  }

  Widget _buildIngredientItem(String ingredient, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.sm),
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.gradientSoft,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Text(
              ingredient,
              style: const TextStyle(
                fontSize: AppTheme.fontMd,
                color: AppTheme.text,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (500 + index * 50).ms).slideX(
          begin: 0.2,
          end: 0,
          delay: (500 + index * 50).ms,
        );
  }

  Widget _buildPreparationStep(String step, int stepNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppTheme.gradientPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  fontSize: AppTheme.fontMd,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Text(
              step,
              style: const TextStyle(
                fontSize: AppTheme.fontMd,
                color: AppTheme.text,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (600 + stepNumber * 50).ms);
  }

  IconData _getMealIcon(String mealName) {
    if (mealName.contains('شوفان') || mealName.contains('إفطار')) {
      return Icons.breakfast_dining;
    } else if (mealName.contains('سلطة')) {
      return Icons.lunch_dining;
    } else if (mealName.contains('سناك') || mealName.contains('بروتين')) {
      return Icons.cookie;
    } else if (mealName.contains('سمك') || mealName.contains('عشاء')) {
      return Icons.dinner_dining;
    }
    return Icons.restaurant;
  }

  List<String> _getIngredients(String mealName) {
    if (mealName.contains('شوفان')) {
      return [
        '½ كوب شوفان',
        '1 كوب حليب لوز',
        '½ كوب توت مشكل',
        '1 ملعقة عسل',
        'رشة قرفة',
      ];
    } else if (mealName.contains('سلطة دجاج')) {
      return [
        '100g صدر دجاج مشوي',
        '2 كوب خضار مشكلة',
        '¼ كوب جبنة فيتا',
        '1 ملعقة زيت زيتون',
        'عصير ليمون',
      ];
    } else if (mealName.contains('بروتين')) {
      return [
        '1 حبة تفاح',
        '2 ملعقة زبدة لوز',
        '1 سكوب بروتين',
        'رشة قرفة',
      ];
    } else if (mealName.contains('سمك')) {
      return [
        '150g سمك سلمون',
        '1 كوب أرز بني',
        '1 كوب بروكلي',
        'ليمون وأعشاب',
      ];
    }
    return ['مكونات متنوعة'];
  }

  List<String> _getPreparationSteps(String mealName) {
    if (mealName.contains('شوفان')) {
      return [
        'اخلطي الشوفان مع الحليب في وعاء',
        'سخني على نار متوسطة لمدة 5 دقائق مع التحريك المستمر',
        'أضيفي التوت والعسل والقرفة',
        'قدمي ساخناً واستمتعي',
      ];
    } else if (mealName.contains('سلطة دجاج')) {
      return [
        'اشوي صدر الدجاج وقطعيه إلى شرائح',
        'اخلطي الخضار في وعاء كبير',
        'أضيفي الدجاج والجبنة الفيتا',
        'تبلي بزيت الزيتون وعصير الليمون',
      ];
    } else if (mealName.contains('بروتين')) {
      return [
        'قطعي التفاح إلى شرائح',
        'امزجي زبدة اللوز مع البروتين',
        'وزعي المزيج على شرائح التفاح',
        'رشي القرفة للنكهة',
      ];
    } else if (mealName.contains('سمك')) {
      return [
        'تبلي السمك بالليمون والأعشاب',
        'اشوي السمك في الفرن لمدة 15 دقيقة',
        'اطهي الأرز والبروكلي بالبخار',
        'قدمي جميع المكونات معاً',
      ];
    }
    return ['اتبعي تعليمات التحضير'];
  }

  String _getTip(String mealName) {
    if (mealName.contains('شوفان')) {
      return 'يمكنك تحضير الشوفان مسبقاً وحفظه في الثلاجة لمدة تصل إلى 3 أيام. أضيفي المكسرات للحصول على المزيد من البروتين!';
    } else if (mealName.contains('سلطة دجاج')) {
      return 'لتوفير الوقت، حضري كمية كبيرة من الدجاج المشوي في بداية الأسبوع واستخدميها في عدة وجبات.';
    } else if (mealName.contains('بروتين')) {
      return 'هذه السناك مثالية بعد التمرين! يمكنك استبدال التفاح بالموز للحصول على طاقة إضافية.';
    } else if (mealName.contains('سمك')) {
      return 'السلمون غني بالأوميغا 3 المفيدة للقلب والدماغ. تناوليه 2-3 مرات أسبوعياً للحصول على أفضل النتائج.';
    }
    return 'تناولي وجباتك ببطء واستمتعي بكل لقمة. الأكل الواعي يساعد على الهضم والشبع!';
  }
}
