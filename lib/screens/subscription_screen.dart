import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _currentSubscription;
  List<Map<String, dynamic>> _plans = [];
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('userName') ?? 'المستخدم';

      // Load current subscription
      final subscription = await ApiService.getMySubscription();

      // Load available plans
      final plansResult = await ApiService.getSubscriptionPlans();

      if (mounted) {
        setState(() {
          if (subscription['success'] == true || subscription['plan'] != null) {
            _currentSubscription = subscription['data'] ?? subscription;
          }

          if (plansResult['success'] == true) {
            _plans = (plansResult['data'] as List<dynamic>)
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showUpgradeDialog(Map<String, dynamic> plan) {
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
            'تأكيد الاشتراك',
            style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هل تريدين الاشتراك في ${plan['nameAr'] ?? plan['name']}؟',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppTheme.md),
              Container(
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('السعر:', style: TextStyle(color: AppTheme.textSecondary)),
                    Text(
                      '${plan['price']} ريال',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: AppTheme.fontLg,
                      ),
                    ),
                  ],
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
              onPressed: () async {
                Navigator.pop(context);
                await _subscribeToPlan(plan);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('تأكيد الاشتراك', style: TextStyle(color: AppTheme.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _subscribeToPlan(Map<String, dynamic> plan) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
    );

    try {
      final result = await ApiService.subscribeToPlan(plan['id'].toString());

      if (mounted) {
        Navigator.pop(context); // Close loading

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'تم الاشتراك بنجاح!'),
              backgroundColor: AppTheme.success,
            ),
          );
          _loadData(); // Reload data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'فشل الاشتراك'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showCancelDialog() {
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
            'إلغاء الاشتراك',
            style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'هل أنتِ متأكدة من إلغاء الاشتراك؟ ستفقدين جميع المميزات الحالية.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('لا، أبقي الاشتراك', style: TextStyle(color: AppTheme.primary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تقديم طلب الإلغاء بنجاح'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              child: const Text('نعم، إلغاء', style: TextStyle(color: AppTheme.white)),
            ),
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
        backgroundColor: AppTheme.background,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
            : SafeArea(
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
                        'إدارة الاشتراكات',
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
                            // Current Subscription
                            const Text(
                              'اشتراكك الحالي',
                              style: TextStyle(
                                fontSize: AppTheme.fontXl,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.white,
                              ),
                            ).animate().fadeIn(),
                            const SizedBox(height: AppTheme.md),
                            _buildCurrentSubscription()
                                .animate()
                                .fadeIn(delay: 100.ms)
                                .slideY(begin: 0.2, end: 0, duration: 400.ms),

                            const SizedBox(height: AppTheme.xl),

                            // Available Plans
                            const Text(
                              'الخطط المتاحة',
                              style: TextStyle(
                                fontSize: AppTheme.fontXl,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.white,
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                            const SizedBox(height: AppTheme.md),

                            ..._plans.asMap().entries.map((entry) {
                              final index = entry.key;
                              final plan = entry.value;
                              final isCurrentPlan = _currentSubscription != null &&
                                  (_currentSubscription!['plan'] == plan['name']?.toLowerCase() ||
                                   _currentSubscription!['planName'] == plan['nameAr']);

                              return _buildPlanCard(
                                plan: plan,
                                isCurrentPlan: isCurrentPlan,
                                isPopular: index == 2, // الذهبية
                                delay: 300 + (index * 100),
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

  Widget _buildCurrentSubscription() {
    if (_currentSubscription == null) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.lg),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.card_membership, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.md),
            const Text(
              'لا يوجد اشتراك حالي',
              style: TextStyle(
                fontSize: AppTheme.fontLg,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.sm),
            const Text(
              'اختاري باقة مناسبة للبدء',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    final planName = _currentSubscription!['planName'] ?? _currentSubscription!['plan'] ?? 'الباقة المميزة';
    final status = _currentSubscription!['status'] ?? 'active';
    final endDate = _currentSubscription!['endDate'] ?? '';
    final daysRemaining = _currentSubscription!['daysRemaining'] ?? 0;
    final features = _currentSubscription!['features'] as List<dynamic>? ?? [];
    final trainer = _currentSubscription!['trainer'] as Map<String, dynamic>?;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.gradientPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowLg,
      ),
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: AppTheme.warning, size: 24),
                  const SizedBox(width: AppTheme.sm),
                  Text(
                    planName,
                    style: const TextStyle(
                      fontSize: AppTheme.fontXl,
                      fontWeight: AppTheme.fontBold,
                      color: AppTheme.white,
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
                  color: status == 'active'
                      ? AppTheme.success.withOpacity(0.2)
                      : AppTheme.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: status == 'active' ? AppTheme.success : AppTheme.warning,
                  ),
                ),
                child: Text(
                  status == 'active' ? 'نشط' : 'معلق',
                  style: TextStyle(
                    fontSize: AppTheme.fontSm,
                    fontWeight: AppTheme.fontBold,
                    color: status == 'active' ? AppTheme.success : AppTheme.warning,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.md),

          if (daysRemaining > 0)
            Container(
              padding: const EdgeInsets.all(AppTheme.sm),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: AppTheme.white, size: 18),
                  const SizedBox(width: AppTheme.sm),
                  Text(
                    'متبقي $daysRemaining يوم',
                    style: const TextStyle(color: AppTheme.white),
                  ),
                ],
              ),
            ),

          if (endDate.isNotEmpty) ...[
            const SizedBox(height: AppTheme.sm),
            Text(
              'ينتهي في: $endDate',
              style: TextStyle(color: AppTheme.white.withOpacity(0.8)),
            ),
          ],

          if (trainer != null) ...[
            const SizedBox(height: AppTheme.md),
            Container(
              padding: const EdgeInsets.all(AppTheme.sm),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: AppTheme.white, size: 18),
                  const SizedBox(width: AppTheme.sm),
                  Expanded(
                    child: Text(
                      'مدربتك: ${trainer['name']}',
                      style: const TextStyle(color: AppTheme.white),
                    ),
                  ),
                  if (trainer['phone'] != null)
                    IconButton(
                      onPressed: () {
                        // Open WhatsApp
                      },
                      icon: const Icon(Icons.chat, color: AppTheme.success, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ],

          if (features.isNotEmpty) ...[
            const SizedBox(height: AppTheme.md),
            const Text(
              'مميزاتك:',
              style: TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.sm),
            ...features.take(3).map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.success, size: 16),
                  const SizedBox(width: AppTheme.sm),
                  Expanded(
                    child: Text(
                      feature.toString(),
                      style: TextStyle(
                        color: AppTheme.white.withOpacity(0.9),
                        fontSize: AppTheme.fontSm,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            if (features.length > 3)
              Text(
                '+ ${features.length - 3} مميزات أخرى',
                style: TextStyle(
                  color: AppTheme.white.withOpacity(0.7),
                  fontSize: AppTheme.fontSm,
                ),
              ),
          ],

          const SizedBox(height: AppTheme.lg),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Show upgrade options
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: const Text(
                    'ترقية الخطة',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: _showCancelDialog,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: const Text(
                    'إلغاء الاشتراك',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required Map<String, dynamic> plan,
    required bool isCurrentPlan,
    required bool isPopular,
    required int delay,
  }) {
    final name = plan['nameAr'] ?? plan['name'] ?? '';
    final price = plan['price']?.toString() ?? '0';
    final duration = plan['duration'] ?? 30;
    final features = plan['features'] as List<dynamic>? ?? [];

    String periodText = '$duration يوم';
    if (duration == 30) periodText = 'شهر';
    if (duration == 90) periodText = '3 أشهر';
    if (duration == 365) periodText = 'سنة';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isCurrentPlan
              ? AppTheme.success
              : isPopular
                  ? AppTheme.primary
                  : AppTheme.border,
          width: isCurrentPlan || isPopular ? 2 : 1,
        ),
        boxShadow: isPopular ? AppTheme.shadowLg : AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badges
          if (isPopular || isCurrentPlan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppTheme.sm),
              decoration: BoxDecoration(
                gradient: isCurrentPlan
                    ? const LinearGradient(colors: [AppTheme.success, Color(0xFF2E7D32)])
                    : AppTheme.gradientPrimary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLg),
                  topRight: Radius.circular(AppTheme.radiusLg),
                ),
              ),
              child: Text(
                isCurrentPlan ? 'خطتك الحالية' : 'الأكثر شعبية',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppTheme.fontSm,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.white,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppTheme.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: AppTheme.fontXl,
                    fontWeight: AppTheme.fontBold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: AppTheme.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.sm),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'ريال / $periodText',
                        style: const TextStyle(
                          fontSize: AppTheme.fontMd,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.lg),

                // Features
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.sm),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                      const SizedBox(width: AppTheme.sm),
                      Expanded(
                        child: Text(
                          feature.toString(),
                          style: const TextStyle(
                            fontSize: AppTheme.fontMd,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

                const SizedBox(height: AppTheme.md),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan ? null : () => _showUpgradeDialog(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan
                          ? AppTheme.textSecondary
                          : isPopular
                              ? AppTheme.primary
                              : AppTheme.surface,
                      foregroundColor: isCurrentPlan
                          ? AppTheme.white
                          : isPopular
                              ? AppTheme.white
                              : AppTheme.primary,
                      disabledBackgroundColor: AppTheme.textSecondary.withOpacity(0.3),
                      disabledForegroundColor: AppTheme.textSecondary,
                      side: isPopular || isCurrentPlan
                          ? null
                          : const BorderSide(color: AppTheme.primary, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: Text(
                      isCurrentPlan ? 'خطتك الحالية' : 'اختاري الخطة',
                      style: const TextStyle(
                        fontSize: AppTheme.fontMd,
                        fontWeight: AppTheme.fontBold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
        );
  }
}
