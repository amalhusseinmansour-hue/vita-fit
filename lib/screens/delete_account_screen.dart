import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/hive_storage_service.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  bool _confirmDelete = false;
  String _selectedReason = '';

  final List<Map<String, String>> _deletionReasons = [
    {'id': 'not_using', 'label': 'لم أعد أستخدم التطبيق'},
    {'id': 'found_alternative', 'label': 'وجدت بديلاً أفضل'},
    {'id': 'privacy_concerns', 'label': 'مخاوف تتعلق بالخصوصية'},
    {'id': 'subscription_cost', 'label': 'تكلفة الاشتراك مرتفعة'},
    {'id': 'not_satisfied', 'label': 'غير راضية عن الخدمة'},
    {'id': 'technical_issues', 'label': 'مشاكل تقنية'},
    {'id': 'other', 'label': 'سبب آخر'},
  ];

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال كلمة المرور'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (!_confirmDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء تأكيد رغبتك في حذف الحساب'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    // Show final confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تأكيد نهائي',
                style: TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'هل أنت متأكدة تماماً؟\n\nسيتم حذف جميع بياناتك بشكل نهائي ولا يمكن استرجاعها.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
              ),
              child: const Text(
                'نعم، احذف حسابي',
                style: TextStyle(color: AppTheme.white),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.deleteAccount(
        password: _passwordController.text,
        reason: _selectedReason.isNotEmpty ? _selectedReason : null,
        feedback: _reasonController.text.isNotEmpty ? _reasonController.text : null,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success'] == true) {
        // Clear all local data
        await HiveStorageService.clear();

        // Show success message and navigate to login
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
                    'تم حذف الحساب',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: AppTheme.fontXl,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.md),
                  const Text(
                    'نأسف لرؤيتك تغادرين.\nشكراً لاستخدامك VitaFit.',
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
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                    ),
                    child: const Text('حسناً', style: TextStyle(color: AppTheme.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'فشل حذف الحساب'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
            'حذف الحساب',
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
              // Warning Banner
              Container(
                padding: const EdgeInsets.all(AppTheme.lg),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: AppTheme.md),
                    const Text(
                      'تحذير: هذا الإجراء لا يمكن التراجع عنه',
                      style: TextStyle(
                        color: AppTheme.error,
                        fontSize: AppTheme.fontLg,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.sm),
                    const Text(
                      'عند حذف حسابك، سيتم حذف جميع بياناتك بشكل نهائي بما في ذلك:',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.fontMd,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),

              const SizedBox(height: AppTheme.lg),

              // What will be deleted
              Container(
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _buildDeleteItem(Icons.person, 'معلوماتك الشخصية', 100),
                    _buildDeleteItem(Icons.fitness_center, 'سجل التمارين والتقدم', 150),
                    _buildDeleteItem(Icons.restaurant, 'الخطط الغذائية المحفوظة', 200),
                    _buildDeleteItem(Icons.videocam, 'سجل الجلسات الأونلاين', 250),
                    _buildDeleteItem(Icons.shopping_bag, 'سجل الطلبات', 300),
                    _buildDeleteItem(Icons.card_membership, 'الاشتراكات النشطة', 350),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppTheme.xl),

              // Deletion Policy
              Container(
                padding: const EdgeInsets.all(AppTheme.md),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.info.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: AppTheme.info),
                        const SizedBox(width: AppTheme.sm),
                        const Text(
                          'سياسة الحذف',
                          style: TextStyle(
                            color: AppTheme.info,
                            fontSize: AppTheme.fontMd,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.sm),
                    const Text(
                      '• سيتم حذف بياناتك خلال 30 يوماً\n'
                      '• يمكنك إلغاء الحذف خلال 7 أيام بالتواصل معنا\n'
                      '• بعض البيانات قد نحتفظ بها للأغراض القانونية\n'
                      '• لن تتمكني من استخدام نفس البريد للتسجيل مجدداً خلال 30 يوماً',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.fontSm,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: AppTheme.xl),

              // Reason Selection
              const Text(
                'سبب حذف الحساب (اختياري)',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: AppTheme.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: AppTheme.md),

              Wrap(
                spacing: AppTheme.sm,
                runSpacing: AppTheme.sm,
                children: _deletionReasons.map((reason) {
                  final isSelected = _selectedReason == reason['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedReason = reason['id']!),
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
                      child: Text(
                        reason['label']!,
                        style: TextStyle(
                          color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                          fontSize: AppTheme.fontSm,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ).animate().fadeIn(delay: 550.ms),

              const SizedBox(height: AppTheme.lg),

              // Additional Feedback
              if (_selectedReason == 'other') ...[
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  style: const TextStyle(color: AppTheme.white),
                  decoration: InputDecoration(
                    hintText: 'أخبرينا المزيد...',
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
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: AppTheme.lg),
              ],

              // Password Verification
              const Text(
                'تأكيد كلمة المرور',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: AppTheme.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 650.ms),
              const SizedBox(height: AppTheme.sm),
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                style: const TextStyle(color: AppTheme.white),
                decoration: InputDecoration(
                  hintText: 'أدخلي كلمة المرور للتأكيد',
                  hintStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.surface,
                  prefixIcon: const Icon(Icons.lock, color: AppTheme.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
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
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: AppTheme.lg),

              // Confirmation Checkbox
              GestureDetector(
                onTap: () => setState(() => _confirmDelete = !_confirmDelete),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _confirmDelete ? AppTheme.error : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _confirmDelete ? AppTheme.error : AppTheme.border,
                        ),
                      ),
                      child: _confirmDelete
                          ? const Icon(Icons.check, color: AppTheme.white, size: 16)
                          : null,
                    ),
                    const SizedBox(width: AppTheme.sm),
                    const Expanded(
                      child: Text(
                        'أفهم أن حذف حسابي سيؤدي إلى فقدان جميع بياناتي بشكل نهائي',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.fontSm,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 750.ms),

              const SizedBox(height: AppTheme.xl),

              // Delete Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _deleteAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
                      : const Text(
                          'حذف حسابي نهائياً',
                          style: TextStyle(
                            fontSize: AppTheme.fontLg,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: AppTheme.md),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'إلغاء والعودة',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.fontMd,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 850.ms),

              const SizedBox(height: AppTheme.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteItem(IconData icon, String text, int delay) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.sm),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.error, size: 20),
          const SizedBox(width: AppTheme.md),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.fontMd,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms);
  }
}
