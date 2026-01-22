import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/hive_storage_service.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import 'email_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب الموافقة على الشروط والأحكام'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Call real API
        final result = await ApiService.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        setState(() => _isLoading = false);

        if (!mounted) return;

        if (result['success'] == true) {
          // Check if email verification is required
          final requiresVerification = result['requires_verification'] == true ||
              result['data']?['requires_verification'] == true;
          final email = result['email'] ?? result['data']?['email'] ?? _emailController.text.trim();

          if (requiresVerification) {
            // Navigate to email verification screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إرسال رمز التحقق إلى بريدك الإلكتروني'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmailVerificationScreen(
                  email: email,
                  name: _nameController.text.trim(),
                ),
              ),
            );
          } else {
            // Token and user are inside result['data']
            final responseData = result['data'];
            final token = responseData?['token'];
            final userData = responseData?['user'];

            if (token != null) {
              await ApiService.saveToken(token);
            }

            // Save user data
            await HiveStorageService.setString('userId', userData?['id']?.toString() ?? '');
            await HiveStorageService.setString('userName', userData?['name'] ?? '');
            await HiveStorageService.setString('userEmail', userData?['email'] ?? '');
            await HiveStorageService.setString('userRole', userData?['role'] ?? 'user');
            await HiveStorageService.setBool('isLoggedIn', true);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إنشاء الحساب بنجاح!'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to home
            Navigator.pushReplacementNamed(context, '/home');
          }
        } else {
          // Show error dialog for better visibility
          _showErrorDialog(result['message'] ?? 'فشل إنشاء الحساب');
        }
      } catch (e) {
        setState(() => _isLoading = false);

        if (mounted) {
          _showErrorDialog('حدث خطأ في الاتصال بالخادم');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.error, size: 28),
            SizedBox(width: 8),
            Text(
              'خطأ',
              style: TextStyle(color: AppTheme.white),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(color: AppTheme.primary, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.background,
              AppTheme.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.xl),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.shadowGlow,
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 50,
                        color: AppTheme.primary,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),

                    const SizedBox(height: AppTheme.xl),

                    // Title
                    const Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: AppTheme.sm),

                    // Subtitle
                    Text(
                      'انضم إلينا وابدأ رحلتك',
                      style: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.8),
                        fontSize: AppTheme.fontLg,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: AppTheme.xl * 2),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: AppTheme.white),
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل',
                        labelStyle: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.7),
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: AppTheme.primary,
                        ),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: BorderSide(
                            color: AppTheme.border.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الاسم';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 600.ms)
                        .slideX(
                          begin: -0.2,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: AppTheme.lg),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppTheme.white),
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        labelStyle: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.7),
                        ),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppTheme.primary,
                        ),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: BorderSide(
                            color: AppTheme.border.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال البريد الإلكتروني';
                        }
                        if (!value.contains('@')) {
                          return 'الرجاء إدخال بريد إلكتروني صحيح';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 600.ms)
                        .slideX(
                          begin: -0.2,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: AppTheme.lg),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: AppTheme.white),
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        labelStyle: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.7),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppTheme.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: BorderSide(
                            color: AppTheme.border.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال كلمة المرور';
                        }
                        if (value.length < 6) {
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 600.ms)
                        .slideX(
                          begin: -0.2,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: AppTheme.lg),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: const TextStyle(color: AppTheme.white),
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور',
                        labelStyle: TextStyle(
                          color: AppTheme.textSecondary.withValues(alpha: 0.7),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppTheme.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: BorderSide(
                            color: AppTheme.border.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          borderSide: const BorderSide(
                            color: AppTheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء تأكيد كلمة المرور';
                        }
                        if (value != _passwordController.text) {
                          return 'كلمة المرور غير متطابقة';
                        }
                        return null;
                      },
                    )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 600.ms)
                        .slideX(
                          begin: -0.2,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: AppTheme.lg),

                    // Terms Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                          activeColor: AppTheme.primary,
                          checkColor: AppTheme.white,
                        ),
                        Expanded(
                          child: Text(
                            'أوافق على الشروط والأحكام وسياسة الخصوصية',
                            style: TextStyle(
                              color:
                                  AppTheme.textSecondary.withValues(alpha: 0.8),
                              fontSize: AppTheme.fontSm,
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 900.ms, duration: 600.ms),

                    const SizedBox(height: AppTheme.xl),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.md + 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppTheme.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'إنشاء حساب',
                                style: TextStyle(
                                  fontSize: AppTheme.fontLg,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 1000.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: AppTheme.xl),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لديك حساب بالفعل؟',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.8),
                            fontSize: AppTheme.fontMd,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: AppTheme.fontMd,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 1100.ms, duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
