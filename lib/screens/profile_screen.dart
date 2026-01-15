import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  double _height = 165;
  double _weight = 60;
  double _targetWeight = 55;
  String _activityLevel = 'moderate';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final result = await ApiService.getProfile();
      if (result['success'] == true && result['profile'] != null) {
        final profile = result['profile'];
        setState(() {
          _nameController.text = profile['name'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _phoneController.text = profile['phone'] ?? '';
          _height = (profile['height'] ?? 165).toDouble();
          _weight = (profile['current_weight'] ?? 60).toDouble();
          _targetWeight = (profile['target_weight'] ?? 55).toDouble();
          _activityLevel = profile['activity_level'] ?? 'moderate';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final result = await ApiService.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        height: _height,
        currentWeight: _weight,
        targetWeight: _targetWeight,
        activityLevel: _activityLevel,
      );

      setState(() => _isSaving = false);

      if (!mounted) return;

      if (result['success'] == true) {
        // Save updated data to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', _nameController.text.trim());
        if (_phoneController.text.trim().isNotEmpty) {
          await prefs.setString('userPhone', _phoneController.text.trim());
        }

        // Also update the full user data in ApiService
        final currentUserData = await ApiService.getUserData() ?? {};
        currentUserData['name'] = _nameController.text.trim();
        currentUserData['phone'] = _phoneController.text.trim();
        currentUserData['height'] = _height;
        currentUserData['current_weight'] = _weight;
        currentUserData['target_weight'] = _targetWeight;
        currentUserData['activity_level'] = _activityLevel;
        await ApiService.saveUserData(currentUserData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التغييرات بنجاح'),
            backgroundColor: AppTheme.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'فشل حفظ التغييرات'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في الاتصال بالخادم'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                )
              : CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      backgroundColor: AppTheme.surface,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: AppTheme.gradientPrimary,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 120,
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
                                        decoration: const BoxDecoration(
                                          gradient: AppTheme.gradientSecondary,
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: AppTheme.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      leading: IconButton(
                        icon:
                            const Icon(Icons.arrow_forward, color: AppTheme.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.lg),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'المعلومات الشخصية',
                                style: TextStyle(
                                  fontSize: AppTheme.fontXl,
                                  fontWeight: AppTheme.fontBold,
                                  color: AppTheme.white,
                                ),
                              ).animate().fadeIn(),
                              const SizedBox(height: AppTheme.lg),

                              // الاسم
                              _buildTextField(
                                controller: _nameController,
                                label: 'الاسم الكامل',
                                icon: Icons.person,
                                delay: 100,
                              ),
                              const SizedBox(height: AppTheme.md),

                              // البريد الإلكتروني (للعرض فقط)
                              _buildTextField(
                                controller: _emailController,
                                label: 'البريد الإلكتروني',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                delay: 150,
                                enabled: false,
                              ),
                              const SizedBox(height: AppTheme.md),

                              // رقم الهاتف
                              _buildTextField(
                                controller: _phoneController,
                                label: 'رقم الهاتف',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                delay: 200,
                              ),
                              const SizedBox(height: AppTheme.lg),

                              // مستوى النشاط
                              const Text(
                                'مستوى النشاط',
                                style: TextStyle(
                                  fontSize: AppTheme.fontMd,
                                  fontWeight: AppTheme.fontSemibold,
                                  color: AppTheme.white,
                                ),
                              ),
                              const SizedBox(height: AppTheme.sm),
                              _buildActivityLevelSelector().animate().fadeIn(delay: 250.ms),
                              const SizedBox(height: AppTheme.lg),

                              // الطول
                              const Text(
                                'الطول (سم)',
                                style: TextStyle(
                                  fontSize: AppTheme.fontMd,
                                  fontWeight: AppTheme.fontSemibold,
                                  color: AppTheme.white,
                                ),
                              ),
                              const SizedBox(height: AppTheme.sm),
                              _buildSlider(
                                value: _height,
                                min: 140,
                                max: 220,
                                label: '${_height.toInt()} سم',
                                onChanged: (value) {
                                  setState(() {
                                    _height = value;
                                  });
                                },
                                delay: 300,
                              ),
                              const SizedBox(height: AppTheme.lg),

                              // الوزن الحالي
                              const Text(
                                'الوزن الحالي (كجم)',
                                style: TextStyle(
                                  fontSize: AppTheme.fontMd,
                                  fontWeight: AppTheme.fontSemibold,
                                  color: AppTheme.white,
                                ),
                              ),
                              const SizedBox(height: AppTheme.sm),
                              _buildSlider(
                                value: _weight,
                                min: 40,
                                max: 150,
                                label: '${_weight.toInt()} كجم',
                                onChanged: (value) {
                                  setState(() {
                                    _weight = value;
                                  });
                                },
                                delay: 350,
                              ),
                              const SizedBox(height: AppTheme.lg),

                              // الوزن المستهدف
                              const Text(
                                'الوزن المستهدف (كجم)',
                                style: TextStyle(
                                  fontSize: AppTheme.fontMd,
                                  fontWeight: AppTheme.fontSemibold,
                                  color: AppTheme.white,
                                ),
                              ),
                              const SizedBox(height: AppTheme.sm),
                              _buildSlider(
                                value: _targetWeight,
                                min: 40,
                                max: 150,
                                label: '${_targetWeight.toInt()} كجم',
                                onChanged: (value) {
                                  setState(() {
                                    _targetWeight = value;
                                  });
                                },
                                delay: 400,
                              ),
                              const SizedBox(height: AppTheme.xl),

                              // زر الحفظ
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppTheme.radiusLg),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: AppTheme.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'حفظ التغييرات',
                                          style: TextStyle(
                                            fontSize: AppTheme.fontLg,
                                            fontWeight: AppTheme.fontBold,
                                            color: AppTheme.white,
                                          ),
                                        ),
                                ),
                              ).animate().fadeIn(delay: 450.ms).slideY(
                                    begin: 0.3,
                                    end: 0,
                                    duration: 400.ms,
                                  ),
                              const SizedBox(height: AppTheme.xl),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    required int delay,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? AppTheme.white : AppTheme.textSecondary,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        filled: true,
        fillColor: enabled ? AppTheme.surface : AppTheme.surface.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.border.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
      validator: (value) {
        if (enabled && (value == null || value.isEmpty)) {
          return 'هذا الحقل مطلوب';
        }
        return null;
      },
    ).animate().fadeIn(delay: delay.ms).slideX(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
        );
  }

  Widget _buildActivityLevelSelector() {
    final levels = [
      {'value': 'sedentary', 'label': 'خامل', 'icon': Icons.weekend},
      {'value': 'light', 'label': 'خفيف', 'icon': Icons.directions_walk},
      {'value': 'moderate', 'label': 'معتدل', 'icon': Icons.directions_run},
      {'value': 'active', 'label': 'نشيط', 'icon': Icons.fitness_center},
      {'value': 'very_active', 'label': 'نشيط جداً', 'icon': Icons.sports},
    ];

    return Wrap(
      spacing: AppTheme.sm,
      runSpacing: AppTheme.sm,
      children: levels.map((level) {
        final isSelected = _activityLevel == level['value'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _activityLevel = level['value'] as String;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.md,
              vertical: AppTheme.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.border,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  level['icon'] as IconData,
                  color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: AppTheme.xs),
                Text(
                  level['label'] as String,
                  style: TextStyle(
                    fontSize: AppTheme.fontSm,
                    fontWeight: isSelected ? AppTheme.fontBold : AppTheme.fontRegular,
                    color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required String label,
    required ValueChanged<double> onChanged,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.fontXl,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.primary,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: AppTheme.primary,
            inactiveColor: AppTheme.border,
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min.toInt()}',
                style: const TextStyle(
                  fontSize: AppTheme.fontSm,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${max.toInt()}',
                style: const TextStyle(
                  fontSize: AppTheme.fontSm,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
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
