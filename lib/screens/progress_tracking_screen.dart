import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  Map<String, dynamic> _stats = {};
  List<dynamic> _weightHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final stats = await ApiService.getProgressStats();
      final weightHistory = await ApiService.getWeightHistory();

      setState(() {
        _stats = stats;
        _weightHistory = weightHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('تتبع التقدم', style: TextStyle(color: AppTheme.white)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    // استخراج البيانات من _stats (بدون قيم افتراضية وهمية)
    final currentWeight = _stats['currentWeight']?.toDouble() ?? 0.0;
    final targetWeight = _stats['targetWeight']?.toDouble() ?? 0.0;
    final startWeight = _stats['startWeight']?.toDouble() ?? 0.0;
    final weightLost = _stats['weightLost']?.toDouble() ?? 0.0;
    final caloriesBurned = _stats['caloriesBurned'] ?? 0;
    final workoutsCompleted = _stats['workoutsCompleted'] ?? 0;
    final totalWorkoutMinutes = _stats['totalWorkoutMinutes'] ?? 0;
    final streakDays = _stats['streakDays'] ?? 0;
    final currentBodyFat = _stats['currentBodyFat']?.toDouble() ?? 0.0;
    final startBodyFat = _stats['startBodyFat']?.toDouble() ?? 0.0;
    final currentMuscleMass = _stats['currentMuscleMass']?.toDouble() ?? 0.0;
    final startMuscleMass = _stats['startMuscleMass']?.toDouble() ?? 0.0;

    // قياسات الجسم من الـ API
    final waistCurrent = _stats['waistCurrent']?.toString() ?? '0';
    final waistPrevious = _stats['waistPrevious']?.toString() ?? '0';
    final chestCurrent = _stats['chestCurrent']?.toString() ?? '0';
    final chestPrevious = _stats['chestPrevious']?.toString() ?? '0';
    final armCurrent = _stats['armCurrent']?.toString() ?? '0';
    final armPrevious = _stats['armPrevious']?.toString() ?? '0';
    final thighCurrent = _stats['thighCurrent']?.toString() ?? '0';
    final thighPrevious = _stats['thighPrevious']?.toString() ?? '0';

    final hasData = _stats.isNotEmpty;

    final weightRemaining = currentWeight - targetWeight;
    final weightProgress = (startWeight - currentWeight) / (startWeight - targetWeight);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.primary,
            child: CustomScrollView(
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
                    'تتبع التقدم',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: AppTheme.fontLg,
                      fontWeight: AppTheme.fontBold,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add, color: AppTheme.primary),
                      onPressed: () => _showAddMeasurementDialog(),
                    ),
                  ],
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Overview Cards
                        const Text(
                          'نظرة عامة',
                          style: TextStyle(
                            fontSize: AppTheme.fontXl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.white,
                          ),
                        ).animate().fadeIn(),
                        const SizedBox(height: AppTheme.md),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.local_fire_department,
                                title: 'السعرات المحروقة',
                                value: _formatNumber(caloriesBurned),
                                unit: 'كالوري',
                                color: AppTheme.error,
                                delay: 100,
                              ),
                            ),
                            const SizedBox(width: AppTheme.md),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.fitness_center,
                                title: 'التمارين',
                                value: workoutsCompleted.toString(),
                                unit: 'تمرين',
                                color: AppTheme.primary,
                                delay: 150,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.md),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.timer,
                                title: 'وقت التمرين',
                                value: (totalWorkoutMinutes / 60).toStringAsFixed(0),
                                unit: 'ساعة',
                                color: AppTheme.warning,
                                delay: 200,
                              ),
                            ),
                            const SizedBox(width: AppTheme.md),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.trending_down,
                                title: 'فقدان الوزن',
                                value: weightLost.toStringAsFixed(1),
                                unit: 'كجم',
                                color: AppTheme.success,
                                delay: 250,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.md),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.whatshot,
                                title: 'سلسلة الأيام',
                                value: streakDays.toString(),
                                unit: 'يوم',
                                color: Colors.orange,
                                delay: 275,
                              ),
                            ),
                            const SizedBox(width: AppTheme.md),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.percent,
                                title: 'نسبة الدهون',
                                value: currentBodyFat.toStringAsFixed(1),
                                unit: '%',
                                color: AppTheme.info,
                                delay: 300,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.xl),

                        // Weight Progress
                        const Text(
                          'تطور الوزن',
                          style: TextStyle(
                            fontSize: AppTheme.fontXl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.white,
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                        const SizedBox(height: AppTheme.md),
                        _buildWeightProgress(
                          currentWeight: currentWeight,
                          targetWeight: targetWeight,
                          progress: weightProgress.clamp(0.0, 1.0),
                          remaining: weightRemaining,
                        ).animate().fadeIn(delay: 350.ms),
                        const SizedBox(height: AppTheme.xl),

                        // Weight History Chart
                        if (_weightHistory.isNotEmpty) ...[
                          const Text(
                            'سجل الوزن',
                            style: TextStyle(
                              fontSize: AppTheme.fontXl,
                              fontWeight: AppTheme.fontBold,
                              color: AppTheme.white,
                            ),
                          ).animate().fadeIn(delay: 375.ms),
                          const SizedBox(height: AppTheme.md),
                          _buildWeightChart().animate().fadeIn(delay: 400.ms),
                          const SizedBox(height: AppTheme.xl),
                        ],

                        // Body Measurements
                        const Text(
                          'قياسات الجسم',
                          style: TextStyle(
                            fontSize: AppTheme.fontXl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.white,
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                        const SizedBox(height: AppTheme.md),
                        _buildMeasurement(
                          icon: Icons.straighten,
                          title: 'الخصر',
                          current: waistCurrent,
                          previous: waistPrevious,
                          unit: 'سم',
                          delay: 450,
                        ),
                        _buildMeasurement(
                          icon: Icons.accessibility_new,
                          title: 'الصدر',
                          current: chestCurrent,
                          previous: chestPrevious,
                          unit: 'سم',
                          delay: 500,
                        ),
                        _buildMeasurement(
                          icon: Icons.fitness_center,
                          title: 'الذراع',
                          current: armCurrent,
                          previous: armPrevious,
                          unit: 'سم',
                          delay: 550,
                        ),
                        _buildMeasurement(
                          icon: Icons.accessibility,
                          title: 'الفخذ',
                          current: thighCurrent,
                          previous: thighPrevious,
                          unit: 'سم',
                          delay: 600,
                        ),
                        _buildMeasurement(
                          icon: Icons.percent,
                          title: 'نسبة الدهون',
                          current: currentBodyFat.toStringAsFixed(1),
                          previous: startBodyFat.toStringAsFixed(1),
                          unit: '%',
                          delay: 625,
                        ),
                        _buildMeasurement(
                          icon: Icons.fitness_center,
                          title: 'الكتلة العضلية',
                          current: currentMuscleMass.toStringAsFixed(1),
                          previous: startMuscleMass.toStringAsFixed(1),
                          unit: 'كجم',
                          delay: 650,
                          isIncreaseBetter: true,
                        ),
                        const SizedBox(height: AppTheme.xl),

                        // Weekly Activity
                        const Text(
                          'النشاط الأسبوعي',
                          style: TextStyle(
                            fontSize: AppTheme.fontXl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.white,
                          ),
                        ).animate().fadeIn(delay: 650.ms),
                        const SizedBox(height: AppTheme.md),
                        _buildWeeklyActivity().animate().fadeIn(delay: 700.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  void _showAddMeasurementDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: const Text(
            'إضافة قياس جديد',
            style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.white),
                decoration: InputDecoration(
                  labelText: 'الوزن (كجم)',
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.md),
              TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.white),
                decoration: InputDecoration(
                  labelText: 'محيط الخصر (سم)',
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حفظ القياس بنجاح'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('حفظ', style: TextStyle(color: AppTheme.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: AppTheme.md),
          Text(
            title,
            style: const TextStyle(
              fontSize: AppTheme.fontSm,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: AppTheme.fontXl,
                  fontWeight: AppTheme.fontBold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSm,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
        );
  }

  Widget _buildWeightProgress({
    required double currentWeight,
    required double targetWeight,
    required double progress,
    required double remaining,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الوزن الحالي',
                    style: TextStyle(
                      fontSize: AppTheme.fontSm,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currentWeight.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          'كجم',
                          style: TextStyle(
                            fontSize: AppTheme.fontMd,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'الهدف',
                    style: TextStyle(
                      fontSize: AppTheme.fontSm,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        targetWeight.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.success,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          'كجم',
                          style: TextStyle(
                            fontSize: AppTheme.fontMd,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% مكتمل',
                style: const TextStyle(
                  fontSize: AppTheme.fontSm,
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'متبقي ${remaining.toStringAsFixed(1)} كجم',
                style: const TextStyle(
                  fontSize: AppTheme.fontSm,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart() {
    // Get min and max weights for scaling
    double minWeight = double.infinity;
    double maxWeight = double.negativeInfinity;

    for (var entry in _weightHistory) {
      final weight = (entry['weight'] as num).toDouble();
      if (weight < minWeight) minWeight = weight;
      if (weight > maxWeight) maxWeight = weight;
    }

    final range = maxWeight - minWeight;
    final padding = range * 0.1;
    minWeight -= padding;
    maxWeight += padding;

    return Container(
      padding: const EdgeInsets.all(AppTheme.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weightHistory.asMap().entries.map((entry) {
                final index = entry.key;
                final weight = (entry.value['weight'] as num).toDouble();
                final normalizedHeight = ((weight - minWeight) / (maxWeight - minWeight)) * 120;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          weight.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: normalizedHeight.clamp(20.0, 120.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primary,
                                AppTheme.primary.withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          Text(
            'آخر ${_weightHistory.length} قياسات',
            style: const TextStyle(
              fontSize: AppTheme.fontSm,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurement({
    required IconData icon,
    required String title,
    required String current,
    required String previous,
    required String unit,
    required int delay,
    bool isIncreaseBetter = false,
  }) {
    final currentNum = double.tryParse(current) ?? 0;
    final previousNum = double.tryParse(previous) ?? 0;
    final difference = currentNum - previousNum;
    final isPositive = difference > 0;
    final isGood = isIncreaseBetter ? isPositive : !isPositive;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.sm),
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.sm),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 24,
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
                    fontSize: AppTheme.fontMd,
                    fontWeight: AppTheme.fontSemibold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'السابق: $previous $unit',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSm,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$current $unit',
                style: const TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 4),
              if (difference != 0)
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isGood ? AppTheme.success : AppTheme.error,
                      size: 16,
                    ),
                    Text(
                      '${difference.abs().toStringAsFixed(1)} $unit',
                      style: TextStyle(
                        fontSize: AppTheme.fontSm,
                        fontWeight: AppTheme.fontBold,
                        color: isGood ? AppTheme.success : AppTheme.error,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
        );
  }

  Widget _buildWeeklyActivity() {
    final days = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
    // استخدام البيانات من الـ API أو قيم فارغة
    final weeklyData = _stats['weeklyActivity'] as List<dynamic>? ?? [];
    final activities = weeklyData.isNotEmpty
        ? weeklyData.map((e) => (e as num).toDouble()).toList()
        : List.filled(7, 0.0);

    return Container(
      padding: const EdgeInsets.all(AppTheme.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        height: 120 * activities[index],
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primary,
                              AppTheme.primary.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                      ),
                      const SizedBox(height: AppTheme.sm),
                      Text(
                        days[index].substring(0, 2),
                        style: const TextStyle(
                          fontSize: AppTheme.fontXs,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppTheme.lg),
          Text(
            weeklyData.isNotEmpty
                ? 'معدل النشاط: ${((activities.reduce((a, b) => a + b) / 7) * 100).toStringAsFixed(0)}% من الهدف اليومي'
                : 'لا توجد بيانات نشاط',
            style: const TextStyle(
              fontSize: AppTheme.fontSm,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
