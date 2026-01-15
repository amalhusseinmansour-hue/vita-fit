import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../services/trainer_hours_service.dart';
import 'trainer_add_exercise_screen.dart';
import 'trainer_add_meal_screen.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  Map<String, dynamic> _trainerStats = {};
  List<dynamic> _todaySessions = [];
  List<dynamic> _pendingRequests = [];
  TrainerHoursUsage? _hoursUsage;
  bool _isLoading = true;
  String _trainerName = 'المدربة';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final clients = await ApiService.getTrainerClients();
      final sessions = await ApiService.getTrainerSessions();

      // حساب الإحصائيات
      final activeClients = clients.length;
      final totalSessions = sessions.length;

      // جلسات اليوم
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final todaySessions = sessions.where((s) {
        final sessionDate = s['scheduled_at']?.toString().substring(0, 10) ?? '';
        return sessionDate == todayStr;
      }).toList();

      // تحميل بيانات المدربة من SharedPreferences أولاً
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('user_data');
      String trainerName = 'المدربة';
      String trainerId = 'trainer_1';

      if (userDataStr != null) {
        final userData = json.decode(userDataStr);
        trainerName = userData['name']?.toString() ?? 'المدربة';
        trainerId = userData['id']?.toString() ?? userData['trainer_id']?.toString() ?? 'trainer_1';
        debugPrint('Loaded trainer from SharedPreferences: $trainerName');
      } else {
        // تحميل من API إذا لم تكن البيانات محفوظة
        final profile = await ApiService.getProfile();
        final profileData = profile['profile'] ?? profile['data'] ?? profile;
        trainerId = profileData['id']?.toString() ?? profileData['_id']?.toString() ?? 'trainer_1';
        trainerName = profileData['name']?.toString() ?? 'المدربة';
        debugPrint('Loaded trainer from API: $trainerName');
      }

      final hoursUsage = await TrainerHoursService.getTrainerUsage(trainerId);

      // تحميل طلبات المتدربين المعلقة
      final requestsResult = await ApiService.getTrainerRequests();
      final pendingRequests = requestsResult['success'] == true
          ? (requestsResult['data'] as List? ?? [])
          : [];

      setState(() {
        _trainerName = trainerName;
        _pendingRequests = pendingRequests;
        _trainerStats = {
          'activeClients': activeClients,
          'maxClients': 15,
          'totalSessions': totalSessions,
          'rating': 4.8,
          'experience': 3,
        };
        _todaySessions = todaySessions.isNotEmpty ? todaySessions : sessions.take(3).toList();
        _hoursUsage = hoursUsage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showNewPlanDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'إنشاء خطة جديدة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.text,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fitness_center, color: AppTheme.primary),
              ),
              title: const Text('خطة تمارين', style: TextStyle(color: AppTheme.text)),
              subtitle: const Text('إنشاء برنامج تدريبي للمتدربة', style: TextStyle(color: AppTheme.textSecondary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrainerAddExerciseScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant_menu, color: AppTheme.secondary),
              ),
              title: const Text('خطة غذائية', style: TextStyle(color: AppTheme.text)),
              subtitle: const Text('إنشاء برنامج غذائي للمتدربة', style: TextStyle(color: AppTheme.textSecondary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrainerAddMealScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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

                const SizedBox(height: AppTheme.lg),

                // Quick Stats for Trainers
                _buildTrainerStats(),

                const SizedBox(height: AppTheme.lg),

                // Pending Trainee Requests
                if (_pendingRequests.isNotEmpty) ...[
                  _buildPendingRequests(),
                  const SizedBox(height: AppTheme.lg),
                ],

                // Trainer Hours Usage
                _buildHoursUsageCard(),

                const SizedBox(height: AppTheme.lg),

                // Today's Sessions
                _buildTodaySessions(),

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
        gradient: LinearGradient(
          colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'مرحباً مدربتنا 💪',
                    style: TextStyle(
                      fontSize: AppTheme.fontMd,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.xs),
                  Text(
                    _trainerName,
                    style: const TextStyle(
                      fontSize: AppTheme.fontXxl,
                      fontWeight: AppTheme.fontBold,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      size: 28,
                      color: AppTheme.white,
                    ),
                  ),
                  if (_pendingRequests.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_pendingRequests.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildTrainerStats() {
    final clients = _trainerStats['activeClients'] ?? 0;
    final maxClients = _trainerStats['maxClients'] ?? 15;
    final sessions = _trainerStats['totalSessions'] ?? 0;
    final rating = _trainerStats['rating'] ?? 0.0;
    final experience = _trainerStats['experience'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.people,
                    value: '$clients/$maxClients',
                    label: 'متدربة',
                    colors: [const Color(0xFFFFE4E1), const Color(0xFFFFB6C1)],
                    delay: 0,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_month,
                    value: '$sessions',
                    label: 'جلسة',
                    colors: [const Color(0xFFFFF0F5), const Color(0xFFFFDDF4)],
                    delay: 100,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.star,
                    value: '$rating',
                    label: 'التقييم',
                    colors: [const Color(0xFFF0D9FF), const Color(0xFFDDA0DD)],
                    delay: 200,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.workspace_premium,
                    value: '$experience',
                    label: 'سنوات خبرة',
                    colors: [const Color(0xFFE8F5E9), const Color(0xFF81C784)],
                    delay: 300,
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
              child: Icon(icon, size: 28, color: const Color(0xFFFF69B4)),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF69B4),
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
                color: Color(0xFFFF69B4),
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

  Widget _buildHoursUsageCard() {
    if (_hoursUsage == null) {
      return const SizedBox.shrink();
    }

    final usage = _hoursUsage!;
    final progressColor = usage.isOverLimit
        ? const Color(0xFFE91E63)
        : const Color(0xFFFF69B4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: usage.isOverLimit
                ? [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)]
                : [const Color(0xFFFFF0F5), const Color(0xFFFFE4E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: progressColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: progressColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                const Expanded(
                  child: Text(
                    'ساعاتي الشهرية',
                    style: TextStyle(
                      fontSize: AppTheme.fontLg,
                      fontWeight: AppTheme.fontBold,
                      color: AppTheme.text,
                    ),
                  ),
                ),
                if (usage.isOverLimit)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Text(
                      'تجاوزت الحد',
                      style: TextStyle(
                        fontSize: AppTheme.fontXs,
                        color: AppTheme.white,
                        fontWeight: AppTheme.fontSemibold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.lg),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (usage.usagePercentage / 100).clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: AppTheme.sm),

            // Hours Info Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${usage.usedHours.toStringAsFixed(1)} ساعة مستخدمة',
                  style: TextStyle(
                    fontSize: AppTheme.fontSm,
                    color: progressColor,
                    fontWeight: AppTheme.fontMedium,
                  ),
                ),
                Text(
                  'من ${usage.freeHours} ساعة مجانية',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSm,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.md),

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildHoursStatItem(
                    icon: Icons.hourglass_empty,
                    value: '${usage.remainingFreeHours.toStringAsFixed(1)}',
                    label: 'متبقية',
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                Expanded(
                  child: _buildHoursStatItem(
                    icon: Icons.add_circle_outline,
                    value: '${usage.extraHours.toStringAsFixed(1)}',
                    label: 'إضافية',
                    color: const Color(0xFFFF9800),
                  ),
                ),
                Expanded(
                  child: _buildHoursStatItem(
                    icon: Icons.attach_money,
                    value: '${usage.extraCost.toStringAsFixed(0)}',
                    label: 'AED',
                    color: const Color(0xFFE91E63),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildHoursStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: AppTheme.fontLg,
            fontWeight: AppTheme.fontBold,
            color: color,
          ),
        ),
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

  Widget _buildTodaySessions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'جلساتي القادمة',
                style: TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.text,
                ),
              ),
              TextButton(
                onPressed: _loadData,
                child: const Text(
                  'تحديث',
                  style: TextStyle(color: AppTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          else if (_todaySessions.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppTheme.lg),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: const Center(
                child: Text(
                  'لا توجد جلسات حالياً',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ..._todaySessions.asMap().entries.map((entry) {
              final index = entry.key;
              final session = entry.value;
              final isOnline = session['is_online'] == true;
              final participants = session['participants_count'] ?? 0;
              final maxParticipants = session['max_participants'] ?? 10;

              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.sm),
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isOnline
                        ? [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)]
                        : [const Color(0xFFFFF0F5), const Color(0xFFFFDDF4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isOnline ? Icons.videocam : Icons.fitness_center,
                        color: isOnline ? const Color(0xFF2196F3) : const Color(0xFFFF69B4),
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session['title'] ?? 'جلسة تدريبية',
                            style: TextStyle(
                              fontSize: AppTheme.fontMd,
                              fontWeight: FontWeight.bold,
                              color: isOnline ? const Color(0xFF1976D2) : const Color(0xFFFF69B4),
                            ),
                          ),
                          Text(
                            '${session['day'] ?? ''} - ${session['time'] ?? ''}',
                            style: TextStyle(
                              fontSize: AppTheme.fontSm,
                              color: isOnline ? const Color(0xFF1976D2) : const Color(0xFFFF69B4),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 14,
                                color: isOnline ? const Color(0xFF1976D2) : const Color(0xFFFF69B4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$participants/$maxParticipants',
                                style: TextStyle(
                                  fontSize: AppTheme.fontXs,
                                  color: isOnline ? const Color(0xFF1976D2) : const Color(0xFFFF69B4),
                                ),
                              ),
                              if (isOnline) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.wifi, size: 14, color: Color(0xFF4CAF50)),
                                const SizedBox(width: 4),
                                const Text(
                                  'أونلاين',
                                  style: TextStyle(
                                    fontSize: AppTheme.fontXs,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isOnline ? const Color(0xFF1976D2) : const Color(0xFFFF69B4),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms);
            }),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: AppTheme.fontLg,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.text,
            ),
          ),
          const SizedBox(height: AppTheme.md),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppTheme.sm,
            crossAxisSpacing: AppTheme.sm,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard(
                icon: Icons.fitness_center,
                title: 'إضافة تمرين',
                color: const Color(0xFFFF69B4),
                delay: 0,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrainerAddExerciseScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                icon: Icons.restaurant_menu,
                title: 'إضافة وجبة',
                color: const Color(0xFFFFB6C1),
                delay: 100,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrainerAddMealScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                icon: Icons.add_circle,
                title: 'خطة جديدة',
                color: const Color(0xFFDDA0DD),
                delay: 200,
                onTap: () {
                  _showNewPlanDialog();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
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
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.xs),
          Text(
            title,
            style: TextStyle(
              fontSize: AppTheme.fontSm,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delay.ms);
  }

  Widget _buildPendingRequests() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add, color: Colors.orange, size: 20),
              ),
              const SizedBox(width: AppTheme.sm),
              const Text(
                'طلبات متدربات جديدة',
                style: TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.text,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_pendingRequests.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          ..._pendingRequests.asMap().entries.map((entry) {
            final index = entry.key;
            final request = entry.value;
            final trainee = request['trainee'] ?? {};

            return Container(
              margin: const EdgeInsets.only(bottom: AppTheme.sm),
              padding: const EdgeInsets.all(AppTheme.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.orange.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.orange.withOpacity(0.2),
                        child: const Icon(Icons.person, color: Colors.orange, size: 24),
                      ),
                      const SizedBox(width: AppTheme.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trainee['name'] ?? 'متدربة جديدة',
                              style: const TextStyle(
                                fontSize: AppTheme.fontMd,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF69B4),
                              ),
                            ),
                            Text(
                              trainee['email'] ?? '',
                              style: const TextStyle(
                                fontSize: AppTheme.fontSm,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (trainee['phone'] != null)
                              Text(
                                trainee['phone'],
                                style: const TextStyle(
                                  fontSize: AppTheme.fontXs,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.md),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _respondToRequest(request['id'], 'accept'),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('قبول'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _respondToRequest(request['id'], 'reject'),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('رفض'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms);
          }),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }

  Future<void> _respondToRequest(int requestId, String action) async {
    try {
      final result = await ApiService.respondToTrainerRequest(requestId, action);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'accept' ? 'تم قبول المتدربة بنجاح' : 'تم رفض الطلب'),
            backgroundColor: action == 'accept' ? Colors.green : Colors.orange,
          ),
        );
        _loadData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'حدث خطأ'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ في الاتصال'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
