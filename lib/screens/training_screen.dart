import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/live_class.dart';
import '../services/api_service.dart';
import 'class_detail_screen.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with SingleTickerProviderStateMixin {
  String selectedCategory = 'all';
  late AnimationController _pulseController;
  bool _isLoading = true;
  bool _isLoadingTrainerPlan = true;

  // البيانات من API
  List<LiveClass> liveClasses = [];

  // خطة التدريب من المدرب
  List<Map<String, dynamic>> trainerWorkouts = [];
  String? trainerName;

  final List<Category> categories = const [
    Category(id: 'all', title: 'الكل', icon: 'apps'),
    Category(id: 'yoga', title: 'يوغا', icon: 'self_improvement'),
    Category(id: 'cardio', title: 'كارديو', icon: 'directions_run'),
    Category(id: 'strength', title: 'المقاومة', icon: 'fitness_center'),
  ];

  final List<String> dayNames = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadClasses();
    _loadTrainerPlan();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    try {
      final classes = await ApiService.getLiveClasses();
      setState(() {
        liveClasses = classes.map((c) => LiveClass(
          id: c['id']?.toString() ?? '',
          title: c['title'] ?? '',
          instructor: c['instructor'] ?? '',
          time: c['time'] ?? '',
          duration: c['duration'] ?? 0,
          level: c['level'] ?? '',
          participants: c['participants'] ?? 0,
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTrainerPlan() async {
    setState(() => _isLoadingTrainerPlan = true);
    try {
      final result = await ApiService.getMyTrainerWorkouts();
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          trainerWorkouts = List<Map<String, dynamic>>.from(result['data']['workouts'] ?? []);
          trainerName = result['data']['trainer']?['name'];
          _isLoadingTrainerPlan = false;
        });
      } else {
        setState(() => _isLoadingTrainerPlan = false);
      }
    } catch (e) {
      setState(() => _isLoadingTrainerPlan = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadTrainerPlan();
              await _loadClasses();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),

                  // Trainer Workout Plan Section
                  if (!_isLoadingTrainerPlan && trainerWorkouts.isNotEmpty) ...[
                    _buildTrainerPlanSection(),
                    const SizedBox(height: 20),
                  ] else if (_isLoadingTrainerPlan) ...[
                    _buildTrainerPlanLoading(),
                    const SizedBox(height: 20),
                  ] else ...[
                    _buildNoTrainerPlan(),
                    const SizedBox(height: 20),
                  ],

                  // Categories
                  _buildCategories(),

                  // Live Classes Section Title
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.md),
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_pulseController.value * 0.5),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: AppTheme.sm),
                        const Text(
                          'الحصص المباشرة',
                          style: TextStyle(
                            fontSize: AppTheme.fontMd,
                            fontWeight: AppTheme.fontSemibold,
                            color: AppTheme.text,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Live Classes List
                  _buildLiveClassesList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.gradientSoft,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.md,
        vertical: AppTheme.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'تدريبي',
            style: TextStyle(
              fontSize: AppTheme.fontXl,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.text,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              boxShadow: AppTheme.shadowSm,
            ),
            child: const Icon(
              Icons.search,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'خطة تدريبك الأسبوعية',
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
          ),
        ).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
            itemCount: 7,
            itemBuilder: (context, dayIndex) {
              final dayWorkouts = trainerWorkouts.where((w) => w['day_of_week'] == dayIndex).toList();
              final isToday = dayIndex == DateTime.now().weekday % 7;

              return Container(
                width: 140,
                margin: const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  gradient: isToday ? AppTheme.gradientPrimary : null,
                  color: isToday ? null : AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: isToday ? null : Border.all(color: AppTheme.border),
                  boxShadow: isToday ? AppTheme.shadowMd : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dayNames[dayIndex],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isToday ? Colors.white : AppTheme.text,
                            ),
                          ),
                          if (isToday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'اليوم',
                                style: TextStyle(fontSize: 10, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: dayWorkouts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.spa,
                                      size: 24,
                                      color: isToday ? Colors.white.withOpacity(0.5) : AppTheme.textSecondary.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'راحة',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isToday ? Colors.white.withOpacity(0.7) : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: dayWorkouts.length,
                                itemBuilder: (context, workoutIndex) {
                                  final workout = dayWorkouts[workoutIndex];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isToday ? Colors.white.withOpacity(0.2) : AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          workout['workout_name_ar'] ?? workout['workout_name'] ?? '',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isToday ? Colors.white : AppTheme.primary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (workout['duration_minutes'] != null)
                                          Text(
                                            '${workout['duration_minutes']} دقيقة',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isToday ? Colors.white.withOpacity(0.8) : AppTheme.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (dayIndex * 100).ms).slideX(begin: 0.2);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrainerPlanLoading() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'خطة تدريبك الأسبوعية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        ],
      ),
    );
  }

  Widget _buildNoTrainerPlan() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.md),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              size: 48,
              color: AppTheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'لم يتم إضافة خطة تدريب بعد',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'ستظهر خطة التدريب هنا بمجرد أن تضيفها مدربتك',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.md,
          vertical: 6,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category.id;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(left: AppTheme.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconData(category.icon),
                    size: 16,
                    color: isSelected ? AppTheme.white : AppTheme.text,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    category.title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: AppTheme.fontMedium,
                      color: isSelected ? AppTheme.white : AppTheme.text,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).scale(delay: (index * 50).ms);
        },
      ),
    );
  }

  Widget _buildLiveClassesList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (liveClasses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
              const SizedBox(height: AppTheme.md),
              const Text(
                'لا توجد حصص مباشرة حالياً',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: AppTheme.fontMd),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: liveClasses.length,
      itemBuilder: (context, index) {
        final classItem = liveClasses[index];
        return _buildClassCard(classItem, index);
      },
    );
  }

  Widget _buildClassCard(LiveClass classItem, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: AppTheme.shadowGlow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x802D2D40),
                Color(0x803D3D52),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                left: 20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                right: -10,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppTheme.gradientPrimary,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        boxShadow: AppTheme.shadowMd,
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.videocam,
                              size: 28,
                              color: AppTheme.white,
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            left: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.error,
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.circle, size: 4, color: AppTheme.white),
                                  SizedBox(width: 3),
                                  Text(
                                    'LIVE',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: AppTheme.fontBold,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classItem.title,
                            style: const TextStyle(
                              fontSize: AppTheme.fontMd,
                              fontWeight: AppTheme.fontSemibold,
                              color: AppTheme.text,
                            ),
                          ),
                          const SizedBox(height: AppTheme.xs),
                          Text(
                            'المدربة: ${classItem.instructor}',
                            style: const TextStyle(
                              fontSize: AppTheme.fontSm,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppTheme.sm),
                          Row(
                            children: [
                              _buildDetailChip(Icons.schedule, classItem.time),
                              const SizedBox(width: AppTheme.md),
                              _buildDetailChip(Icons.timer, '${classItem.duration} دقيقة'),
                              const SizedBox(width: AppTheme.md),
                              _buildDetailChip(Icons.people, classItem.participants.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.sm),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getLevelColor(classItem.level).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Text(
                            classItem.level,
                            style: const TextStyle(
                              fontSize: AppTheme.fontXs,
                              fontWeight: AppTheme.fontMedium,
                              color: AppTheme.text,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.xs),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.gradientPrimary,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClassDetailScreen(liveClass: classItem),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppTheme.md,
                                  vertical: AppTheme.sm,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'انضمي',
                                      style: TextStyle(
                                        fontSize: AppTheme.fontSm,
                                        fontWeight: AppTheme.fontSemibold,
                                        color: AppTheme.white,
                                      ),
                                    ),
                                    SizedBox(width: AppTheme.xs),
                                    Icon(Icons.arrow_back, size: 16, color: AppTheme.white),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
    ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms).slideY(begin: 0.2, end: 0, duration: 400.ms, delay: (index * 100).ms);
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: AppTheme.xs),
        Text(
          text,
          style: const TextStyle(
            fontSize: AppTheme.fontXs,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'apps':
        return Icons.apps;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'directions_run':
        return Icons.directions_run;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'music_note':
        return Icons.music_note;
      default:
        return Icons.apps;
    }
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'مبتدئ':
        return AppTheme.success;
      case 'متوسط':
        return AppTheme.warning;
      case 'متقدم':
        return AppTheme.error;
      default:
        return AppTheme.primary;
    }
  }
}
