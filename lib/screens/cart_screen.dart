import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/cart_provider.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'سلة التسوق',
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
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 120,
                    color: AppTheme.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: AppTheme.lg),
                  Text(
                    'سلة التسوق فارغة',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.fontLg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.sm),
                  Text(
                    'أضف منتجات لبدء التسوق',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      fontSize: AppTheme.fontMd,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.md),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items.values.toList()[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.md),
                      padding: const EdgeInsets.all(AppTheme.md),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(
                          color: AppTheme.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Product Image Placeholder
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: const Icon(
                              Icons.image,
                              color: AppTheme.primary,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: AppTheme.md),
                          // Product Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    color: AppTheme.white,
                                    fontSize: AppTheme.fontMd,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.xs),
                                Text(
                                  '${item.product.finalPrice.toStringAsFixed(2)} AED',
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: AppTheme.fontMd,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.sm),
                                // Quantity Controls
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.radiusSm),
                                      ),
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove,
                                                size: 16),
                                            color: AppTheme.white,
                                            onPressed: () {
                                              if (item.quantity > 1) {
                                                cart.updateQuantity(
                                                  cart.items.keys.toList()[index],
                                                  item.quantity - 1,
                                                );
                                              }
                                            },
                                            padding: const EdgeInsets.all(4),
                                            constraints:
                                                const BoxConstraints(),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppTheme.sm,
                                            ),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                color: AppTheme.white,
                                                fontSize: AppTheme.fontMd,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon:
                                                const Icon(Icons.add, size: 16),
                                            color: AppTheme.white,
                                            onPressed: () {
                                              cart.updateQuantity(
                                                cart.items.keys.toList()[index],
                                                item.quantity + 1,
                                              );
                                            },
                                            padding: const EdgeInsets.all(4),
                                            constraints:
                                                const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Remove Button
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            onPressed: () {
                              cart.removeItem(cart.items.keys.toList()[index]);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Total and Checkout
              Container(
                padding: const EdgeInsets.all(AppTheme.lg),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.border,
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'المجموع:',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: AppTheme.fontLg,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${cart.totalAmount.toStringAsFixed(2)} AED',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: AppTheme.fontXl,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CheckoutScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                            ),
                          ),
                          child: const Text(
                            'إتمام الطلب',
                            style: TextStyle(
                              fontSize: AppTheme.fontLg,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
