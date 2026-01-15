import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedType = 'suggestion';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _feedbackTypes = [
    {'id': 'suggestion', 'label': 'اقتراح', 'icon': Icons.lightbulb_outline},
    {'id': 'complaint', 'label': 'شكوى', 'icon': Icons.report_problem_outlined},
    {'id': 'question', 'label': 'استفسار', 'icon': Icons.help_outline},
    {'id': 'praise', 'label': 'إشادة', 'icon': Icons.thumb_up_outlined},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await ApiService.submitFeedback(
        type: _selectedType,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        email: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
      );

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      if (result['success'] == true) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'فشل إرسال الملاحظات'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ في الاتصال'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.success,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppTheme.lg),
              const Text(
                'تم إرسال ملاحظاتك!',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: AppTheme.fontXl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.md),
              const Text(
                'شكراً لمشاركتنا رأيك، سنعمل على تحسين تجربتك',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.fontMd,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                ),
                child: const Text('تم', style: TextStyle(color: AppTheme.white)),
              ),
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
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'اقتراحاتك وملاحظاتك',
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppTheme.lg),
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientPrimary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.feedback, color: AppTheme.white, size: 40),
                      SizedBox(width: AppTheme.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نحن نستمع إليك',
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: AppTheme.fontLg,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'رأيك يساعدنا على تحسين التطبيق',
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: AppTheme.fontSm,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.2, end: 0),

                const SizedBox(height: AppTheme.xl),

                // Feedback Type
                const Text(
                  'نوع الرسالة',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: AppTheme.fontMd,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: AppTheme.md),

                Wrap(
                  spacing: AppTheme.sm,
                  runSpacing: AppTheme.sm,
                  children: _feedbackTypes.map((type) {
                    final isSelected = _selectedType == type['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = type['id']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.md,
                          vertical: AppTheme.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary : AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : AppTheme.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type['icon'],
                              size: 18,
                              color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              type['label'],
                              style: TextStyle(
                                color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 150.ms),

                const SizedBox(height: AppTheme.xl),

                // Subject
                const Text(
                  'الموضوع',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: AppTheme.fontMd,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: AppTheme.sm),
                TextFormField(
                  controller: _subjectController,
                  style: const TextStyle(color: AppTheme.white),
                  decoration: InputDecoration(
                    hintText: 'عنوان رسالتك',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الموضوع';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: AppTheme.lg),

                // Message
                const Text(
                  'الرسالة',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: AppTheme.fontMd,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: AppTheme.sm),
                TextFormField(
                  controller: _messageController,
                  maxLines: 6,
                  style: const TextStyle(color: AppTheme.white),
                  decoration: InputDecoration(
                    hintText: 'اكتبي رسالتك هنا...',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الرسالة';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: AppTheme.lg),

                // Email (optional)
                const Text(
                  'البريد الإلكتروني (اختياري)',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: AppTheme.fontMd,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: AppTheme.sm),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppTheme.white),
                  decoration: InputDecoration(
                    hintText: 'للتواصل معك بخصوص رسالتك',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: AppTheme.xl),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppTheme.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'إرسال',
                            style: TextStyle(
                              fontSize: AppTheme.fontLg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: AppTheme.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
