import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/trainer.dart';
import '../models/workshop.dart';
import '../services/api_service.dart';
import 'online_sessions_screen.dart';
import 'profile_screen.dart';
import 'progress_tracking_screen.dart';
import 'nutrition_screen.dart';
import 'shop_screen.dart';
import 'training_screen.dart';
import 'subscription_screen.dart';
import 'help_center_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartController;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  double? _bmiResult;
  String _bmiCategory = '';
  double? _bmrResult;
  double? _tdeeResult;
  String _selectedGender = 'female';
  String _selectedActivity = 'moderate';

  // User stats from API
  Map<String, dynamic> _userStats = {};
  bool _isLoadingStats = true;

  // User profile
  String _userName = '';
  Map<String, dynamic>? _myTrainer;

  // الحصص والمدربين والورش من API
  List<Map<String, dynamic>> _classes = [];
  List<Trainer> _trainers = [];
  List<Workshop> _workshops = [];

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    try {
      // تحميل بيانات المستخدم
      final profile = await ApiService.getProfile();
      final stats = await ApiService.getProgressStats();
      final classes = await ApiService.getClasses();
      final trainers = await ApiService.getTrainers();
      final workshops = await ApiService.getWorkshops();

      // البحث عن مدرب المستخدم
      Map<String, dynamic>? assignedTrainer;
      final trainerId = profile['trainer_id'] ?? profile['trainerId'];
      if (trainerId != null && trainers.isNotEmpty) {
        assignedTrainer = trainers.firstWhere(
          (t) => t['_id']?.toString() == trainerId.toString() || t['id']?.toString() == trainerId.toString(),
          orElse: () => <String, dynamic>{},
        );
        if (assignedTrainer != null && assignedTrainer.isEmpty) assignedTrainer = null;
      }

      // إذا لم يوجد مدرب معين، نعرض أول مدرب متاح
      if (assignedTrainer == null && trainers.isNotEmpty) {
        assignedTrainer = trainers.first;
      }

      if (mounted) {
        setState(() {
          _userName = profile['name'] ?? profile['full_name'] ?? '';
          _myTrainer = assignedTrainer;
          _userStats = stats;
          _classes = List<Map<String, dynamic>>.from(classes);
          _trainers = trainers.map((t) => Trainer(
            id: t['_id']?.toString() ?? '',
            name: t['name'] ?? '',
            specialty: t['specialty'] ?? '',
            image: t['image'] ?? t['imageUrl'] ?? '',
            rating: (t['rating'] ?? 0.0).toDouble(),
            experience: t['experience'] ?? t['yearsOfExperience'] ?? 0,
            clients: t['clients'] ?? 0,
            description: t['description'] ?? '',
          )).toList();
          _workshops = workshops.map((w) => Workshop(
            id: w['_id']?.toString() ?? '',
            title: w['title'] ?? '',
            description: w['description'] ?? '',
            instructor: w['instructor'] ?? '',
            image: w['image'] ?? w['imageUrl'] ?? '',
            date: DateTime.tryParse(w['date'] ?? '') ?? DateTime.now(),
            time: w['time'] ?? '',
            duration: w['duration'] is int ? w['duration'] : (int.tryParse(w['duration']?.toString() ?? '0') ?? 0),
            capacity: w['capacity'] ?? w['maxParticipants'] ?? 0,
            enrolled: w['enrolled'] ?? w['currentParticipants'] ?? 0,
            price: (w['price'] ?? 0.0).toDouble(),
            level: w['level'] ?? 'مبتدئ',
            location: w['location'] ?? '',
          )).toList();
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight != null && height != null && height > 0) {
      final heightInMeters = height / 100; // تحويل من سم إلى متر
      final bmi = weight / (heightInMeters * heightInMeters);

      setState(() {
        _bmiResult = bmi;

        // تحديد فئة الوزن
        if (bmi < 18.5) {
          _bmiCategory = 'نقص في الوزن';
        } else if (bmi < 25) {
          _bmiCategory = 'وزن طبيعي';
        } else if (bmi < 30) {
          _bmiCategory = 'زيادة في الوزن';
        } else {
          _bmiCategory = 'سمنة';
        }
      });
    }
  }

  // حساب معدل الأيض الأساسي (BMR) والسعرات اليومية (TDEE)
  void _calculateBMR() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final age = int.tryParse(_ageController.text);

    if (weight != null && height != null && age != null && height > 0 && age > 0) {
      double bmr;

      // معادلة Mifflin-St Jeor (الأكثر دقة)
      if (_selectedGender == 'female') {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
      } else {
        bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
      }

      // حساب TDEE بناءً على مستوى النشاط
      double activityMultiplier;
      switch (_selectedActivity) {
        case 'sedentary':
          activityMultiplier = 1.2; // قليل الحركة
          break;
        case 'light':
          activityMultiplier = 1.375; // نشاط خفيف 1-3 أيام/أسبوع
          break;
        case 'moderate':
          activityMultiplier = 1.55; // نشاط معتدل 3-5 أيام/أسبوع
          break;
        case 'active':
          activityMultiplier = 1.725; // نشاط عالي 6-7 أيام/أسبوع
          break;
        case 'very_active':
          activityMultiplier = 1.9; // نشاط مكثف + عمل بدني
          break;
        default:
          activityMultiplier = 1.55;
      }

      setState(() {
        _bmrResult = bmr;
        _tdeeResult = bmr * activityMultiplier;
      });
    }
  }

  Color _getBMIColor() {
    if (_bmiResult == null) return AppTheme.primary;
    if (_bmiResult! < 18.5) return Colors.blue;
    if (_bmiResult! < 25) return Colors.green;
    if (_bmiResult! < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                _buildHeader(),

                // Quick Stats
                _buildQuickStats(),

                const SizedBox(height: AppTheme.lg),

                // My Trainer Section
                _buildMyTrainerSection(),

                const SizedBox(height: AppTheme.lg),

                // BMI Calculator
                _buildBMICalculator(),

                const SizedBox(height: AppTheme.lg),

                // BMR Calculator (معدل الأيض)
                _buildBMRCalculator(),

                const SizedBox(height: AppTheme.lg),

                // Weekly Progress
                _buildWeeklyProgress(),

                const SizedBox(height: AppTheme.lg),

                // Today's Workout
                _buildTodayWorkout(),

                const SizedBox(height: AppTheme.lg),

                // Popular Classes
                _buildPopularClasses(),

                const SizedBox(height: AppTheme.lg),

                // Top Trainers
                _buildTopTrainers(),

                const SizedBox(height: AppTheme.lg),

                // Upcoming Workshops
                _buildUpcomingWorkshops(),

                const SizedBox(height: AppTheme.lg),

                // Quick Actions
                _buildQuickActions(),

                const SizedBox(height: AppTheme.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.gradientPrimary,
      ),
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Stack(
        children: [
          // Decorative hearts
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _heartController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_heartController.value * 0.2),
                  child: const Opacity(
                    opacity: 0.3,
                    child: Column(
                      children: [
                        Text('💖', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 8),
                        Text('✨', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 8),
                        Text('🌸', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName.isNotEmpty ? 'مرحباً $_userName 💕' : 'مرحباً بك 💕',
                          style: const TextStyle(
                            fontSize: AppTheme.fontMd,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(height: AppTheme.xs),
                        const Text(
                          'في FitHer ✨',
                          style: TextStyle(
                            fontSize: AppTheme.fontXxl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.notifications_none,
                            size: 28,
                            color: AppTheme.white,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.white,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                '♥',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildQuickStats() {
    // استخراج البيانات من API أو القيم الافتراضية
    final caloriesBurned = _userStats['calories_burned']?.toString() ??
        (_userStats['total_workouts'] != null
            ? '${(_userStats['total_workouts'] as int) * 320}'
            : '0');
    final workoutMinutes = _userStats['total_minutes']?.toString() ??
        (_userStats['total_workouts'] != null
            ? '${(_userStats['total_workouts'] as int) * 45}'
            : '0');
    final streak = _userStats['current_streak']?.toString() ?? '0';

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.md, AppTheme.xl, AppTheme.md, 0),
      child: _isLoadingStats
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    value: caloriesBurned,
                    label: 'سعرات محروقة 🔥',
                    colors: [const Color(0xFFFFE4E1), const Color(0xFFFFF0F5)],
                    delay: 0,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  flex: 1,
                  child: _buildStatCard(
                    icon: Icons.timer,
                    value: workoutMinutes,
                    label: 'دقيقة تمرين ⏱️',
                    colors: [const Color(0xFFF0D9FF), const Color(0xFFFFDDF4)],
                    delay: 100,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  flex: 1,
                  child: _buildStatCard(
                    icon: Icons.emoji_events,
                    value: streak,
                    label: 'يوم متواصل ✨',
                    colors: [const Color(0xFFFFF0F5), const Color(0xFFFFE4E1)],
                    delay: 200,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required List<Color> colors,
    required int delay,
  }) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 28, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay.ms)
        .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: delay.ms);
  }

  Widget _buildMyTrainerSection() {
    if (_myTrainer == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF0F5), Color(0xFFFFE4E1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
          ),
          child: const Column(
            children: [
              Icon(Icons.person_search, size: 48, color: AppTheme.primary),
              SizedBox(height: AppTheme.md),
              Text(
                'لم يتم تعيين مدربة لك بعد',
                style: TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.text,
                ),
              ),
              SizedBox(height: AppTheme.xs),
              Text(
                'تواصلي مع الإدارة لتعيين مدربة لك',
                style: TextStyle(
                  fontSize: AppTheme.fontSm,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms),
      );
    }

    final trainerName = _myTrainer!['name'] ?? 'المدربة';
    final specialty = _myTrainer!['specialty'] ?? '';
    final rating = (_myTrainer!['rating'] ?? 0.0).toDouble();
    final experience = _myTrainer!['experience'] ?? _myTrainer!['yearsOfExperience'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مدربتي 💪',
            style: TextStyle(
              fontSize: AppTheme.fontLg,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: AppTheme.md),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE4EC), Color(0xFFFFF0F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppTheme.lg),
            child: Row(
              children: [
                // صورة المدربة
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: AppTheme.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                // معلومات المدربة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainerName,
                        style: const TextStyle(
                          fontSize: AppTheme.fontLg,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                      if (specialty.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          specialty,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSm,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppTheme.sm),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: AppTheme.warning),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: AppTheme.fontSm,
                              fontWeight: AppTheme.fontBold,
                              color: AppTheme.text,
                            ),
                          ),
                          const SizedBox(width: AppTheme.md),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              '$experience سنوات خبرة',
                              style: const TextStyle(
                                fontSize: AppTheme.fontXs,
                                color: AppTheme.primary,
                                fontWeight: AppTheme.fontMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // زر التواصل
                Container(
                  padding: const EdgeInsets.all(AppTheme.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(
                    Icons.chat,
                    color: AppTheme.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
    );
  }

  Widget _buildWeeklyProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0x26FF69B4),
              Color(0x26DDA0DD),
            ],
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التقدم الأسبوعي 📈',
                      style: TextStyle(
                        fontSize: AppTheme.fontLg,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.text,
                      ),
                    ),
                    SizedBox(height: AppTheme.xs),
                    Text(
                      '5 من 7 أيام مكتملة',
                      style: TextStyle(
                        fontSize: AppTheme.fontSm,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.md,
                    vertical: AppTheme.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(color: AppTheme.primary),
                  ),
                  child: const Text(
                    '75%',
                    style: TextStyle(
                      fontSize: AppTheme.fontLg,
                      fontWeight: AppTheme.fontBold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.md),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              child: LinearProgressIndicator(
                value: 0.75,
                minHeight: 12,
                backgroundColor: AppTheme.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              ),
            ),
            const SizedBox(height: AppTheme.md),
            // Days
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final days = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
                final isCompleted = index < 5;
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.primary.withValues(alpha: 0.3)
                        : AppTheme.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppTheme.primary
                          : AppTheme.white.withValues(alpha: 0.2),
                    ),
                    boxShadow: isCompleted ? AppTheme.shadowSm : null,
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: TextStyle(
                        fontSize: AppTheme.fontSm,
                        fontWeight: AppTheme.fontSemibold,
                        color: isCompleted
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
    );
  }

  Widget _buildTodayWorkout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تمرين اليوم',
                style: TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.text,
                ),
              ),
              Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: AppTheme.fontSm,
                  color: AppTheme.primary,
                  fontWeight: AppTheme.fontMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimary,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppTheme.shadowMd,
            ),
            padding: const EdgeInsets.all(AppTheme.lg),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تمارين القوة للمبتدئات',
                        style: TextStyle(
                          fontSize: AppTheme.fontLg,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.white,
                        ),
                      ),
                      SizedBox(height: AppTheme.xs),
                      Text(
                        '30 دقيقة • متوسط الصعوبة',
                        style: TextStyle(
                          fontSize: AppTheme.fontSm,
                          color: AppTheme.white,
                        ),
                      ),
                      SizedBox(height: AppTheme.md),
                    ],
                  ),
                ),
                Icon(
                  Icons.fitness_center,
                  size: 60,
                  color: AppTheme.white.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
    );
  }

  Widget _buildPopularClasses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الحصص الأكثر شعبية',
                style: TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.text,
                ),
              ),
              Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: AppTheme.fontSm,
                  color: AppTheme.primary,
                  fontWeight: AppTheme.fontMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.md),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
            itemCount: _classes.isEmpty ? 1 : _classes.length,
            itemBuilder: (context, index) {
              // إذا لم تكن هناك حصص، عرض رسالة
              if (_classes.isEmpty) {
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(left: AppTheme.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.md),
                      child: Text(
                        'لا توجد حصص متاحة',
                        style: TextStyle(color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }
              final classData = _classes[index];

              final gradients = [
                AppTheme.gradientRose,
                AppTheme.gradientLavender,
                AppTheme.gradientPeach,
              ];

              return Container(
                width: 160,
                margin: const EdgeInsets.only(left: AppTheme.sm),
                decoration: BoxDecoration(
                  gradient: gradients[index],
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppTheme.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        classData['icon'] as IconData,
                        size: 32,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.sm),
                    Text(
                      classData['title'] as String,
                      style: const TextStyle(
                        fontSize: AppTheme.fontMd,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    const SizedBox(height: AppTheme.xs),
                    Text(
                      classData['instructor'] as String,
                      style: const TextStyle(
                        fontSize: AppTheme.fontXs,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(width: AppTheme.xs),
                        Text(
                          classData['duration'] as String,
                          style: const TextStyle(
                            fontSize: AppTheme.fontXs,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (500 + index * 100).ms)
                  .slideX(
                      begin: 0.2,
                      end: 0,
                      duration: 400.ms,
                      delay: (500 + index * 100).ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الوصول السريع',
            style: TextStyle(
              fontSize: AppTheme.fontLg,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppTheme.sm,
            crossAxisSpacing: AppTheme.sm,
            childAspectRatio: 0.85,
            children: [
              _buildQuickActionCard(
                icon: Icons.video_call,
                title: 'جلسات أونلاين',
                color: const Color(0xFF6C63FF),
                delay: 600,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OnlineSessionsScreen()),
                ),
              ),
              _buildQuickActionCard(
                icon: Icons.fitness_center,
                title: 'التمارين',
                color: AppTheme.primary,
                delay: 650,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrainingScreen()),
                ),
              ),
              _buildQuickActionCard(
                icon: Icons.restaurant_menu,
                title: 'التغذية',
                color: AppTheme.secondary,
                delay: 700,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NutritionScreen()),
                ),
              ),
              _buildQuickActionCard(
                icon: Icons.shopping_bag,
                title: 'المتجر',
                color: const Color(0xFFE91E63),
                delay: 750,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShopScreen()),
                ),
              ),
              _buildQuickActionCard(
                icon: Icons.trending_up,
                title: 'تقدمي',
                color: const Color(0xFF4CAF50),
                delay: 800,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProgressTrackingScreen()),
                ),
              ),
              _buildQuickActionCard(
                icon: Icons.card_membership,
                title: 'الاشتراكات',
                color: const Color(0xFFFF6F00),
                delay: 850,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                ),
              ),
              _buildQuickActionCard(
                icon: Icons.chat_bubble,
                title: 'استشارة',
                color: AppTheme.accent,
                delay: 900,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                ),
              ),
              _buildQuickActionCard(
                icon: Icons.help_outline,
                title: 'المساعدة',
                color: const Color(0xFF607D8B),
                delay: 950,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required int delay,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppTheme.sm, horizontal: AppTheme.xs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.9), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delay.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          delay: delay.ms,
        );
  }

  // Top Trainers Section
  Widget _buildTopTrainers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'أفضل المدربين',
                style: TextStyle(
                  fontSize: AppTheme.fontXl,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.text,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: AppTheme.fontMd,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.sm),
        SizedBox(
          height: 220,
          child: _trainers.isEmpty
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppTheme.md),
                    padding: const EdgeInsets.all(AppTheme.lg),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Text(
                      'لا يوجد مدربين متاحين حالياً',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
            itemCount: _trainers.length,
            itemBuilder: (context, index) {
              final trainer = _trainers[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(left: AppTheme.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.card,
                      AppTheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: AppTheme.border.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Container
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppTheme.radiusLg),
                          topRight: Radius.circular(AppTheme.radiusLg),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trainer.name,
                            style: const TextStyle(
                              fontSize: AppTheme.fontMd,
                              fontWeight: AppTheme.fontBold,
                              color: AppTheme.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trainer.specialty,
                            style: TextStyle(
                              fontSize: AppTheme.fontXs,
                              color: AppTheme.textSecondary.withValues(alpha: 0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTheme.xs),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: AppTheme.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                trainer.rating.toString(),
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSm,
                                  fontWeight: AppTheme.fontMedium,
                                  color: AppTheme.text,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.xs,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.2),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusSm),
                                ),
                                child: Text(
                                  '${trainer.experience} سنوات',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.primary,
                                    fontWeight: AppTheme.fontMedium,
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
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                  .slideX(
                    begin: 0.2,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  );
            },
          ),
        ),
      ],
    );
  }

  // Upcoming Workshops Section
  Widget _buildUpcomingWorkshops() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الورش التدريبية القادمة',
                style: TextStyle(
                  fontSize: AppTheme.fontXl,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.text,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: AppTheme.fontMd,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.sm),
        SizedBox(
          height: 200,
          child: _workshops.isEmpty
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppTheme.md),
                    padding: const EdgeInsets.all(AppTheme.lg),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Text(
                      'لا توجد ورش تدريبية متاحة حالياً',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
            itemCount: _workshops.length,
            itemBuilder: (context, index) {
              final workshop = _workshops[index];
              return Container(
                width: 300,
                margin: const EdgeInsets.only(left: AppTheme.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.card,
                      AppTheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: AppTheme.border.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              workshop.title,
                              style: const TextStyle(
                                fontSize: AppTheme.fontMd,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.text,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getLevelColor(workshop.level)
                                  .withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              workshop.level,
                              style: TextStyle(
                                fontSize: AppTheme.fontXs,
                                color: _getLevelColor(workshop.level),
                                fontWeight: AppTheme.fontMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            workshop.instructor,
                            style: TextStyle(
                              fontSize: AppTheme.fontSm,
                              color: AppTheme.textSecondary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.xs),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${workshop.date.day}/${workshop.date.month}',
                            style: TextStyle(
                              fontSize: AppTheme.fontSm,
                              color: AppTheme.textSecondary.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(width: AppTheme.md),
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            workshop.time,
                            style: TextStyle(
                              fontSize: AppTheme.fontSm,
                              color: AppTheme.textSecondary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المقاعد المتاحة',
                                style: TextStyle(
                                  fontSize: AppTheme.fontXs,
                                  color: AppTheme.textSecondary
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              Text(
                                '${workshop.availableSeats} / ${workshop.capacity}',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontMd,
                                  fontWeight: AppTheme.fontBold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.md,
                              vertical: AppTheme.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Text(
                              '${workshop.price.toStringAsFixed(0)} AED',
                              style: const TextStyle(
                                fontSize: AppTheme.fontMd,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                  .slideX(
                    begin: 0.2,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBMICalculator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF0F5),
              Color(0xFFFFE4E1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.sm),
                  decoration: BoxDecoration(
                    color: _getBMIColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(
                    Icons.calculate,
                    color: _getBMIColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حاسبة كتلة الجسم (BMI)',
                        style: TextStyle(
                          color: AppTheme.primaryDark,
                          fontSize: AppTheme.fontLg,
                          fontWeight: AppTheme.fontBold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'احسب مؤشر كتلة جسمك',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: AppTheme.fontSm,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.lg),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'الوزن (كجم)',
                      labelStyle: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: '70',
                      hintStyle: TextStyle(
                        color: AppTheme.primary.withOpacity(0.3),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: const BorderSide(color: AppTheme.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.md,
                        vertical: AppTheme.md,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'الطول (سم)',
                      labelStyle: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: '170',
                      hintStyle: TextStyle(
                        color: AppTheme.primary.withOpacity(0.3),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: const BorderSide(color: AppTheme.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.md,
                        vertical: AppTheme.md,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  elevation: 8,
                  shadowColor: AppTheme.primary.withOpacity(0.5),
                ),
                child: const Text(
                  'احسب',
                  style: TextStyle(
                    fontSize: AppTheme.fontLg,
                    fontWeight: AppTheme.fontBold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            if (_bmiResult != null) ...[
              const SizedBox(height: AppTheme.lg),
              Container(
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  color: _getBMIColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: _getBMIColor().withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _bmiResult!.toStringAsFixed(1),
                          style: TextStyle(
                            color: _getBMIColor(),
                            fontSize: 48,
                            fontWeight: AppTheme.fontBold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.sm),
                    Text(
                      _bmiCategory,
                      style: TextStyle(
                        color: _getBMIColor(),
                        fontSize: AppTheme.fontLg,
                        fontWeight: AppTheme.fontSemibold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.sm),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.background.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Row(
                        children: [
                          // نقص في الوزن (أقل من 18.5)
                          Expanded(
                            flex: 185,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _bmiResult! < 18.5
                                    ? Colors.blue
                                    : Colors.blue.withValues(alpha: 0.3),
                                borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(AppTheme.radiusSm),
                                ),
                              ),
                            ),
                          ),
                          // وزن طبيعي (18.5 - 25)
                          Expanded(
                            flex: 65,
                            child: Container(
                              color: _bmiResult! >= 18.5 && _bmiResult! < 25
                                  ? Colors.green
                                  : Colors.green.withValues(alpha: 0.3),
                            ),
                          ),
                          // زيادة في الوزن (25 - 30)
                          Expanded(
                            flex: 50,
                            child: Container(
                              color: _bmiResult! >= 25 && _bmiResult! < 30
                                  ? Colors.orange
                                  : Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          // سمنة (30+)
                          Expanded(
                            flex: 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _bmiResult! >= 30
                                    ? Colors.red
                                    : Colors.red.withValues(alpha: 0.3),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(AppTheme.radiusSm),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'نقص',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.8),
                            fontSize: AppTheme.fontXs,
                          ),
                        ),
                        Text(
                          'طبيعي',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.8),
                            fontSize: AppTheme.fontXs,
                          ),
                        ),
                        Text(
                          'زيادة',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.8),
                            fontSize: AppTheme.fontXs,
                          ),
                        ),
                        Text(
                          'سمنة',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.8),
                            fontSize: AppTheme.fontXs,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1.0, 1.0),
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),
            ],
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(
            begin: 0.2,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOut,
          ),
    );
  }

  Widget _buildBMRCalculator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFC8E6C9),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.sm),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حاسبة معدل الأيض (BMR)',
                        style: TextStyle(
                          color: Color(0xFF1B5E20),
                          fontSize: AppTheme.fontLg,
                          fontWeight: AppTheme.fontBold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'احسب السعرات اللازمة يومياً',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: AppTheme.fontSm,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.lg),

            // الجنس
            Row(
              children: [
                const Text(
                  'الجنس:',
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedGender = 'female'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: AppTheme.sm),
                            decoration: BoxDecoration(
                              color: _selectedGender == 'female'
                                  ? Colors.green
                                  : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Text(
                              'أنثى',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedGender == 'female'
                                    ? Colors.white
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.sm),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedGender = 'male'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: AppTheme.sm),
                            decoration: BoxDecoration(
                              color: _selectedGender == 'male'
                                  ? Colors.green
                                  : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: Text(
                              'ذكر',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedGender == 'male'
                                    ? Colors.white
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.md),

            // الوزن والطول والعمر
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: _buildBMRInputDecoration('الوزن (كجم)', '60'),
                  ),
                ),
                const SizedBox(width: AppTheme.sm),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: _buildBMRInputDecoration('الطول (سم)', '165'),
                  ),
                ),
                const SizedBox(width: AppTheme.sm),
                Expanded(
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: _buildBMRInputDecoration('العمر', '25'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.md),

            // مستوى النشاط
            const Text(
              'مستوى النشاط:',
              style: TextStyle(
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedActivity,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                  style: const TextStyle(
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.bold,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'sedentary', child: Text('قليل الحركة (مكتبي)')),
                    DropdownMenuItem(value: 'light', child: Text('نشاط خفيف (1-3 أيام/أسبوع)')),
                    DropdownMenuItem(value: 'moderate', child: Text('نشاط معتدل (3-5 أيام/أسبوع)')),
                    DropdownMenuItem(value: 'active', child: Text('نشاط عالي (6-7 أيام/أسبوع)')),
                    DropdownMenuItem(value: 'very_active', child: Text('نشاط مكثف (رياضي محترف)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedActivity = value);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: AppTheme.lg),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateBMR,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  elevation: 8,
                  shadowColor: Colors.green.withOpacity(0.5),
                ),
                child: const Text(
                  'احسب السعرات',
                  style: TextStyle(
                    fontSize: AppTheme.fontLg,
                    fontWeight: AppTheme.fontBold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            if (_bmrResult != null && _tdeeResult != null) ...[
              const SizedBox(height: AppTheme.lg),
              Container(
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    // معدل الأيض الأساسي
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معدل الأيض الأساسي (BMR)',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: AppTheme.fontSm,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'السعرات في الراحة التامة',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: AppTheme.fontXs,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_bmrResult!.toInt()} سعرة',
                          style: const TextStyle(
                            color: Color(0xFF1B5E20),
                            fontSize: AppTheme.fontXl,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: AppTheme.lg),

                    // السعرات اليومية
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'السعرات اليومية (TDEE)',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: AppTheme.fontSm,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'للحفاظ على الوزن الحالي',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: AppTheme.fontXs,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_tdeeResult!.toInt()} سعرة',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: AppTheme.fontXxl,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.md),

                    // توصيات
                    Container(
                      padding: const EdgeInsets.all(AppTheme.sm),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Column(
                        children: [
                          _buildCalorieRecommendation(
                            'لخسارة الوزن',
                            '${(_tdeeResult! - 500).toInt()} سعرة',
                            Colors.orange,
                            Icons.trending_down,
                          ),
                          const SizedBox(height: AppTheme.xs),
                          _buildCalorieRecommendation(
                            'للحفاظ على الوزن',
                            '${_tdeeResult!.toInt()} سعرة',
                            Colors.green,
                            Icons.trending_flat,
                          ),
                          const SizedBox(height: AppTheme.xs),
                          _buildCalorieRecommendation(
                            'لزيادة الوزن',
                            '${(_tdeeResult! + 500).toInt()} سعرة',
                            Colors.blue,
                            Icons.trending_up,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
    );
  }

  InputDecoration _buildBMRInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.green.withOpacity(0.3)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: Colors.green),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: BorderSide(color: Colors.green.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sm,
        vertical: AppTheme.sm,
      ),
    );
  }

  Widget _buildCalorieRecommendation(String title, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: AppTheme.sm),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1B5E20),
              fontSize: AppTheme.fontSm,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: AppTheme.fontMd,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
        return AppTheme.info;
    }
  }
}
