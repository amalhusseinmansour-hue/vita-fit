import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constants/app_theme.dart';
import '../providers/language_provider.dart';
import '../services/payment_service.dart';
import '../services/payment_settings_service.dart';

/// شاشة الدفع الموحدة
class PaymentScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String customerEmail;
  final String customerPhone;
  final String customerName;
  final String orderDescription;
  final Function(Map<String, dynamic>) onPaymentSuccess;
  final VoidCallback? onPaymentCancel;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.currency,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerName,
    required this.orderDescription,
    required this.onPaymentSuccess,
    this.onPaymentCancel,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = true;
  List<PaymentMethodInfo> _paymentMethods = [];
  String? _selectedMethod;
  String? _errorMessage;
  bool _isProcessing = false;

  // WebView for PayMob
  WebViewController? _webViewController;
  bool _showWebView = false;
  String? _paymentUrl;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final methods = await PaymentService.getAvailablePaymentMethods();
      setState(() {
        _paymentMethods = methods;
        _isLoading = false;
        if (methods.isNotEmpty) {
          _selectedMethod = methods.first.id;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == null) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result = await PaymentService.processPayment(
        method: _selectedMethod!,
        amount: widget.amount,
        currency: widget.currency,
        customerEmail: widget.customerEmail,
        customerPhone: widget.customerPhone,
        customerName: widget.customerName,
      );

      if (result['success'] == true) {
        if (result['iframeUrl'] != null) {
          // PayMob payment - show WebView
          setState(() {
            _paymentUrl = result['iframeUrl'];
            _showWebView = true;
            _isProcessing = false;
          });
          _initWebView();
        } else if (result['requiresNativePayment'] == true) {
          // Google Pay / Apple Pay - needs native implementation
          _showNativePaymentDialog(result);
        } else {
          // Direct success
          widget.onPaymentSuccess(result);
          if (mounted) Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'فشل في معالجة الدفع';
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isProcessing = false;
      });
    }
  }

  void _initWebView() {
    if (_paymentUrl == null) return;

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // التحقق من callback URLs
            if (request.url.contains('success') || request.url.contains('callback')) {
              _handlePaymentCallback(true);
              return NavigationDecision.prevent;
            }
            if (request.url.contains('failure') || request.url.contains('cancel')) {
              _handlePaymentCallback(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (url) {
            // يمكن إضافة منطق إضافي هنا
          },
        ),
      )
      ..loadRequest(Uri.parse(_paymentUrl!));
  }

  void _handlePaymentCallback(bool success) {
    setState(() {
      _showWebView = false;
    });

    if (success) {
      widget.onPaymentSuccess({
        'success': true,
        'message': 'تم الدفع بنجاح',
      });
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = 'تم إلغاء الدفع أو فشل';
      });
    }
  }

  void _showNativePaymentDialog(Map<String, dynamic> result) {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Text(
          result['paymentMethod'] == 'google_pay' ? 'Google Pay' : 'Apple Pay',
          style: const TextStyle(color: AppTheme.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              result['paymentMethod'] == 'google_pay'
                  ? Icons.g_mobiledata
                  : Icons.apple,
              size: 64,
              color: result['paymentMethod'] == 'google_pay'
                  ? const Color(0xFF4285F4)
                  : AppTheme.white,
            ),
            const SizedBox(height: AppTheme.md),
            Text(
              isRTL
                  ? 'سيتم فتح ${result['paymentMethod'] == 'google_pay' ? 'Google Pay' : 'Apple Pay'} لإتمام الدفع'
                  : '${result['paymentMethod'] == 'google_pay' ? 'Google Pay' : 'Apple Pay'} will open to complete payment',
              style: const TextStyle(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.sm),
            Text(
              '${widget.amount} ${widget.currency}',
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: AppTheme.fontXl,
                fontWeight: AppTheme.fontBold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isProcessing = false);
            },
            child: Text(
              isRTL ? 'إلغاء' : 'Cancel',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // في التطبيق الحقيقي، سيتم استخدام Pay package هنا
              // لعرض واجهة Google Pay / Apple Pay
              _simulateNativePayment(result);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            child: Text(
              isRTL ? 'متابعة' : 'Continue',
              style: const TextStyle(color: AppTheme.white),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateNativePayment(Map<String, dynamic> result) {
    // في الإنتاج، سيتم استخدام Pay package
    // هنا نحاكي نجاح الدفع للعرض التوضيحي

    setState(() => _isProcessing = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        widget.onPaymentSuccess({
          'success': true,
          'paymentMethod': result['paymentMethod'],
          'transactionId': DateTime.now().millisecondsSinceEpoch.toString(),
        });
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, child) {
        final isRTL = langProvider.isRTL;

        if (_showWebView && _webViewController != null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.surface,
              title: Text(
                isRTL ? 'إتمام الدفع' : 'Complete Payment',
                style: const TextStyle(color: AppTheme.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppTheme.white),
                onPressed: () {
                  setState(() => _showWebView = false);
                  _handlePaymentCallback(false);
                },
              ),
            ),
            body: WebViewWidget(controller: _webViewController!),
          );
        }

        return Directionality(
          textDirection: langProvider.textDirection,
          child: Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              backgroundColor: AppTheme.surface,
              title: Text(
                isRTL ? 'اختر طريقة الدفع' : 'Select Payment Method',
                style: const TextStyle(
                  color: AppTheme.white,
                  fontWeight: AppTheme.fontBold,
                ),
              ),
              leading: IconButton(
                icon: Icon(
                  isRTL ? Icons.arrow_forward : Icons.arrow_back,
                  color: AppTheme.white,
                ),
                onPressed: () {
                  widget.onPaymentCancel?.call();
                  Navigator.pop(context);
                },
              ),
            ),
            body: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : _buildContent(isRTL),
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isRTL) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary
          _buildOrderSummary(isRTL),
          const SizedBox(height: AppTheme.lg),

          // Error Message
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.md),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
            ).animate().shake(),
            const SizedBox(height: AppTheme.md),
          ],

          // Payment Methods
          Text(
            isRTL ? 'طرق الدفع المتاحة' : 'Available Payment Methods',
            style: const TextStyle(
              fontSize: AppTheme.fontLg,
              fontWeight: AppTheme.fontBold,
              color: AppTheme.white,
            ),
          ),
          const SizedBox(height: AppTheme.md),

          if (_paymentMethods.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppTheme.lg),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.payment_outlined,
                        size: 48, color: AppTheme.textSecondary),
                    const SizedBox(height: AppTheme.md),
                    Text(
                      isRTL
                          ? 'لا توجد طرق دفع متاحة حالياً'
                          : 'No payment methods available',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(
              _paymentMethods.length,
              (index) => _buildPaymentMethodCard(
                _paymentMethods[index],
                isRTL,
                index,
              ),
            ),

          const SizedBox(height: AppTheme.xl),

          // Pay Button
          if (_paymentMethods.isNotEmpty) _buildPayButton(isRTL),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.md),
      decoration: BoxDecoration(
        gradient: AppTheme.gradientPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: AppTheme.white),
              const SizedBox(width: AppTheme.sm),
              Text(
                isRTL ? 'ملخص الطلب' : 'Order Summary',
                style: const TextStyle(
                  color: AppTheme.white,
                  fontWeight: AppTheme.fontBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          Text(
            widget.orderDescription,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: AppTheme.fontSm,
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          const Divider(color: Colors.white30),
          const SizedBox(height: AppTheme.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRTL ? 'المبلغ الإجمالي' : 'Total Amount',
                style: const TextStyle(color: AppTheme.white),
              ),
              Text(
                '${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: AppTheme.fontXl,
                  fontWeight: AppTheme.fontBold,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildPaymentMethodCard(
      PaymentMethodInfo method, bool isRTL, int index) {
    final isSelected = _selectedMethod == method.id;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: method.isAvailable
              ? () {
                  setState(() {
                    _selectedMethod = method.id;
                  });
                }
              : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.md),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : method.isAvailable
                        ? AppTheme.border
                        : AppTheme.border.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getMethodColor(method.id).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(
                    _getMethodIcon(method.id),
                    color: _getMethodColor(method.id),
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRTL ? method.nameAr : method.name,
                        style: TextStyle(
                          fontSize: AppTheme.fontMd,
                          fontWeight: AppTheme.fontSemibold,
                          color: method.isAvailable
                              ? AppTheme.white
                              : AppTheme.textSecondary,
                        ),
                      ),
                      if (!method.isAvailable &&
                          method.unavailableReason != null)
                        Text(
                          method.unavailableReason!,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSm,
                            color: AppTheme.textLight,
                          ),
                        ),
                    ],
                  ),
                ),
                if (method.isAvailable)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                        width: 2,
                      ),
                      color: isSelected ? AppTheme.primary : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            size: 16, color: AppTheme.white)
                        : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(
          begin: isRTL ? 0.2 : -0.2,
          end: 0,
          delay: (100 * index).ms,
        );
  }

  IconData _getMethodIcon(String methodId) {
    switch (methodId) {
      case 'paymob':
        return Icons.credit_card;
      case 'google_pay':
        return Icons.g_mobiledata;
      case 'apple_pay':
        return Icons.apple;
      default:
        return Icons.payment;
    }
  }

  Color _getMethodColor(String methodId) {
    switch (methodId) {
      case 'paymob':
        return AppTheme.primary;
      case 'google_pay':
        return const Color(0xFF4285F4);
      case 'apple_pay':
        return AppTheme.white;
      default:
        return AppTheme.primary;
    }
  }

  Widget _buildPayButton(bool isRTL) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing || _selectedMethod == null
            ? null
            : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppTheme.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, color: AppTheme.white),
                  const SizedBox(width: AppTheme.sm),
                  Text(
                    isRTL
                        ? 'ادفع ${widget.amount.toStringAsFixed(2)} ${widget.currency}'
                        : 'Pay ${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                    style: const TextStyle(
                      fontSize: AppTheme.fontMd,
                      fontWeight: AppTheme.fontBold,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(delay: 400.ms);
  }
}
