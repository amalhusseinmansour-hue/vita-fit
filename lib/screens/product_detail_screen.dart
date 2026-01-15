import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedSize;
  String? selectedColor;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    selectedSize = widget.product.sizes.isNotEmpty ? widget.product.sizes[0] : null;
    selectedColor = widget.product.colors.isNotEmpty ? widget.product.colors[0] : null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // App Bar مع الصورة
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.gradientSoft,
                      ),
                      child: Center(
                        child: Icon(
                          _getProductIcon(widget.product.category),
                          size: 150,
                          color: AppTheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    // خصم
                    if (widget.product.discount != null && widget.product.discount! > 0)
                      Positioned(
                        top: 60,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            boxShadow: AppTheme.shadowMd,
                          ),
                          child: Text(
                            'خصم ${widget.product.discountText}',
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: AppTheme.fontMd,
                              fontWeight: AppTheme.fontBold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.background.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: AppTheme.text),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Consumer<FavoritesProvider>(
                  builder: (context, favorites, child) => IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.background.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        favorites.isProductFavorite(widget.product.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: favorites.isProductFavorite(widget.product.id)
                            ? AppTheme.error
                            : AppTheme.text,
                      ),
                    ),
                    onPressed: () {
                      favorites.toggleProductFavorite(widget.product.id);
                    },
                  ),
                ),
              ],
            ),

            // المحتوى
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusXl),
                    topRight: Radius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان والسعر
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.name,
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontXxl,
                                    fontWeight: AppTheme.fontBold,
                                    color: AppTheme.text,
                                  ),
                                ).animate().fadeIn(duration: 400.ms),
                                const SizedBox(height: AppTheme.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppTheme.sm,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.gradientSoft,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                  ),
                                  child: Text(
                                    widget.product.category,
                                    style: const TextStyle(
                                      fontSize: AppTheme.fontSm,
                                      color: AppTheme.primary,
                                      fontWeight: AppTheme.fontMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (widget.product.discount != null && widget.product.discount! > 0)
                                Text(
                                  '${widget.product.price.toInt()} ريال',
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontMd,
                                    color: AppTheme.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                '${widget.product.finalPrice.toInt()} ريال',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontXxl,
                                  fontWeight: AppTheme.fontBold,
                                  color: AppTheme.primary,
                                ),
                              ).animate().fadeIn(delay: 200.ms),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.lg),

                      // التقييمات والتوفر
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.md,
                              vertical: AppTheme.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.card,
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 18,
                                  color: AppTheme.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.product.rating}',
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontMd,
                                    fontWeight: AppTheme.fontBold,
                                    color: AppTheme.text,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${widget.product.reviews} تقييم)',
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontSm,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppTheme.md),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.md,
                              vertical: AppTheme.sm,
                            ),
                            decoration: BoxDecoration(
                              color: widget.product.inStock
                                  ? AppTheme.success.withValues(alpha: 0.2)
                                  : AppTheme.error.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  widget.product.inStock
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 16,
                                  color: widget.product.inStock
                                      ? AppTheme.success
                                      : AppTheme.error,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.product.inStock
                                      ? 'متوفر (${widget.product.stock})'
                                      : 'نفذت الكمية',
                                  style: TextStyle(
                                    fontSize: AppTheme.fontSm,
                                    color: widget.product.inStock
                                        ? AppTheme.success
                                        : AppTheme.error,
                                    fontWeight: AppTheme.fontMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: AppTheme.xl),

                      // الوصف
                      const Text(
                        'الوصف',
                        style: TextStyle(
                          fontSize: AppTheme.fontLg,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: AppTheme.md),
                      Text(
                        widget.product.description,
                        style: const TextStyle(
                          fontSize: AppTheme.fontMd,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: AppTheme.xl),

                      // المقاسات
                      if (widget.product.sizes.isNotEmpty && widget.product.sizes[0] != 'واحد')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المقاس',
                              style: TextStyle(
                                fontSize: AppTheme.fontLg,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.text,
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            Wrap(
                              spacing: AppTheme.sm,
                              runSpacing: AppTheme.sm,
                              children: widget.product.sizes.map((size) {
                                final isSelected = selectedSize == size;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedSize = size;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.lg,
                                      vertical: AppTheme.md,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? AppTheme.gradientPrimary
                                          : null,
                                      color: isSelected ? null : AppTheme.card,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : AppTheme.border,
                                      ),
                                    ),
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        fontSize: AppTheme.fontMd,
                                        fontWeight: isSelected
                                            ? AppTheme.fontBold
                                            : AppTheme.fontMedium,
                                        color: isSelected
                                            ? AppTheme.white
                                            : AppTheme.text,
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 500.ms).scale(
                                      begin: const Offset(0.8, 0.8),
                                      delay: 500.ms,
                                    );
                              }).toList(),
                            ),
                            const SizedBox(height: AppTheme.xl),
                          ],
                        ),

                      // الألوان
                      if (widget.product.colors.isNotEmpty && widget.product.colors[0] != 'متعدد')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'اللون',
                              style: TextStyle(
                                fontSize: AppTheme.fontLg,
                                fontWeight: AppTheme.fontBold,
                                color: AppTheme.text,
                              ),
                            ),
                            const SizedBox(height: AppTheme.md),
                            Wrap(
                              spacing: AppTheme.sm,
                              runSpacing: AppTheme.sm,
                              children: widget.product.colors.map((color) {
                                final isSelected = selectedColor == color;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedColor = color;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.lg,
                                      vertical: AppTheme.md,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? AppTheme.gradientPrimary
                                          : null,
                                      color: isSelected ? null : AppTheme.card,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : AppTheme.border,
                                      ),
                                    ),
                                    child: Text(
                                      color,
                                      style: TextStyle(
                                        fontSize: AppTheme.fontMd,
                                        fontWeight: isSelected
                                            ? AppTheme.fontBold
                                            : AppTheme.fontMedium,
                                        color: isSelected
                                            ? AppTheme.white
                                            : AppTheme.text,
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 600.ms).scale(
                                      begin: const Offset(0.8, 0.8),
                                      delay: 600.ms,
                                    );
                              }).toList(),
                            ),
                            const SizedBox(height: AppTheme.xl),
                          ],
                        ),

                      // الكمية
                      const Text(
                        'الكمية',
                        style: TextStyle(
                          fontSize: AppTheme.fontLg,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: AppTheme.md),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: quantity > 1
                                  ? () {
                                      setState(() {
                                        quantity--;
                                      });
                                    }
                                  : null,
                              color: AppTheme.primary,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.lg,
                              ),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontXl,
                                  fontWeight: AppTheme.fontBold,
                                  color: AppTheme.text,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: quantity < widget.product.stock
                                  ? () {
                                      setState(() {
                                        quantity++;
                                      });
                                    }
                                  : null,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 700.ms),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // أزرار الإضافة للسلة
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(AppTheme.lg),
          decoration: BoxDecoration(
            color: AppTheme.background,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // زر الإضافة للمفضلة
                Consumer<FavoritesProvider>(
                  builder: (context, favorites, child) => Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          favorites.toggleProductFavorite(widget.product.id);
                        },
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: Icon(
                          favorites.isProductFavorite(widget.product.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: favorites.isProductFavorite(widget.product.id)
                              ? AppTheme.error
                              : AppTheme.text,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                // زر الإضافة للسلة
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.gradientPrimary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: AppTheme.shadowMd,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.product.inStock
                            ? () {
                                final cart = Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                );
                                cart.addItem(
                                  widget.product,
                                  selectedSize: selectedSize,
                                  selectedColor: selectedColor,
                                  quantity: quantity,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تمت إضافة $quantity من ${widget.product.name} للسلة',
                                    ),
                                    backgroundColor: AppTheme.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            : null,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_cart,
                                color: AppTheme.white,
                              ),
                              const SizedBox(width: AppTheme.sm),
                              Text(
                                'أضف للسلة - ${(widget.product.finalPrice * quantity).toInt()} ريال',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontLg,
                                  fontWeight: AppTheme.fontBold,
                                  color: AppTheme.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 600.ms).slideY(
                  begin: 1,
                  end: 0,
                  duration: 600.ms,
                ),
          ),
        ),
      ),
    );
  }

  IconData _getProductIcon(String category) {
    switch (category) {
      case 'ملابس':
        return Icons.checkroom;
      case 'معدات':
        return Icons.fitness_center;
      case 'مكملات':
        return Icons.local_drink;
      case 'إكسسوارات':
        return Icons.watch;
      default:
        return Icons.shopping_bag;
    }
  }
}
