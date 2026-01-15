import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../constants/app_theme.dart';
import 'trainer_main_screen.dart';
import '../main.dart';
import 'login_screen.dart';

class RoleRouterScreen extends StatefulWidget {
  const RoleRouterScreen({super.key});

  @override
  State<RoleRouterScreen> createState() => _RoleRouterScreenState();
}

class _RoleRouterScreenState extends State<RoleRouterScreen> {
  bool _isLoading = true;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final isLoggedIn = await ApiService.isLoggedIn();
      final userType = await ApiService.getUserType();

      if (!isLoggedIn || userType == null) {
        // لا يوجد مستخدم مسجل، انتقل لشاشة تسجيل الدخول
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _userType = userType;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking user role: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // توجيه المستخدم بناءً على دوره
    if (_userType == null) {
      return const LoginScreen();
    }

    switch (_userType) {
      case 'admin':
      case 'super_admin':
        return const AdminRedirectScreen();
      case 'trainer':
        return const TrainerMainScreen();
      case 'trainee':
      default:
        return const MainScreen();
    }
  }
}

/// شاشة توجيه المشرف للوحة التحكم على الويب
class AdminRedirectScreen extends StatelessWidget {
  const AdminRedirectScreen({super.key});

  Future<void> _openAdminPanel() async {
    final uri = Uri.parse('https://vitafit.online/admin-panel/index');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _logout(BuildContext context) async {
    await ApiService.logout();
    await ApiService.removeToken();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientPrimary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 50,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: AppTheme.xl),
                const Text(
                  'لوحة تحكم المشرف',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: AppTheme.fontXxl,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.md),
                const Text(
                  'لوحة التحكم متاحة على المتصفح فقط',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: AppTheme.fontMd,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openAdminPanel,
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('فتح لوحة التحكم'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.md),
                TextButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout, color: AppTheme.error),
                  label: const Text(
                    'تسجيل الخروج',
                    style: TextStyle(color: AppTheme.error),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
