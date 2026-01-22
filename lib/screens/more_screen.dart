import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/hive_storage_service.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../providers/language_provider.dart';
import 'profile_screen.dart';
import 'subscription_screen.dart';
import 'payment_methods_screen.dart';
import 'progress_tracking_screen.dart';
import 'workout_schedule_screen.dart';
import 'meal_plans_screen.dart';
import 'online_sessions_screen.dart';
import 'my_orders_screen.dart';
import 'privacy_security_screen.dart';
import 'help_center_screen.dart';
import 'rate_app_screen.dart';
import 'feedback_screen.dart';
import 'about_app_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';
import 'language_settings_screen.dart';
import 'trainer_clients_screen.dart';
import 'trainer_schedule_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _userName = '';
  String _userEmail = '';
  String _userType = 'trainee'; // trainee or trainer
  int _consecutiveDays = 0;
  int _completedSessions = 0;
  double _weightLoss = 0.0;
  // Trainer stats
  int _totalClients = 0;
  int _activeClients = 0;
  int _sessionsGiven = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStats();
  }

  Future<void> _loadUserData() async {
    final userType = HiveStorageService.getString('userType') ?? 'trainee';

    // Try to get from user data first
    final userData = await ApiService.getUserData();
    if (userData != null) {
      setState(() {
        _userName = userData['name'] ?? '';
        _userEmail = userData['email'] ?? '';
        _userType = userData['type'] ?? userType;
      });
    } else {
      // Fallback to individual Hive storage
      setState(() {
        _userName = HiveStorageService.getString('userName') ?? '';
        _userEmail = HiveStorageService.getString('userEmail') ?? '';
        _userType = userType;
      });
    }
  }

  Future<void> _loadStats() async {
    final userType = HiveStorageService.getString('userType') ?? 'trainee';

    if (userType == 'trainer') {
      await _loadTrainerStats();
    } else {
      await _loadTraineeStats();
    }
  }

  Future<void> _loadTraineeStats() async {
    // Load stats from local storage
    final startWeight = double.tryParse(HiveStorageService.getString('smartplan_current_weight') ?? '') ?? 0;
    final currentWeight = double.tryParse(HiveStorageService.getString('current_weight') ?? HiveStorageService.getString('smartplan_current_weight') ?? '') ?? 0;

    // Calculate weight loss
    double weightLoss = 0;
    if (startWeight > 0 && currentWeight > 0 && startWeight > currentWeight) {
      weightLoss = startWeight - currentWeight;
    }

    // Load consecutive days and completed sessions
    final consecutiveDays = HiveStorageService.getInt('consecutive_days') ?? 0;
    final completedSessions = HiveStorageService.getInt('completed_sessions') ?? 0;

    setState(() {
      _consecutiveDays = consecutiveDays;
      _completedSessions = completedSessions;
      _weightLoss = weightLoss;
    });

    // Try to get from API
    try {
      final result = await ApiService.getTraineeStats();
      if (result['success'] == true && mounted) {
        setState(() {
          _consecutiveDays = result['consecutive_days'] ?? _consecutiveDays;
          _completedSessions = result['completed_sessions'] ?? _completedSessions;
          _weightLoss = (result['weight_loss'] ?? _weightLoss).toDouble();
        });
        // Save to local
        await HiveStorageService.setInt('consecutive_days', _consecutiveDays);
        await HiveStorageService.setInt('completed_sessions', _completedSessions);
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  Future<void> _loadTrainerStats() async {
    try {
      final result = await ApiService.getTrainerStats();
      if (result['success'] == true && mounted) {
        setState(() {
          _totalClients = result['total_clients'] ?? 0;
          _activeClients = result['active_clients'] ?? 0;
          _sessionsGiven = result['sessions_given'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading trainer stats: $e');
    }
  }

  bool get _isTrainer => _userType == 'trainer';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header مع Profile
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _isTrainer
                        ? AppTheme.gradientSecondary
                        : AppTheme.gradientPrimary,
                  ),
                  padding: const EdgeInsets.all(AppTheme.lg),
                  child: Column(
                    children: [
                      // صورة Profile
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.white,
                            width: 3,
                          ),
                          boxShadow: AppTheme.shadowLg,
                        ),
                        child: ClipOval(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: _isTrainer
                                  ? AppTheme.gradientPrimary
                                  : AppTheme.gradientSecondary,
                            ),
                            child: Icon(
                              _isTrainer ? Icons.sports : Icons.person,
                              size: 50,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ).animate().scale(duration: 600.ms),
                      const SizedBox(height: AppTheme.md),
                      Text(
                        _userName.isNotEmpty ? _userName : (_isTrainer ? 'مدربة VitaFit' : 'مستخدم VitaFit'),
                        style: const TextStyle(
                          fontSize: AppTheme.fontXl,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.white,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      if (_isTrainer) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'حساب مدربة',
                            style: TextStyle(
                              fontSize: AppTheme.fontSm,
                              color: AppTheme.white,
                            ),
                          ),
                        ).animate().fadeIn(delay: 250.ms),
                      ],
                      const SizedBox(height: AppTheme.lg),
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _isTrainer
                            ? [
                                _buildStatItem('$_totalClients', 'إجمالي المتدربات', 0),
                                _buildStatItem('$_activeClients', 'متدربة نشطة', 100),
                                _buildStatItem('$_sessionsGiven', 'جلسة مكتملة', 200),
                              ]
                            : [
                                _buildStatItem('$_consecutiveDays', 'أيام متواصلة', 0),
                                _buildStatItem('$_completedSessions', 'حصة مكتملة', 100),
                                _buildStatItem(_weightLoss > 0 ? _weightLoss.toStringAsFixed(1) : '0', 'كجم فقدان', 200),
                              ],
                      ),
                    ],
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
                      // الحساب
                      const Text(
                        'حسابي',
                        style: TextStyle(
                          fontSize: AppTheme.fontLg,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: AppTheme.md),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.person_outline,
                        title: 'الملف الشخصي',
                        subtitle: 'عرض وتعديل معلوماتك',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                          // Reload user data when returning from profile
                          _loadUserData();
                        },
                        delay: 0,
                      ),

                      // خيارات حسب نوع الحساب
                      if (_isTrainer) ...[
                        // خيارات المدربة
                        _buildMenuItem(
                          context: context,
                          icon: Icons.people_outline,
                          title: 'متدرباتي',
                          subtitle: 'إدارة قائمة المتدربات',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TrainerClientsScreen(),
                              ),
                            );
                          },
                          delay: 50,
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.calendar_month,
                          title: 'جدول الجلسات',
                          subtitle: 'إدارة مواعيد الجلسات',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TrainerScheduleScreen(),
                              ),
                            );
                          },
                          delay: 100,
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.payment,
                          title: 'المدفوعات',
                          subtitle: 'سجل المدفوعات والأرباح',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaymentMethodsScreen(),
                              ),
                            );
                          },
                          delay: 150,
                        ),
                      ] else ...[
                        // خيارات المتدربة
                        _buildMenuItem(
                          context: context,
                          icon: Icons.card_membership,
                          title: 'الاشتراكات',
                          subtitle: 'إدارة اشتراكاتك',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SubscriptionScreen(),
                              ),
                            );
                          },
                          delay: 50,
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.payment,
                          title: 'طرق الدفع',
                          subtitle: 'إدارة بطاقاتك',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaymentMethodsScreen(),
                              ),
                            );
                          },
                          delay: 100,
                        ),
                      ],

                      const SizedBox(height: AppTheme.lg),

                      // التمارين والتغذية
                      Text(
                        _isTrainer ? 'إدارة الخطط' : 'التمارين والتغذية',
                        style: const TextStyle(
                          fontSize: AppTheme.fontLg,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: AppTheme.md),

                      if (_isTrainer) ...[
                        // خيارات المدربة للخطط
                        _buildMenuItem(
                          context: context,
                          icon: Icons.fitness_center,
                          title: 'قوالب التمارين',
                          subtitle: 'إنشاء وإدارة خطط التمارين',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WorkoutScheduleScreen(),
                              ),
                            );
                          },
                          delay: 200,
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.restaurant_menu,
                          title: 'قوالب التغذية',
                          subtitle: 'إنشاء وإدارة الخطط الغذائية',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MealPlansScreen(),
                              ),
                            );
                          },
                          delay: 250,
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.analytics_outlined,
                          title: 'تقارير الأداء',
                          subtitle: 'متابعة تقدم المتدربات',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProgressTrackingScreen(),
                              ),
                            );
                          },
                          delay: 300,
                        ),
                      ] else ...[
                        // خيارات المتدربة
                        _buildMenuItem(
                          context: context,
                          icon: Icons.track_changes,
                          title: 'تتبع التقدم',
                          subtitle: 'عرض إحصائياتك',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProgressTrackingScreen(),
                              ),
                            );
                          },
                          delay: 150,
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.calendar_today,
                          title: 'جدول التمارين',
                          subtitle: 'خطتك الأسبوعية',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WorkoutScheduleScreen(),
                              ),
                            );
                          },
                          delay: 200,
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.restaurant_menu,
                          title: 'الخطط الغذائية',
                          subtitle: 'وجباتك المحفوظة',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MealPlansScreen(),
                              ),
                            );
                          },
                          delay: 250,
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.videocam,
                          title: 'الجلسات الأونلاين',
                          subtitle: 'جلساتك مع المدربات',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OnlineSessionsScreen(),
                              ),
                            );
                          },
                          delay: 275,
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.shopping_bag,
                          title: 'طلباتي',
                          subtitle: 'متابعة طلبات المتجر',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyOrdersScreen(),
                              ),
                            );
                          },
                          delay: 290,
                        ),
                      ],

                      const SizedBox(height: AppTheme.lg),

                      // المزيد
                      const Text(
                        'الإعدادات',
                        style: TextStyle(
                          fontSize: AppTheme.fontLg,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: AppTheme.md),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.notifications_outlined,
                        title: 'الإشعارات',
                        subtitle: 'إدارة التنبيهات',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                        delay: 300,
                      ),
                      Consumer<LanguageProvider>(
                        builder: (context, langProvider, child) {
                          final isRTL = langProvider.isRTL;
                          return _buildMenuItem(
                            context: context,
                            icon: Icons.language,
                            title: isRTL ? 'اللغة' : 'Language',
                            subtitle: isRTL ? 'العربية' : 'English',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LanguageSettingsScreen(),
                                ),
                              );
                            },
                            delay: 350,
                          );
                        },
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.dark_mode,
                        title: 'المظهر',
                        subtitle: 'الوضع الداكن (مُفعّل)',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('التطبيق يعمل بالوضع الداكن حالياً'),
                              backgroundColor: AppTheme.success,
                            ),
                          );
                        },
                        delay: 400,
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.privacy_tip_outlined,
                        title: 'الخصوصية والأمان',
                        subtitle: 'إعدادات حسابك',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PrivacySecurityScreen(),
                            ),
                          );
                        },
                        delay: 450,
                      ),

                      const SizedBox(height: AppTheme.lg),

                      // الدعم
                      const Text(
                        'الدعم',
                        style: TextStyle(
                          fontSize: AppTheme.fontLg,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: AppTheme.md),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.help_outline,
                        title: 'مركز المساعدة',
                        subtitle: 'الأسئلة الشائعة',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpCenterScreen(),
                            ),
                          );
                        },
                        delay: 500,
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.chat_bubble_outline,
                        title: 'تواصلي معنا',
                        subtitle: 'نحن هنا لمساعدتك',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpCenterScreen(),
                            ),
                          );
                        },
                        delay: 550,
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.star_outline,
                        title: 'قيّمي التطبيق',
                        subtitle: 'شاركينا رأيك',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RateAppScreen(),
                            ),
                          );
                        },
                        delay: 600,
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.lightbulb_outline,
                        title: 'اقتراحات وملاحظات',
                        subtitle: 'آراؤك تهمنا',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeedbackScreen(),
                            ),
                          );
                        },
                        delay: 650,
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.info_outline,
                        title: 'حول التطبيق',
                        subtitle: 'الإصدار 1.0.0',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutAppScreen(),
                            ),
                          );
                        },
                        delay: 700,
                      ),

                      const SizedBox(height: AppTheme.xl),

                      // زر تسجيل الخروج
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0x40FF69B4),
                              Color(0x40DDA0DD),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              // عرض مربع حوار التأكيد
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: AlertDialog(
                                    backgroundColor: AppTheme.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                    ),
                                    title: const Text(
                                      'تسجيل الخروج',
                                      style: TextStyle(
                                        color: AppTheme.white,
                                        fontWeight: AppTheme.fontBold,
                                      ),
                                    ),
                                    content: Text(
                                      _isTrainer
                                          ? 'هل أنتِ متأكدة من تسجيل الخروج؟'
                                          : 'هل أنت متأكدة من تسجيل الخروج؟',
                                      style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text(
                                          'إلغاء',
                                          style: TextStyle(color: AppTheme.textSecondary),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.error,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                          ),
                                        ),
                                        child: const Text(
                                          'تسجيل الخروج',
                                          style: TextStyle(color: AppTheme.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              if (confirmed == true) {
                                // تسجيل الخروج
                                await ApiService.logout();

                                // حذف جميع البيانات المحفوظة
                                await HiveStorageService.clear();

                                if (context.mounted) {
                                  // الانتقال إلى شاشة تسجيل الدخول
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                            },
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLg),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppTheme.md,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.logout,
                                    color: AppTheme.error,
                                  ),
                                  SizedBox(width: AppTheme.sm),
                                  Text(
                                    'تسجيل الخروج',
                                    style: TextStyle(
                                      fontSize: AppTheme.fontMd,
                                      fontWeight: AppTheme.fontSemibold,
                                      color: AppTheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms),

                      const SizedBox(height: AppTheme.xl),
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

  Widget _buildStatItem(String value, String label, int delay) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: AppTheme.fontXl,
            fontWeight: AppTheme.fontBold,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTheme.fontXs,
            color: AppTheme.white,
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms);
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.sm),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: _isTrainer
                        ? AppTheme.gradientSecondary
                        : AppTheme.gradientPrimary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.white,
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
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSm,
                          color: AppTheme.textSecondary,
                        ),
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
          delay: delay.ms,
        );
  }

}
