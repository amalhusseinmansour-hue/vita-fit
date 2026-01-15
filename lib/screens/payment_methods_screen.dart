import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/payment_settings_service.dart';
import '../services/api_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoading = true);
    try {
      // جلب طرق الدفع المفعّلة من إعدادات الأدمن
      final methods = await PaymentSettingsService.getAvailablePaymentMethods();
      setState(() {
        _paymentMethods = methods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  IconData _getPaymentIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'credit_card':
        return Icons.credit_card;
      case 'google':
        return Icons.g_mobiledata;
      case 'apple':
        return Icons.apple;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : RefreshIndicator(
                  onRefresh: _loadPaymentMethods,
                  color: AppTheme.primary,
                  child: CustomScrollView(
                    slivers: [
                      // App Bar
                      SliverAppBar(
                        pinned: true,
                        backgroundColor: AppTheme.surface,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_forward, color: AppTheme.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        title: const Text(
                          'طرق الدفع',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: AppTheme.fontLg,
                            fontWeight: AppTheme.fontBold,
                          ),
                        ),
                      ),

                      // Content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'طرق الدفع المتاحة',
                                style: TextStyle(
                                  fontSize: AppTheme.fontXl,
                                  fontWeight: AppTheme.fontBold,
                                  color: AppTheme.white,
                                ),
                              ).animate().fadeIn(),
                              const SizedBox(height: AppTheme.md),

                              // عرض طرق الدفع أو رسالة فارغة
                              if (_paymentMethods.isEmpty)
                                _buildEmptyState()
                              else
                                ..._paymentMethods.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final method = entry.value;
                                  return _buildPaymentOption(
                                    icon: _getPaymentIcon(method.icon),
                                    title: method.nameAr,
                                    subtitle: method.name,
                                    delay: 100 + (index * 50),
                                    isActive: method.isEnabled,
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.xl),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.payment_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.md),
          const Text(
            'لا توجد طرق دفع متاحة',
            style: TextStyle(
              fontSize: AppTheme.fontLg,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          const Text(
            'يرجى التواصل مع الإدارة لتفعيل طرق الدفع',
            style: TextStyle(
              fontSize: AppTheme.fontMd,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.sm),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.md),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientPrimary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: AppTheme.fontMd,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSm,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Text(
                      'متاح',
                      style: TextStyle(
                        fontSize: AppTheme.fontXs,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.success,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Text(
                      'غير متاح',
                      style: TextStyle(
                        fontSize: AppTheme.fontXs,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(
          begin: 0.2,
          end: 0,
          duration: 400.ms,
        );
  }
}
