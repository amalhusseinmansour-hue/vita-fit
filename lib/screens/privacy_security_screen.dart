import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import 'delete_account_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_conditions_screen.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;
  bool _shareDataWithTrainers = true;
  bool _showProfilePublicly = false;
  bool _allowNotifications = true;

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
            'الخصوصية والأمان',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: AppTheme.fontXl,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security Section
              const Text(
                'الأمان',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: AppTheme.fontLg,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: AppTheme.md),

              _buildSecurityItem(
                icon: Icons.fingerprint,
                title: 'تسجيل الدخول بالبصمة',
                subtitle: 'استخدم البصمة أو Face ID للدخول السريع',
                value: _biometricEnabled,
                onChanged: (val) => setState(() => _biometricEnabled = val),
                delay: 100,
              ),

              _buildSecurityItem(
                icon: Icons.security,
                title: 'التحقق بخطوتين',
                subtitle: 'أضف طبقة حماية إضافية لحسابك',
                value: _twoFactorEnabled,
                onChanged: (val) => setState(() => _twoFactorEnabled = val),
                delay: 150,
              ),

              _buildActionItem(
                icon: Icons.lock_outline,
                title: 'تغيير كلمة المرور',
                subtitle: 'تحديث كلمة مرور حسابك',
                onTap: () => _showChangePasswordDialog(),
                delay: 200,
              ),

              _buildActionItem(
                icon: Icons.devices,
                title: 'الأجهزة المتصلة',
                subtitle: 'إدارة الأجهزة المسجلة في حسابك',
                onTap: () => _showDevicesDialog(),
                delay: 250,
              ),

              const SizedBox(height: AppTheme.xl),

              // Privacy Section
              const Text(
                'الخصوصية',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: AppTheme.fontLg,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: AppTheme.md),

              _buildSecurityItem(
                icon: Icons.share,
                title: 'مشاركة البيانات مع المدربات',
                subtitle: 'السماح للمدربات برؤية تقدمك',
                value: _shareDataWithTrainers,
                onChanged: (val) => setState(() => _shareDataWithTrainers = val),
                delay: 350,
              ),

              _buildSecurityItem(
                icon: Icons.visibility,
                title: 'الملف الشخصي العام',
                subtitle: 'إظهار ملفك للمستخدمين الآخرين',
                value: _showProfilePublicly,
                onChanged: (val) => setState(() => _showProfilePublicly = val),
                delay: 400,
              ),

              _buildSecurityItem(
                icon: Icons.notifications,
                title: 'الإشعارات',
                subtitle: 'السماح بإرسال الإشعارات',
                value: _allowNotifications,
                onChanged: (val) => setState(() => _allowNotifications = val),
                delay: 450,
              ),

              const SizedBox(height: AppTheme.xl),

              // Data Section
              const Text(
                'البيانات',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: AppTheme.fontLg,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: AppTheme.md),

              _buildActionItem(
                icon: Icons.download,
                title: 'تحميل بياناتي',
                subtitle: 'الحصول على نسخة من بياناتك',
                onTap: () => _showDownloadDataDialog(),
                delay: 550,
              ),

              _buildActionItem(
                icon: Icons.delete_forever,
                title: 'حذف الحساب',
                subtitle: 'حذف حسابك وجميع بياناتك نهائياً',
                onTap: () => _showDeleteAccountDialog(),
                isDestructive: true,
                delay: 600,
              ),

              const SizedBox(height: AppTheme.xl),

              // Privacy Policy
              Container(
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
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
                      trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary, size: 16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                      ),
                    ),
                    const Divider(color: AppTheme.border),
                    ListTile(
                      leading: const Icon(Icons.description, color: AppTheme.primary),
                      title: const Text(
                        'شروط الاستخدام',
                        style: TextStyle(color: AppTheme.white),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary, size: 16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsConditionsScreen()),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 650.ms),

              const SizedBox(height: AppTheme.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.sm),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(AppTheme.sm),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: AppTheme.fontSm,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.sm),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: isDestructive ? AppTheme.error.withOpacity(0.3) : AppTheme.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.sm),
          decoration: BoxDecoration(
            color: (isDestructive ? AppTheme.error : AppTheme.primary).withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Icon(icon, color: isDestructive ? AppTheme.error : AppTheme.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? AppTheme.error : AppTheme.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: AppTheme.fontSm,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isDestructive ? AppTheme.error : AppTheme.textSecondary,
          size: 16,
        ),
        onTap: onTap,
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('تغيير كلمة المرور', style: TextStyle(color: AppTheme.white)),
        content: const Text(
          'سيتم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال رابط إعادة التعيين'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('إرسال', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );
  }

  void _showDevicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('الأجهزة المتصلة', style: TextStyle(color: AppTheme.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDeviceItem('هذا الجهاز', 'Samsung Galaxy', true),
            _buildDeviceItem('iPhone 14', 'آخر دخول: منذ يومين', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(String name, String subtitle, bool isCurrent) {
    return ListTile(
      leading: Icon(
        Icons.phone_android,
        color: isCurrent ? AppTheme.success : AppTheme.textSecondary,
      ),
      title: Text(name, style: const TextStyle(color: AppTheme.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary)),
      trailing: isCurrent
          ? const Chip(
              label: Text('الحالي', style: TextStyle(fontSize: 10)),
              backgroundColor: AppTheme.success,
            )
          : IconButton(
              icon: const Icon(Icons.logout, color: AppTheme.error),
              onPressed: () {},
            ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('تحميل البيانات', style: TextStyle(color: AppTheme.white)),
        content: const Text(
          'سيتم إرسال نسخة من بياناتك إلى بريدك الإلكتروني خلال 24 ساعة',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم طلب تحميل البيانات'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('طلب التحميل', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeleteAccountScreen()),
    );
  }

  void _showDownloadDataDialogWithApi() async {
    final result = await ApiService.requestDataExport();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'تم طلب تحميل البيانات'),
          backgroundColor: result['success'] == true ? AppTheme.success : AppTheme.error,
        ),
      );
    }
  }
}
