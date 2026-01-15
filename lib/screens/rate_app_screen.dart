import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  int _rating = 0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار تقييم'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await ApiService.submitRating(
        rating: _rating,
        review: _reviewController.text.trim().isNotEmpty
            ? _reviewController.text.trim()
            : null,
      );

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      if (result['success'] == true) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'فشل إرسال التقييم'),
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
                  Icons.favorite,
                  color: AppTheme.success,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppTheme.lg),
              const Text(
                'شكراً لتقييمك!',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: AppTheme.fontXl,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.md),
              const Text(
                'رأيك يساعدنا على التحسين المستمر',
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
            'قيمي التطبيق',
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

              // App Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPrimary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.shadowLg,
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppTheme.white,
                  size: 50,
                ),
              ).animate().scale(duration: 500.ms),

              const SizedBox(height: AppTheme.xl),

              // Title
              const Text(
                'كيف كانت تجربتك مع VitaFit؟',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: AppTheme.fontXl,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppTheme.sm),

              const Text(
                'رأيك يهمنا ويساعدنا على التحسين',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.fontMd,
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: AppTheme.xl),

              // Rating Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starNumber = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = starNumber),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        _rating >= starNumber ? Icons.star : Icons.star_border,
                        size: 48,
                        color: _rating >= starNumber
                            ? AppTheme.warning
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ).animate().scale(
                        delay: (400 + index * 100).ms,
                        duration: 300.ms,
                      );
                }),
              ),

              const SizedBox(height: AppTheme.md),

              // Rating Text
              Text(
                _getRatingText(),
                style: TextStyle(
                  color: _rating > 0 ? AppTheme.warning : AppTheme.textSecondary,
                  fontSize: AppTheme.fontLg,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 900.ms),

              const SizedBox(height: AppTheme.xl),

              // Review Text Field
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.border),
                ),
                child: TextField(
                  controller: _reviewController,
                  maxLines: 5,
                  style: const TextStyle(color: AppTheme.white),
                  decoration: const InputDecoration(
                    hintText: 'شاركينا تجربتك... (اختياري)',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    contentPadding: EdgeInsets.all(AppTheme.md),
                    border: InputBorder.none,
                  ),
                ),
              ).animate().fadeIn(delay: 1000.ms),

              const SizedBox(height: AppTheme.xl),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRating,
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
                          'إرسال التقييم',
                          style: TextStyle(
                            fontSize: AppTheme.fontLg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 1100.ms),

              const SizedBox(height: AppTheme.lg),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'سيء جداً';
      case 2:
        return 'سيء';
      case 3:
        return 'متوسط';
      case 4:
        return 'جيد';
      case 5:
        return 'ممتاز!';
      default:
        return 'اختاري تقييمك';
    }
  }
}
