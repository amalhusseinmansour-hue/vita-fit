import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class TrainerReportsScreen extends StatefulWidget {
  const TrainerReportsScreen({super.key});

  @override
  State<TrainerReportsScreen> createState() => _TrainerReportsScreenState();
}

class _TrainerReportsScreenState extends State<TrainerReportsScreen> {
  bool _isLoading = true;
  String _selectedPeriod = 'شهري';

  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _monthlyData = [];
  List<Map<String, dynamic>> _topClients = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      final reports = await ApiService.getTrainerReports();

      setState(() {
        _stats = reports['stats'] ?? {};
        _monthlyData = List<Map<String, dynamic>>.from(reports['monthlyData'] ?? []);
        _topClients = List<Map<String, dynamic>>.from(reports['topClients'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  int _getCompletionRate() {
    final completed = _stats['completedSessions'] ?? 0;
    final total = _stats['totalSessions'] ?? 1;
    if (total == 0) return 0;
    return ((completed / total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppTheme.lg),
                decoration: const BoxDecoration(
                  gradient: AppTheme.gradientPrimary,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'تقاريري',
                          style: TextStyle(
                            fontSize: AppTheme.fontXl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _loadReports,
                          icon: const Icon(Icons.refresh, color: AppTheme.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.md),
                    // Period Selector
                    Row(
                      children: [
                        _buildPeriodChip('يومي'),
                        const SizedBox(width: AppTheme.sm),
                        _buildPeriodChip('أسبوعي'),
                        const SizedBox(width: AppTheme.sm),
                        _buildPeriodChip('شهري'),
                        const SizedBox(width: AppTheme.sm),
                        _buildPeriodChip('سنوي'),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(AppTheme.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main Stats
                            const Text(
                              'نظرة عامة',
                              style: TextStyle(
                                fontSize: AppTheme.fontLg,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'إجمالي المتدربات',
                                    '${_stats['totalClients'] ?? 0}',
                                    Icons.people,
                                    AppTheme.primary,
                                    AppTheme.gradientPrimary,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.md),
                                Expanded(
                                  child: _buildStatCard(
                                    'متدربات نشطات',
                                    '${_stats['activeClients'] ?? 0}',
                                    Icons.check_circle,
                                    AppTheme.success,
                                    AppTheme.gradientMint,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'الحصص المنجزة',
                                    '${_stats['completedSessions'] ?? 0}',
                                    Icons.fitness_center,
                                    AppTheme.secondary,
                                    AppTheme.gradientSecondary,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.md),
                                Expanded(
                                  child: _buildStatCard(
                                    'معدل الإنجاز',
                                    '${_getCompletionRate()}%',
                                    Icons.trending_up,
                                    AppTheme.info,
                                    AppTheme.gradientLavender,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppTheme.lg),

                            // Rating & Reviews
                            const Text(
                              'التقييم',
                              style: TextStyle(
                                fontSize: AppTheme.fontLg,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            Container(
                              padding: const EdgeInsets.all(AppTheme.lg),
                              decoration: BoxDecoration(
                                gradient: AppTheme.gradientPeach,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                boxShadow: AppTheme.shadowSm,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 48,
                                  ),
                                  const SizedBox(width: AppTheme.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_stats['averageRating'] ?? 0.0}',
                                          style: const TextStyle(
                                            fontSize: AppTheme.fontXxl,
                                            fontWeight: AppTheme.fontBold,
                                            color: AppTheme.white,
                                          ),
                                        ),
                                        Text(
                                          'من 5.0 (${_stats['totalReviews'] ?? 0} تقييم)',
                                          style: TextStyle(
                                            fontSize: AppTheme.fontSm,
                                            color: AppTheme.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        '${_stats['clientSatisfaction'] ?? 0}%',
                                        style: const TextStyle(
                                          fontSize: AppTheme.fontXl,
                                          fontWeight: AppTheme.fontBold,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                      const Text(
                                        'مؤشر الرضا',
                                        style: TextStyle(
                                          fontSize: AppTheme.fontXs,
                                          fontWeight: AppTheme.fontBold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 100.ms),

                            const SizedBox(height: AppTheme.lg),

                            // Earnings
                            const Text(
                              'الإيرادات',
                              style: TextStyle(
                                fontSize: AppTheme.fontLg,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            Container(
                              padding: const EdgeInsets.all(AppTheme.lg),
                              decoration: BoxDecoration(
                                gradient: AppTheme.gradientPrimary,
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                boxShadow: AppTheme.shadowSm,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    color: AppTheme.white,
                                    size: 48,
                                  ),
                                  const SizedBox(width: AppTheme.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_stats['monthlyEarnings'] ?? 0} AED',
                                          style: const TextStyle(
                                            fontSize: AppTheme.fontXxl,
                                            fontWeight: AppTheme.fontBold,
                                            color: AppTheme.white,
                                          ),
                                        ),
                                        Text(
                                          'الإيرادات الشهرية',
                                          style: TextStyle(
                                            fontSize: AppTheme.fontSm,
                                            color: AppTheme.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 150.ms),

                            const SizedBox(height: AppTheme.lg),

                            // Monthly Performance Chart
                            const Text(
                              'الأداء الشهري',
                              style: TextStyle(
                                fontSize: AppTheme.fontLg,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            _buildPerformanceChart(),

                            const SizedBox(height: AppTheme.lg),

                            // Top Clients
                            const Text(
                              'نجمات الأداء',
                              style: TextStyle(
                                fontSize: AppTheme.fontLg,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            ..._topClients.asMap().entries.map((entry) {
                              return _buildTopClientCard(
                                entry.value,
                                entry.key,
                              );
                            }),

                            const SizedBox(height: AppTheme.lg),

                            // Additional Stats
                            const Text(
                              'إحصائيات إضافية',
                              style: TextStyle(
                                fontSize: AppTheme.fontLg,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            _buildInfoCard(
                              'حصص هذا الأسبوع',
                              '${_stats['thisWeekSessions'] ?? 0} حصة',
                              Icons.event,
                            ),
                            const SizedBox(height: AppTheme.md),
                            _buildInfoCard(
                              'الحصص المؤجلة',
                              '${_stats['postponedSessions'] ?? 0} حصة',
                              Icons.schedule,
                            ),
                            const SizedBox(height: AppTheme.md),
                            _buildInfoCard(
                              'الحصص الملغاة',
                              '${_stats['cancelledSessions'] ?? 0} حصة',
                              Icons.cancel,
                            ),
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

  Widget _buildPeriodChip(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.md,
          vertical: AppTheme.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.white
              : AppTheme.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Text(
          period,
          style: TextStyle(
            fontSize: AppTheme.fontSm,
            fontWeight: AppTheme.fontMedium,
            color: isSelected ? AppTheme.primary : AppTheme.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    LinearGradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.white, size: 32),
          const SizedBox(height: AppTheme.md),
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
            title,
            style: TextStyle(
              fontSize: AppTheme.fontSm,
              color: AppTheme.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildPerformanceChart() {
    if (_monthlyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.lg),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: const Center(
          child: Text(
            'لا توجد بيانات حالياً',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    final maxSessions = _monthlyData.map((e) => (e['sessions'] as int?) ?? 0).reduce(
          (a, b) => a > b ? a : b,
        );
    if (maxSessions == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(AppTheme.lg),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _monthlyData.map((data) {
              final sessions = (data['sessions'] as int?) ?? 0;
              final height = (sessions / maxSessions) * 120;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Text(
                        '$sessions',
                        style: const TextStyle(
                          fontSize: AppTheme.fontXs,
                          color: AppTheme.textSecondary,
                          fontWeight: AppTheme.fontBold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: height,
                        decoration: BoxDecoration(
                          gradient: AppTheme.gradientPrimary,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppTheme.radiusSm),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.sm),
                      Text(
                        data['month'] ?? '',
                        style: const TextStyle(
                          fontSize: AppTheme.fontXs,
                          color: AppTheme.white,
                          fontWeight: AppTheme.fontMedium,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${(((data['earnings'] as int?) ?? 0) / 1000).toStringAsFixed(0)}K',
                        style: const TextStyle(
                          fontSize: AppTheme.fontXs,
                          color: AppTheme.primary,
                          fontWeight: AppTheme.fontBold,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().slideY(
                    begin: 1,
                    end: 0,
                    delay: (_monthlyData.indexOf(data) * 100).ms,
                  );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopClientCard(Map<String, dynamic> client, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.md),
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: index == 0
                  ? AppTheme.gradientPrimary
                  : index == 1
                      ? AppTheme.gradientSecondary
                      : AppTheme.gradientLavender,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client['name'] ?? 'متدربة',
                  style: const TextStyle(
                    fontSize: AppTheme.fontMd,
                    fontWeight: AppTheme.fontBold,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.fitness_center, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${client['sessions'] ?? 0} حصة',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSm,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${client['rating'] ?? 0.0}',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${client['progress'] ?? 0}%',
                style: const TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: AppTheme.fontBold,
                  color: AppTheme.primary,
                ),
              ),
              const Text(
                'التقدم',
                style: TextStyle(
                  fontSize: AppTheme.fontXs,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms);
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.sm),
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimary,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: AppTheme.white, size: 24),
          ),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppTheme.fontSm,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: AppTheme.fontMd,
                    fontWeight: AppTheme.fontBold,
                    color: AppTheme.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
