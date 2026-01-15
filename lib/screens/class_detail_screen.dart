import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/live_class.dart';

class ClassDetailScreen extends StatefulWidget {
  final LiveClass liveClass;

  const ClassDetailScreen({super.key, required this.liveClass});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  bool isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Header مع الصورة
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
                          _getCategoryIcon(widget.liveClass.category),
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
                            AppTheme.background.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                    ),
                    // مؤشر LIVE
                    if (widget.liveClass.isLive)
                      Positioned(
                        top: 60,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            boxShadow: AppTheme.shadowMd,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.white,
                                  shape: BoxShape.circle,
                                ),
                              )
                                  .animate(
                                    onPlay: (controller) =>
                                        controller.repeat(),
                                  )
                                  .fade(
                                    duration: 1000.ms,
                                    curve: Curves.easeInOut,
                                  ),
                              const SizedBox(width: 6),
                              const Text(
                                'مباشر',
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: AppTheme.fontSm,
                                  fontWeight: AppTheme.fontBold,
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
                icon: const Icon(Icons.arrow_forward, color: AppTheme.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: AppTheme.white,
                  ),
                  onPressed: () {
                    setState(() {
                      isBookmarked = !isBookmarked;
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
                    Text(
                      widget.liveClass.title,
                      style: const TextStyle(
                        fontSize: AppTheme.fontXxl,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.text,
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: AppTheme.md),

                    // معلومات المدرب
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.gradientSecondary,
                            boxShadow: AppTheme.shadowSm,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppTheme.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppTheme.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المدرب',
                              style: TextStyle(
                                fontSize: AppTheme.fontSm,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              widget.liveClass.instructor,
                              style: const TextStyle(
                                fontSize: AppTheme.fontMd,
                                fontWeight: AppTheme.fontSemibold,
                                color: AppTheme.text,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: AppTheme.lg),

                    // المعلومات السريعة
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.schedule,
                            label: 'الوقت',
                            value: widget.liveClass.time,
                            delay: 0,
                          ),
                        ),
                        const SizedBox(width: AppTheme.md),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.timer,
                            label: 'المدة',
                            value: '${widget.liveClass.duration} دقيقة',
                            delay: 100,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.md),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.signal_cellular_alt,
                            label: 'المستوى',
                            value: widget.liveClass.level,
                            delay: 200,
                          ),
                        ),
                        const SizedBox(width: AppTheme.md),
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.people,
                            label: 'المشاركين',
                            value: '${widget.liveClass.participants}+',
                            delay: 300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.xl),

                    // الوصف
                    const Text(
                      'حول الحصة',
                      style: TextStyle(
                        fontSize: AppTheme.fontLg,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                    Text(
                      _getClassDescription(widget.liveClass.category),
                      style: const TextStyle(
                        fontSize: AppTheme.fontMd,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: AppTheme.xl),

                    // ما ستحتاجينه
                    const Text(
                      'ما ستحتاجينه',
                      style: TextStyle(
                        fontSize: AppTheme.fontLg,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                    ..._getEquipmentList(widget.liveClass.category)
                        .asMap()
                        .entries
                        .map(
                          (entry) => _buildEquipmentItem(
                            entry.value,
                            entry.key,
                          ),
                        ),
                    const SizedBox(height: AppTheme.xl),

                    // الفوائد
                    const Text(
                      'الفوائد',
                      style: TextStyle(
                        fontSize: AppTheme.fontLg,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                    ..._getBenefitsList(widget.liveClass.category)
                        .asMap()
                        .entries
                        .map(
                          (entry) => _buildBenefitItem(
                            entry.value,
                            entry.key,
                          ),
                        ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        // زر الانضمام
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
                    // الانضمام للحصة
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم الانضمام للحصة بنجاح!'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.liveClass.isLive
                              ? Icons.play_circle_filled
                              : Icons.schedule,
                          color: AppTheme.white,
                        ),
                        const SizedBox(width: AppTheme.sm),
                        Text(
                          widget.liveClass.isLive
                              ? 'انضمي الآن'
                              : 'احجزي مكانك',
                          style: const TextStyle(
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

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primary,
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
            style: const TextStyle(
              fontSize: AppTheme.fontMd,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.text,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          delay: delay.ms,
        );
  }

  Widget _buildEquipmentItem(String item, int index) {
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
              item,
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

  Widget _buildBenefitItem(String benefit, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              gradient: AppTheme.gradientPrimary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Text(
              benefit,
              style: const TextStyle(
                fontSize: AppTheme.fontMd,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (600 + index * 50).ms);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'yoga':
        return Icons.self_improvement;
      case 'cardio':
        return Icons.favorite;
      case 'strength':
        return Icons.fitness_center;
      case 'dance':
        return Icons.music_note;
      default:
        return Icons.sports_gymnastics;
    }
  }

  String _getClassDescription(String category) {
    switch (category) {
      case 'yoga':
        return 'حصة يوغا شاملة تركز على التوازن والمرونة والاسترخاء. مناسبة لجميع المستويات وتساعد على تحسين القوة الداخلية والتركيز الذهني.';
      case 'cardio':
        return 'تمارين كارديو عالية الكثافة لحرق السعرات الحرارية وتحسين اللياقة القلبية. تمارين متنوعة وممتعة تناسب جميع المستويات.';
      case 'strength':
        return 'تمارين القوة لبناء العضلات وتحسين القوة البدنية. استخدام الأوزان والمقاومة لتحقيق أفضل النتائج في وقت قصير.';
      case 'dance':
        return 'حصة رقص ممتعة تجمع بين اللياقة والموسيقى. طريقة رائعة لحرق السعرات مع الاستمتاع بالحركة والإيقاع.';
      default:
        return 'حصة تدريبية متكاملة تركز على تحسين اللياقة البدنية العامة والصحة.';
    }
  }

  List<String> _getEquipmentList(String category) {
    switch (category) {
      case 'yoga':
        return ['سجادة يوغا', 'مكعبات يوغا (اختياري)', 'حزام يوغا (اختياري)', 'ملابس مريحة'];
      case 'cardio':
        return ['حذاء رياضي مريح', 'زجاجة ماء', 'منشفة', 'ملابس رياضية'];
      case 'strength':
        return ['دمبلز (2-5 كجم)', 'حزام مقاومة', 'سجادة تمرين', 'زجاجة ماء'];
      case 'dance':
        return ['حذاء رياضي خفيف', 'ملابس مريحة للحركة', 'زجاجة ماء', 'منشفة'];
      default:
        return ['سجادة تمرين', 'زجاجة ماء', 'ملابس رياضية'];
    }
  }

  List<String> _getBenefitsList(String category) {
    switch (category) {
      case 'yoga':
        return [
          'تحسين المرونة والتوازن',
          'تقليل التوتر والقلق',
          'تقوية العضلات الأساسية',
          'تحسين التركيز والوعي الذهني',
          'تحسين وضعية الجسم',
        ];
      case 'cardio':
        return [
          'حرق السعرات الحرارية بكفاءة',
          'تحسين صحة القلب والأوعية الدموية',
          'زيادة القدرة على التحمل',
          'تحسين المزاج وإفراز الإندورفين',
          'تعزيز عملية الأيض',
        ];
      case 'strength':
        return [
          'بناء وتقوية العضلات',
          'تحسين كثافة العظام',
          'زيادة معدل الأيض الأساسي',
          'تحسين القوة البدنية العامة',
          'نحت وتشكيل الجسم',
        ];
      case 'dance':
        return [
          'حرق السعرات بطريقة ممتعة',
          'تحسين التناسق والتوازن',
          'تعزيز المرونة والرشاقة',
          'تحسين الحالة المزاجية',
          'تعلم حركات وإيقاعات جديدة',
        ];
      default:
        return [
          'تحسين اللياقة البدنية العامة',
          'تعزيز الصحة النفسية',
          'زيادة الطاقة والحيوية',
        ];
    }
  }
}
