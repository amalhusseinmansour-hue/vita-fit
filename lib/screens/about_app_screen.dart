import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_theme.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'حول التطبيق',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: AppTheme.fontXl,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.xl),

              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPrimary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  boxShadow: AppTheme.shadowLg,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  child: Image.asset(
                    'assets/icons/logo.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.fitness_center,
                      color: AppTheme.white,
                      size: 60,
                    ),
                  ),
                ),
              ).animate().scale(duration: 500.ms),

              const SizedBox(height: AppTheme.lg),

              // App Name
              const Text(
                'VitaFit',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppTheme.sm),

              // Version
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.md,
                  vertical: AppTheme.xs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Text(
                  'الإصدار 1.0.0',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: AppTheme.fontSm,
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: AppTheme.xl),

              // Description
              Container(
                padding: const EdgeInsets.all(AppTheme.lg),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Column(
                  children: [
                    Text(
                      'تطبيق VitaFit هو رفيقك المثالي في رحلة اللياقة البدنية. نقدم لك برامج تمارين متخصصة، خطط غذائية متوازنة، ومتابعة شخصية مع أفضل المدربات.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.fontMd,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: AppTheme.xl),

              // Features
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'مميزات التطبيق',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: AppTheme.fontLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: AppTheme.md),

              _buildFeatureItem(
                icon: Icons.fitness_center,
                title: 'برامج تمارين متنوعة',
                subtitle: 'تمارين مصممة خصيصاً لاحتياجاتك',
                delay: 550,
              ),
              _buildFeatureItem(
                icon: Icons.restaurant_menu,
                title: 'خطط غذائية صحية',
                subtitle: 'وجبات متوازنة لتحقيق أهدافك',
                delay: 600,
              ),
              _buildFeatureItem(
                icon: Icons.videocam,
                title: 'جلسات أونلاين',
                subtitle: 'تدريب مباشر مع المدربات',
                delay: 650,
              ),
              _buildFeatureItem(
                icon: Icons.track_changes,
                title: 'تتبع التقدم',
                subtitle: 'راقبي تطورك بشكل مستمر',
                delay: 700,
              ),
              _buildFeatureItem(
                icon: Icons.shopping_bag,
                title: 'متجر متكامل',
                subtitle: 'منتجات رياضية ومكملات غذائية',
                delay: 750,
              ),

              const SizedBox(height: AppTheme.xl),

              // Social Media
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'تابعينا',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: AppTheme.fontLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
              const SizedBox(height: AppTheme.md),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    icon: Icons.language,
                    label: 'الموقع',
                    color: AppTheme.primary,
                    onTap: () => _launchUrl('https://vitafit.online'),
                  ),
                  const SizedBox(width: AppTheme.md),
                  _buildSocialButton(
                    icon: Icons.camera_alt,
                    label: 'انستغرام',
                    color: const Color(0xFFE1306C),
                    onTap: () => _launchUrl('https://instagram.com/vitafit'),
                  ),
                  const SizedBox(width: AppTheme.md),
                  _buildSocialButton(
                    icon: Icons.play_circle,
                    label: 'تيك توك',
                    color: const Color(0xFF000000),
                    onTap: () => _launchUrl('https://tiktok.com/@vitafit'),
                  ),
                  const SizedBox(width: AppTheme.md),
                  _buildSocialButton(
                    icon: Icons.chat,
                    label: 'تويتر',
                    color: const Color(0xFF1DA1F2),
                    onTap: () => _launchUrl('https://twitter.com/vitafit'),
                  ),
                ],
              ).animate().fadeIn(delay: 850.ms),

              const SizedBox(height: AppTheme.xl),

              // Legal
              Container(
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.policy, color: AppTheme.primary),
                      title: const Text(
                        'سياسة الخصوصية',
                        style: TextStyle(color: AppTheme.white),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      ),
                    ),
                    const Divider(color: AppTheme.border),
                    ListTile(
                      leading: const Icon(Icons.description, color: AppTheme.primary),
                      title: const Text(
                        'شروط الاستخدام',
                        style: TextStyle(color: AppTheme.white),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsConditionsScreen(),
                        ),
                      ),
                    ),
                    const Divider(color: AppTheme.border),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: AppTheme.primary),
                      title: const Text(
                        'التراخيص',
                        style: TextStyle(color: AppTheme.white),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: 'VitaFit',
                        applicationVersion: '1.0.0',
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 900.ms),

              const SizedBox(height: AppTheme.xl),

              // Copyright
              const Text(
                '© 2024 VitaFit. جميع الحقوق محفوظة',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.fontSm,
                ),
              ).animate().fadeIn(delay: 950.ms),

              const SizedBox(height: AppTheme.sm),

              const Text(
                'صنع بحب في المملكة العربية السعودية',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.fontXs,
                ),
              ).animate().fadeIn(delay: 1000.ms),

              const SizedBox(height: AppTheme.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
  }) {
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
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.fontSm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.fontXs,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
