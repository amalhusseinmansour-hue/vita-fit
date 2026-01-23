import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/hive_storage_service.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';
import '../services/apple_sign_in_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isAppleLoading = false;
  bool _rememberMe = true;
  bool _isAppleAvailable = false;
  String _userType = 'trainee';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _checkAppleSignInAvailability();
    // Track screen view - disabled temporarily
    // FirebaseService.logScreenView('login_screen');
  }

  Future<void> _checkAppleSignInAvailability() async {
    try {
      if (Platform.isIOS) {
        final available = await AppleSignInService.isAvailable();
        if (mounted) {
          setState(() => _isAppleAvailable = available);
        }
      }
    } catch (e) {
      debugPrint('Apple Sign In check error: $e');
    }
  }

  Future<void> _loadSavedCredentials() async {
    final savedEmail = HiveStorageService.getString('saved_email');
    final savedPassword = HiveStorageService.getString('saved_password');
    final rememberMe = HiveStorageService.getBool('remember_me') ?? false;

    if (rememberMe && savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    if (_rememberMe) {
      await HiveStorageService.setString('saved_email', _emailController.text.trim());
      await HiveStorageService.setString('saved_password', _passwordController.text);
      await HiveStorageService.setBool('remember_me', true);
    } else {
      await HiveStorageService.remove('saved_email');
      await HiveStorageService.remove('saved_password');
      await HiveStorageService.setBool('remember_me', false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final result = await ApiService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          userType: _userType,
        );

        setState(() => _isLoading = false);

        if (!mounted) return;

        if (result['success'] == true) {
          // Save credentials if remember me is checked
          await _saveCredentials();

          final responseData = result['data'] ?? result;
          final token = responseData['token'] ?? result['token'];
          final userData = responseData['user'] ?? result['user'];
          // Check for 'type' first (Laravel API format), then 'role'
          final userRole = userData?['type'] ?? userData?['role'] ?? _userType;

          if (token != null) {
            await ApiService.saveToken(token);
          }

          // Save user type and full user data
          await ApiService.saveUserType(userRole);
          if (userData != null) {
            await ApiService.saveUserData(userData);
          }

          // Save user data to Hive for quick access
          await HiveStorageService.setString('userId', userData?['id']?.toString() ?? '');
          await HiveStorageService.setString('userName', userData?['name'] ?? '');
          await HiveStorageService.setString('userEmail', userData?['email'] ?? '');
          await HiveStorageService.setString('userPhone', userData?['phone'] ?? '');
          await HiveStorageService.setString('userAvatar', userData?['avatar'] ?? '');
          await HiveStorageService.setString('userRole', userRole);
          await HiveStorageService.setBool('isLoggedIn', true);

          // Save additional user data
          if (userData?['height'] != null) {
            await HiveStorageService.setDouble('userHeight', (userData['height'] as num).toDouble());
          }
          if (userData?['weight'] != null) {
            await HiveStorageService.setDouble('userWeight', (userData['weight'] as num).toDouble());
          }
          if (userData?['goal'] != null) {
            await HiveStorageService.setString('userGoal', userData['goal']);
          }
          if (userData?['activity_level'] != null) {
            await HiveStorageService.setString('userActivityLevel', userData['activity_level']);
          }

          // Track successful login
          FirebaseService.logLogin(_userType);
          if (userData?['id'] != null) {
            FirebaseService.setUserId(userData['id'].toString());
            FirebaseService.setCrashlyticsUser(userData['id'].toString());
          }

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showErrorDialog(
            result['message'] ?? 'فشل تسجيل الدخول. حاول مرة أخرى',
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);

        if (mounted) {
          String errorMessage = 'حدث خطأ في الاتصال بالخادم';
          if (e.toString().contains('TimeoutException')) {
            errorMessage = 'انتهت مهلة الاتصال. تأكد من اتصالك بالإنترنت';
          } else if (e.toString().contains('SocketException')) {
            errorMessage = 'لا يمكن الاتصال بالخادم. تأكد من اتصالك بالإنترنت';
          } else if (e.toString().contains('HandshakeException')) {
            errorMessage = 'خطأ في الاتصال الآمن. حاول مرة أخرى';
          }
          print('Login exception: $e');
          _showErrorDialog(errorMessage);
        }
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isAppleLoading = true);

    try {
      final result = await AppleSignInService.signIn();

      setState(() => _isAppleLoading = false);

      if (!mounted) return;

      if (result['success'] == true) {
        final userData = result['user'];

        // Save user data
        await HiveStorageService.setString('userId', userData?['id']?.toString() ?? '');
        await HiveStorageService.setString('userName', userData?['name'] ?? '');
        await HiveStorageService.setString('userEmail', userData?['email'] ?? '');
        await HiveStorageService.setString('userRole', userData?['role'] ?? 'trainee');
        await HiveStorageService.setBool('isLoggedIn', true);

        // Track successful login
        FirebaseService.logLogin('apple');
        if (userData?['id'] != null) {
          FirebaseService.setUserId(userData['id'].toString());
          FirebaseService.setCrashlyticsUser(userData['id'].toString());
        }

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorDialog(result['message'] ?? 'فشل تسجيل الدخول بـ Apple');
      }
    } catch (e) {
      setState(() => _isAppleLoading = false);
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'خطأ',
          style: TextStyle(color: AppTheme.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(color: AppTheme.primary),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A0E2E),
              const Color(0xFF2D1B3D),
              AppTheme.primaryDark.withValues(alpha: 0.3),
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
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primary.withValues(alpha: 0.4),
                            AppTheme.primaryDark.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.6),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primary.withValues(alpha: 0.3),
                              AppTheme.secondary.withValues(alpha: 0.2),
                            ],
                          ),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 70,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        )
                        .then()
                        .shimmer(
                          duration: 2000.ms,
                          color: AppTheme.white.withValues(alpha: 0.3),
                        ),

                    const SizedBox(height: AppTheme.xl),

                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppTheme.primary,
                          AppTheme.secondary,
                          AppTheme.accent,
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'VITAFIT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),

                    const SizedBox(height: AppTheme.sm),

                    // Subtitle
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.lg,
                        vertical: AppTheme.sm,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withValues(alpha: 0.1),
                            AppTheme.secondary.withValues(alpha: 0.1),
                          ],
                        ),
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'انضمي لنا… وبنكون معك في كل خطوة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.fontMd,
                          height: 1.5,
                        ),
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

                    // User Type Selector
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(
                          color: AppTheme.border.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _userType = 'trainee'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: _userType == 'trainee'
                                      ? const LinearGradient(
                                          colors: [AppTheme.primary, AppTheme.primaryDark],
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 20,
                                      color: _userType == 'trainee'
                                          ? AppTheme.white
                                          : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'متدربة',
                                      style: TextStyle(
                                        color: _userType == 'trainee'
                                            ? AppTheme.white
                                            : AppTheme.textSecondary,
                                        fontWeight: _userType == 'trainee'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: AppTheme.fontMd,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _userType = 'trainer'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: _userType == 'trainer'
                                      ? const LinearGradient(
                                          colors: [AppTheme.secondary, AppTheme.primary],
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.fitness_center,
                                      size: 20,
                                      color: _userType == 'trainer'
                                          ? AppTheme.white
                                          : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'مدربة',
                                      style: TextStyle(
                                        color: _userType == 'trainer'
                                            ? AppTheme.white
                                            : AppTheme.textSecondary,
                                        fontWeight: _userType == 'trainer'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: AppTheme.fontMd,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 450.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
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
                        .fadeIn(delay: 500.ms, duration: 600.ms)
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
                        .fadeIn(delay: 600.ms, duration: 600.ms)
                        .slideX(
                          begin: -0.2,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: AppTheme.md),

                    // Remember Me & Forgot Password Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember Me Checkbox
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: AppTheme.primary,
                                checkColor: AppTheme.white,
                                side: BorderSide(
                                  color: AppTheme.primary.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: const Text(
                                'تذكرني',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: AppTheme.fontMd,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Forgot Password
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'نسيت كلمة المرور؟',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: AppTheme.fontMd,
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 600.ms),

                    const SizedBox(height: AppTheme.lg),

                    // Login Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primary,
                            AppTheme.primaryDark,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppTheme.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
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
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontSize: AppTheme.fontLg,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.sm),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 22,
                                  ),
                                ],
                              ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 600.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        )
                        .then()
                        .shimmer(
                          duration: 2000.ms,
                          color: AppTheme.white.withValues(alpha: 0.3),
                        ),

                    const SizedBox(height: AppTheme.xl),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.8),
                            fontSize: AppTheme.fontMd,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'إنشاء حساب',
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
                        .fadeIn(delay: 900.ms, duration: 600.ms),

                    // Apple Sign In Button (iOS only)
                    if (_isAppleAvailable) ...[
                      const SizedBox(height: AppTheme.lg),

                      // Divider with "or"
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppTheme.border.withValues(alpha: 0.3),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
                            child: Text(
                              'أو',
                              style: TextStyle(
                                color: AppTheme.textSecondary.withValues(alpha: 0.7),
                                fontSize: AppTheme.fontMd,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppTheme.border.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 950.ms, duration: 600.ms),

                      const SizedBox(height: AppTheme.lg),

                      // Apple Sign In Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          color: AppTheme.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isAppleLoading ? null : _handleAppleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.black,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                          ),
                          child: _isAppleLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.apple,
                                      size: 28,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: AppTheme.sm),
                                    Text(
                                      'تسجيل الدخول بـ Apple',
                                      style: TextStyle(
                                        fontSize: AppTheme.fontLg,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
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
                    ],
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
