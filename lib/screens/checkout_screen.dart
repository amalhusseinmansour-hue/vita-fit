import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hive_storage_service.dart';
import '../constants/app_theme.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCity = 'الرياض';
  String _paymentMethod = 'cod'; // cod = Cash on Delivery
  bool _isLoading = false;

  final List<String> _cities = [
    'الرياض',
    'جدة',
    'مكة المكرمة',
    'المدينة المنورة',
    'الدمام',
    'الخبر',
    'الظهران',
    'الأحساء',
    'الطائف',
    'تبوك',
    'بريدة',
    'خميس مشيط',
    'حائل',
    'نجران',
    'جازان',
    'أبها',
    'ينبع',
    'الجبيل',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final phone = HiveStorageService.getString('userPhone') ?? '';
    if (phone.isNotEmpty) {
      _phoneController.text = phone;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final cart = Provider.of<CartProvider>(context, listen: false);

    // Prepare order items
    final items = cart.items.values.map((item) => {
      'product_id': item.product.id,
      'product_name': item.product.name,
      'quantity': item.quantity,
      'price': item.product.finalPrice,
      'size': item.selectedSize,
      'color': item.selectedColor,
    }).toList();

    try {
      final result = await ApiService.createOrder(
        items: items,
        shippingAddress: _addressController.text.trim(),
        shippingCity: _selectedCity,
        phone: _phoneController.text.trim(),
        paymentMethod: _paymentMethod,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success'] == true) {
        // Clear cart
        cart.clear();

        // Show success dialog
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
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: AppTheme.lg),
                  const Text(
                    'تم إرسال طلبك بنجاح!',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: AppTheme.fontXl,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.md),
                  Text(
                    'رقم الطلب: ${result['data']?['order_number'] ?? 'N/A'}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: AppTheme.fontMd,
                    ),
                  ),
                  const SizedBox(height: AppTheme.sm),
                  const Text(
                    'سيتم إرسال تفاصيل الطلب على بريدك الإلكتروني',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.fontSm,
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
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to cart
                      Navigator.pop(context); // Go back to shop
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                    child: const Text(
                      'تم',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: AppTheme.fontLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'فشل إرسال الطلب'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
            'إتمام الطلب',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: AppTheme.fontXl,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Consumer<CartProvider>(
          builder: (context, cart, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    Container(
                      padding: const EdgeInsets.all(AppTheme.md),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ملخص الطلب',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: AppTheme.fontLg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(color: AppTheme.border),
                          ...cart.items.values.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppTheme.xs),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.product.name} x${item.quantity}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: AppTheme.fontSm,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${item.totalPrice.toStringAsFixed(2)} AED',
                                  style: const TextStyle(
                                    color: AppTheme.white,
                                    fontSize: AppTheme.fontSm,
                                  ),
                                ),
                              ],
                            ),
                          )),
                          const Divider(color: AppTheme.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'المجموع الفرعي',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              Text(
                                '${cart.totalAmount.toStringAsFixed(2)} AED',
                                style: const TextStyle(color: AppTheme.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.xs),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الشحن',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              Text(
                                'مجاني',
                                style: TextStyle(color: AppTheme.success),
                              ),
                            ],
                          ),
                          const Divider(color: AppTheme.border),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'الإجمالي',
                                style: TextStyle(
                                  color: AppTheme.white,
                                  fontSize: AppTheme.fontLg,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${cart.totalAmount.toStringAsFixed(2)} AED',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: AppTheme.fontLg,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.lg),

                    // Shipping Info
                    const Text(
                      'معلومات الشحن',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: AppTheme.fontLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppTheme.white),
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف',
                        labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: const Icon(Icons.phone, color: AppTheme.primary),
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
                          return 'الرجاء إدخال رقم الهاتف';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.md),

                    // City Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      dropdownColor: AppTheme.surface,
                      style: const TextStyle(color: AppTheme.white),
                      decoration: InputDecoration(
                        labelText: 'المدينة',
                        labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: const Icon(Icons.location_city, color: AppTheme.primary),
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
                      ),
                      items: _cities.map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      )).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCity = value!);
                      },
                    ),
                    const SizedBox(height: AppTheme.md),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      style: const TextStyle(color: AppTheme.white),
                      decoration: InputDecoration(
                        labelText: 'العنوان بالتفصيل',
                        hintText: 'الحي، الشارع، رقم المبنى...',
                        hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                        labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: const Icon(Icons.location_on, color: AppTheme.primary),
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
                          return 'الرجاء إدخال العنوان';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.md),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      style: const TextStyle(color: AppTheme.white),
                      decoration: InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        hintText: 'أي ملاحظات إضافية...',
                        hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                        labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: const Icon(Icons.note, color: AppTheme.primary),
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
                      ),
                    ),

                    const SizedBox(height: AppTheme.lg),

                    // Payment Method
                    const Text(
                      'طريقة الدفع',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: AppTheme.fontLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),

                    // COD Option
                    GestureDetector(
                      onTap: () => setState(() => _paymentMethod = 'cod'),
                      child: Container(
                        padding: const EdgeInsets.all(AppTheme.md),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: _paymentMethod == 'cod'
                                ? AppTheme.primary
                                : AppTheme.border,
                            width: _paymentMethod == 'cod' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              ),
                              child: const Icon(
                                Icons.money,
                                color: AppTheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppTheme.md),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الدفع عند الاستلام',
                                    style: TextStyle(
                                      color: AppTheme.white,
                                      fontSize: AppTheme.fontMd,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'ادفعي نقداً عند استلام طلبك',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: AppTheme.fontSm,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Radio<String>(
                              value: 'cod',
                              groupValue: _paymentMethod,
                              onChanged: (value) => setState(() => _paymentMethod = value!),
                              activeColor: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.xl),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
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
                                'تأكيد الطلب',
                                style: TextStyle(
                                  fontSize: AppTheme.fontLg,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.lg),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
