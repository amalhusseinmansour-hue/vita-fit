import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../services/admin_notification_service.dart';
import 'trainer_pending_screen.dart';

class TrainerSignupScreen extends StatefulWidget {
  const TrainerSignupScreen({super.key});

  @override
  State<TrainerSignupScreen> createState() => _TrainerSignupScreenState();
}

class _TrainerSignupScreenState extends State<TrainerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;

  String? _selectedSpecialty;
  final List<String> _selectedCertifications = [];

  final List<String> _specialties = [
    'لياقة بدنية',
    'يوغا',
    'بيلاتس',
    'تغذية',
    'تمارين المقاومة',
    'كارديو',
    'تمارين ما بعد الولادة',
    'كروس فيت',
    'أخرى',
  ];

  final List<String> _certifications = [
    'NASM',
    'ACE',
    'ISSA',
    'ACSM',
    'NSCA',
    'شهادة معتمدة محلياً',
    'أخرى',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
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

    if (_selectedSpecialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار التخصص'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final experienceYears = int.tryParse(_experienceController.text) ?? 0;

        // Call API to register trainer
        final result = await ApiService.registerTrainer(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          specialty: _selectedSpecialty!,
          experienceYears: experienceYears,
          certifications: _selectedCertifications,
          bio: _bioController.text.trim(),
        );

        if (!mounted) return;

        if (result['success'] == true) {
          // Send notifications to admin
          await AdminNotificationService.notifyNewTrainerRegistration(
            trainerName: _nameController.text.trim(),
            trainerEmail: _emailController.text.trim(),
            trainerPhone: _phoneController.text.trim(),
            specialty: _selectedSpecialty!,
            experienceYears: experienceYears,
            bio: _bioController.text.trim(),
          );

          setState(() => _isLoading = false);

          // Navigate to pending screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TrainerPendingScreen(
                trainerName: _nameController.text.trim(),
                trainerEmail: _emailController.text.trim(),
              ),
            ),
          );
        } else {
          setState(() => _isLoading = false);
          _showErrorDialog(result['message'] ?? 'فشل تسجيل الحساب');
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

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: AppTheme.textSecondary.withValues(alpha: 0.7),
      ),
      prefixIcon: Icon(icon, color: AppTheme.primary),
      suffixIcon: suffixIcon,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        borderSide: const BorderSide(
          color: AppTheme.error,
          width: 1,
        ),
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
              AppTheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.secondary.withValues(alpha: 0.3),
                            AppTheme.primary.withValues(alpha: 0.3),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondary.withValues(alpha: 0.4),
                            blurRadius: 20,
                          ),
                        ],
                        border: Border.all(
                          color: AppTheme.secondary.withValues(alpha: 0.5),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 50,
                        color: AppTheme.secondary,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: AppTheme.lg),

                  // Title
                  Center(
                    child: const Text(
                      'تسجيل كمدربة',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                  ),

                  const SizedBox(height: AppTheme.sm),

                  Center(
                    child: Text(
                      'انضمي لفريق مدربات فيتافيت',
                      style: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.8),
                        fontSize: AppTheme.fontMd,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms),
                  ),

                  const SizedBox(height: AppTheme.xl * 1.5),

                  // Personal Info Section
                  _buildSectionHeader('المعلومات الشخصية', Icons.person_outline)
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 600.ms),

                  const SizedBox(height: AppTheme.md),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: _buildInputDecoration(
                      label: 'الاسم الكامل',
                      icon: Icons.person_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال الاسم';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: AppTheme.md),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: _buildInputDecoration(
                      label: 'البريد الإلكتروني',
                      icon: Icons.email_outlined,
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
                      .fadeIn(delay: 450.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: AppTheme.md),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: _buildInputDecoration(
                      label: 'رقم الجوال',
                      icon: Icons.phone_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم الجوال';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: AppTheme.md),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: _buildInputDecoration(
                      label: 'كلمة المرور',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
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
                      .fadeIn(delay: 550.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: AppTheme.md),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: _buildInputDecoration(
                      label: 'تأكيد كلمة المرور',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () {
                          setState(() =>
                              _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
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
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: AppTheme.xl),

                  // Professional Info Section
                  _buildSectionHeader('المعلومات المهنية', Icons.work_outline)
                      .animate()
                      .fadeIn(delay: 650.ms, duration: 600.ms),

                  const SizedBox(height: AppTheme.md),

                  // Specialty Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedSpecialty,
                    style: const TextStyle(color: AppTheme.white),
                    dropdownColor: AppTheme.surface,
                    decoration: _buildInputDecoration(
                      label: 'التخصص',
                      icon: Icons.category_outlined,
                    ),
                    items: _specialties.map((specialty) {
                      return DropdownMenuItem(
                        value: specialty,
                        child: Text(specialty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedSpecialty = value);
                    },
                  )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: AppTheme.md),

                  // Experience Years
                  TextFormField(
                    controller: _experienceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: _buildInputDecoration(
                      label: 'سنوات الخبرة',
                      icon: Icons.timeline_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال سنوات الخبرة';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 750.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: AppTheme.md),

                  // Certifications
                  Container(
                    padding: const EdgeInsets.all(AppTheme.md),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(
                        color: AppTheme.border.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.verified_outlined,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.sm),
                            Text(
                              'الشهادات (اختياري)',
                              style: TextStyle(
                                color: AppTheme.textSecondary.withValues(alpha: 0.7),
                                fontSize: AppTheme.fontMd,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.md),
                        Wrap(
                          spacing: AppTheme.sm,
                          runSpacing: AppTheme.sm,
                          children: _certifications.map((cert) {
                            final isSelected = _selectedCertifications.contains(cert);
                            return FilterChip(
                              label: Text(cert),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCertifications.add(cert);
                                  } else {
                                    _selectedCertifications.remove(cert);
                                  }
                                });
                              },
                              selectedColor: AppTheme.primary.withValues(alpha: 0.3),
                              checkmarkColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                              ),
                              backgroundColor: AppTheme.card,
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.border.withValues(alpha: 0.3),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: AppTheme.md),

                  // Bio
                  TextFormField(
                    controller: _bioController,
                    maxLines: 4,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: _buildInputDecoration(
                      label: 'نبذة تعريفية',
                      icon: Icons.description_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء كتابة نبذة تعريفية';
                      }
                      if (value.length < 20) {
                        return 'النبذة يجب أن تكون 20 حرف على الأقل';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 850.ms, duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  const SizedBox(height: AppTheme.lg),

                  // Terms Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() => _acceptTerms = value ?? false);
                        },
                        activeColor: AppTheme.primary,
                        checkColor: AppTheme.white,
                      ),
                      Expanded(
                        child: Text(
                          'أوافق على الشروط والأحكام وسياسة الخصوصية',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.8),
                            fontSize: AppTheme.fontSm,
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 900.ms, duration: 600.ms),

                  const SizedBox(height: AppTheme.xl),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        gradient: const LinearGradient(
                          colors: [AppTheme.secondary, AppTheme.primary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondary.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppTheme.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.md + 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
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
                                    'إرسال الطلب',
                                    style: TextStyle(
                                      fontSize: AppTheme.fontLg,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: AppTheme.sm),
                                  Icon(Icons.send, size: 20),
                                ],
                              ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 950.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),

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
                        onPressed: () => Navigator.pop(context),
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
                      .fadeIn(delay: 1000.ms, duration: 600.ms),

                  const SizedBox(height: AppTheme.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 18),
        ),
        const SizedBox(width: AppTheme.sm),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: AppTheme.fontLg,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
