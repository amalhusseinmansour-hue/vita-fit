import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/document_upload_service.dart';
import '../services/api_service.dart';

/// Screen for trainee identity verification
/// Required to activate account
class IdentityVerificationScreen extends StatefulWidget {
  final bool isRequired;
  final VoidCallback? onVerificationComplete;

  const IdentityVerificationScreen({
    super.key,
    this.isRequired = true,
    this.onVerificationComplete,
  });

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  File? _identityImage;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage(bool fromCamera) async {
    final File? image = fromCamera
        ? await DocumentUploadService.pickFromCamera()
        : await DocumentUploadService.pickFromGallery();

    if (image != null) {
      setState(() {
        _identityImage = image;
        _errorMessage = null;
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.lg),
            const Text(
              'اختاري طريقة رفع الهوية',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.lg),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: AppTheme.primary),
              ),
              title: const Text('الكاميرا', style: TextStyle(color: AppTheme.white)),
              subtitle: const Text('التقاط صورة جديدة', style: TextStyle(color: AppTheme.textSecondary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(true);
              },
            ),
            const Divider(color: AppTheme.border),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library, color: AppTheme.secondary),
              ),
              title: const Text('المعرض', style: TextStyle(color: AppTheme.white)),
              subtitle: const Text('اختيار صورة موجودة', style: TextStyle(color: AppTheme.textSecondary)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(false);
              },
            ),
            const SizedBox(height: AppTheme.md),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadIdentity() async {
    if (_identityImage == null) {
      setState(() => _errorMessage = 'يرجى اختيار صورة الهوية أولاً');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userData = await ApiService.getUserData();
      final userId = userData?['id']?.toString() ?? '';

      if (userId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'خطأ في البيانات. يرجى تسجيل الدخول مرة أخرى';
        });
        return;
      }

      final result = await DocumentUploadService.uploadTraineeIdentity(
        traineeId: userId,
        identityDocument: _identityImage!,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showSuccessDialog();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ غير متوقع';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.success,
                size: 50,
              ),
            ),
            const SizedBox(height: AppTheme.lg),
            const Text(
              'تم رفع الهوية بنجاح!',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.sm),
            const Text(
              'سيتم مراجعة هويتك وتفعيل حسابك خلال 24 ساعة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppTheme.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.onVerificationComplete != null) {
                    widget.onVerificationComplete!();
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'حسناً',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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
        leading: widget.isRequired
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.white),
                onPressed: () => Navigator.pop(context),
              ),
        automaticallyImplyLeading: !widget.isRequired,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.3),
                      AppTheme.secondary.withValues(alpha: 0.3),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  size: 50,
                  color: AppTheme.primary,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),

              const SizedBox(height: AppTheme.lg),

              // Title
              const Text(
                'تفعيل الحساب',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

              const SizedBox(height: AppTheme.sm),

              // Subtitle
              Text(
                'يرجى رفع صورة الهوية لتفعيل حسابك',
                style: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

              const SizedBox(height: AppTheme.xl * 2),

              // Image Upload Area
              GestureDetector(
                onTap: _showPickerOptions,
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _identityImage != null
                          ? AppTheme.success
                          : AppTheme.border,
                      width: 2,
                      style: _identityImage == null
                          ? BorderStyle.solid
                          : BorderStyle.solid,
                    ),
                  ),
                  child: _identityImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                _identityImage!,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.background.withValues(alpha: 0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: AppTheme.white),
                                    onPressed: () => setState(() => _identityImage = null),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'تم الاختيار',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 50,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            const Text(
                              'اضغطي لرفع صورة الهوية',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: AppTheme.sm),
                            Text(
                              'الهوية الوطنية أو الإقامة',
                              style: TextStyle(
                                color: AppTheme.textSecondary.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

              const SizedBox(height: AppTheme.md),

              // Requirements note
              Container(
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primary.withValues(alpha: 0.8),
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.sm),
                        const Text(
                          'متطلبات الصورة:',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.sm),
                    _buildRequirement('صورة واضحة للهوية'),
                    _buildRequirement('جميع البيانات مقروءة'),
                    _buildRequirement('الهوية سارية المفعول'),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: AppTheme.md),
                Container(
                  padding: const EdgeInsets.all(AppTheme.md),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.error),
                      const SizedBox(width: AppTheme.sm),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppTheme.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppTheme.xl),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _uploadIdentity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                              Icon(Icons.upload_file, color: AppTheme.white),
                              SizedBox(width: AppTheme.sm),
                              Text(
                                'رفع الهوية',
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppTheme.textSecondary.withValues(alpha: 0.6),
            size: 16,
          ),
          const SizedBox(width: AppTheme.sm),
          Text(
            text,
            style: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
