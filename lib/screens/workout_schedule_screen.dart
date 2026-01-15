import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class WorkoutScheduleScreen extends StatefulWidget {
  const WorkoutScheduleScreen({super.key});

  @override
  State<WorkoutScheduleScreen> createState() => _WorkoutScheduleScreenState();
}

class _WorkoutScheduleScreenState extends State<WorkoutScheduleScreen> {
  List<dynamic> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final workouts = await ApiService.getWorkouts();
      setState(() {
        _workouts = workouts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getWeekSchedule() {
    final days = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
    final weekSchedule = <Map<String, dynamic>>[];

    for (int i = 0; i < days.length; i++) {
      final dayWorkouts = _workouts.where((w) {
        final date = DateTime.tryParse(w['date'] ?? '');
        if (date == null) return false;
        return date.weekday == ((i + 6) % 7 + 1);
      }).toList();

      // استخدام البيانات من المدرب فقط - بدون بيانات افتراضية
      weekSchedule.add({
        'day': days[i],
        'workouts': dayWorkouts.map((w) => {
          'name': w['name'] ?? 'تمرين',
          'duration': '${w['duration'] ?? 45} دقيقة',
          'done': w['completed'] == true,
        }).toList(),
        'isRestDay': dayWorkouts.isEmpty,
      });
    }

    return weekSchedule;
  }

  // حساب التقدم الفعلي
  Map<String, dynamic> _getProgress() {
    if (_workouts.isEmpty) {
      return {'completed': 0, 'total': 0, 'percentage': 0.0};
    }
    final total = _workouts.length;
    final completed = _workouts.where((w) => w['completed'] == true).length;
    final percentage = total > 0 ? completed / total : 0.0;
    return {'completed': completed, 'total': total, 'percentage': percentage};
  }

  @override
  Widget build(BuildContext context) {
    final weekSchedule = _getWeekSchedule();
    final progress = _getProgress();

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
                        'جدول التمارين',
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
                            const Text(
                              'الأسبوع الحالي',
                              style: TextStyle(
                                fontSize: AppTheme.fontXl,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.white,
                              ),
                            ).animate().fadeIn(),
                            const SizedBox(height: AppTheme.md),
                            _buildWeekProgress(progress).animate().fadeIn(delay: 100.ms),
                            const SizedBox(height: AppTheme.xl),
                            const Text(
                              'جدول التمارين الأسبوعي',
                              style: TextStyle(
                                fontSize: AppTheme.fontXl,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.white,
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                            const SizedBox(height: AppTheme.md),
                            ...weekSchedule.asMap().entries.map((entry) {
                              final index = entry.key;
                              final schedule = entry.value;
                              return _buildDayWorkout(
                                day: schedule['day'],
                                workouts: List<Map<String, dynamic>>.from(schedule['workouts']),
                                delay: 250 + (index * 50),
                                isRestDay: schedule['isRestDay'] ?? false,
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

  Widget _buildWeekProgress(Map<String, dynamic> progress) {
    final completed = progress['completed'] as int;
    final total = progress['total'] as int;
    final percentage = progress['percentage'] as double;
    final percentageText = (percentage * 100).toStringAsFixed(0);

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'التقدم الأسبوعي',
                    style: TextStyle(
                      fontSize: AppTheme.fontLg,
                      fontWeight: AppTheme.fontBold,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total > 0 ? '$completed من $total تمرين' : 'لا توجد تمارين',
                    style: const TextStyle(
                      fontSize: AppTheme.fontMd,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  color: AppTheme.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$percentageText%',
                  style: const TextStyle(
                    fontSize: AppTheme.fontLg,
                    fontWeight: AppTheme.fontBold,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: AppTheme.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayWorkout({
    required String day,
    required List<Map<String, dynamic>> workouts,
    required int delay,
    bool isRestDay = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isRestDay
              ? AppTheme.warning.withValues(alpha: 0.3)
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
              color: isRestDay
                  ? AppTheme.warning.withValues(alpha: 0.2)
                  : AppTheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              isRestDay ? Icons.hotel : Icons.fitness_center,
              color: isRestDay ? AppTheme.warning : AppTheme.primary,
              size: 24,
            ),
          ),
          title: Text(
            day,
            style: const TextStyle(
              fontSize: AppTheme.fontLg,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.white,
            ),
          ),
          subtitle: Text(
            isRestDay ? 'لا توجد تمارين' : '${workouts.length} ${workouts.length == 1 ? 'تمرين' : 'تمارين'}',
            style: TextStyle(
              fontSize: AppTheme.fontSm,
              color: isRestDay ? AppTheme.warning : AppTheme.textSecondary,
            ),
          ),
          trailing: isRestDay
              ? const Icon(Icons.remove_circle_outline, color: AppTheme.warning)
              : (workouts.isNotEmpty && workouts.where((w) => w['done'] == true).length == workouts.length)
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
                            'مكتمل',
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
          children: isRestDay
              ? [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.lg),
                    child: const Center(
                      child: Text(
                        'لم يضع المدرب تمارين لهذا اليوم',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.fontMd,
                        ),
                      ),
                    ),
                  ),
                ]
              : workouts.map(
                (workout) => Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.sm),
                  padding: const EdgeInsets.all(AppTheme.md),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: workout['done']
                          ? AppTheme.success.withValues(alpha: 0.3)
                          : AppTheme.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: workout['done'],
                        onChanged: (value) {},
                        activeColor: AppTheme.success,
                        shape: const CircleBorder(),
                      ),
                      const SizedBox(width: AppTheme.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout['name'],
                              style: TextStyle(
                                fontSize: AppTheme.fontMd,
                                fontWeight: AppTheme.fontSemibold,
                                color: workout['done']
                                    ? AppTheme.textSecondary
                                    : AppTheme.white,
                                decoration: workout['done']
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer,
                                  color: AppTheme.textSecondary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  workout['duration'],
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontSm,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (!workout['done'])
                        IconButton(
                          icon: const Icon(
                            Icons.play_circle_filled,
                            color: AppTheme.primary,
                          ),
                          onPressed: () {},
                        ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
        );
  }
}
