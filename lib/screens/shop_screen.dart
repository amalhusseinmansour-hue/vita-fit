import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import '../widgets/shimmer_loading.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String selectedCategory = 'الكل';
  List<Product> products = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'الكل',
    'ملابس',
    'معدات',
    'مكملات',
    'إكسسوارات',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final productsData = await ApiService.getProducts();
      setState(() {
        products = productsData.map((p) => Product(
          id: p['id']?.toString() ?? '',
          name: p['name'] ?? '',
          description: p['description'] ?? '',
          price: (p['price'] as num?)?.toDouble() ?? 0.0,
          discount: p['discount'] ?? 0,
          category: p['category'] ?? '',
          images: List<String>.from(p['images'] ?? []),
          rating: (p['rating'] as num?)?.toDouble() ?? 0.0,
          reviews: p['reviews'] ?? 0,
          sizes: List<String>.from(p['sizes'] ?? []),
          colors: List<String>.from(p['colors'] ?? []),
          inStock: p['inStock'] ?? true,
          stock: p['stock'] ?? 0,
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Product> get filteredProducts {
    var filtered = products;

    // Filter by category
    if (selectedCategory != 'الكل') {
      filtered = filtered.where((p) => p.category == selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
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
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: AppTheme.text),
              decoration: InputDecoration(
                hintText: 'ابحثي عن منتج...',
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    Navigator.pop(context);
                  },
                ),
                filled: true,
                fillColor: AppTheme.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              onSubmitted: (_) => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('بحث', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 160,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.gradientPrimary,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Text(
                          'متجري 🛍️',
                          style: TextStyle(
                            fontSize: AppTheme.fontXxl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.white,
                          ),
                        ),
                        SizedBox(height: AppTheme.sm),
                        Text(
                          'كل ما تحتاجينه لرحلة لياقتك',
                          style: TextStyle(
                            fontSize: AppTheme.fontMd,
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: AppTheme.white),
                    onPressed: _showSearchDialog,
                  ),
                  Consumer<CartProvider>(
                    builder: (context, cart, child) => IconButton(
                      icon: Stack(
                        children: [
                          const Icon(Icons.shopping_cart, color: AppTheme.white),
                          if (cart.itemCount > 0)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppTheme.error,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '${cart.itemCount}',
                                  style: const TextStyle(
                                    color: AppTheme.white,
                                    fontSize: 10,
                                    fontWeight: AppTheme.fontBold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // الفئات
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: AppTheme.sm),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.md,
                            vertical: AppTheme.sm,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppTheme.gradientPrimary
                                : null,
                            color: isSelected ? null : AppTheme.card,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                            boxShadow:
                                isSelected ? AppTheme.shadowSm : null,
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: AppTheme.fontSm,
                                fontWeight: isSelected
                                    ? AppTheme.fontSemibold
                                    : AppTheme.fontRegular,
                                color:
                                    isSelected ? AppTheme.white : AppTheme.text,
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
                    },
                  ),
                ),
              ),

              // شبكة المنتجات
              if (_isLoading)
                SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.md),
                  sliver: SliverToBoxAdapter(
                    child: ShimmerLoading.productGrid(itemCount: 6),
                  ),
                )
              else if (filteredProducts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
                        const SizedBox(height: AppTheme.md),
                        const Text(
                          'لا توجد منتجات في هذه الفئة',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: AppTheme.fontMd),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.md),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppTheme.md,
                      crossAxisSpacing: AppTheme.md,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filteredProducts[index];
                        return _buildProductCard(product, index);
                      },
                      childCount: filteredProducts.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  product: product,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppTheme.gradientSoft,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppTheme.radiusLg),
                        topRight: Radius.circular(AppTheme.radiusLg),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getProductIcon(product.category),
                        size: 60,
                        color: AppTheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // خصم
                  if (product.discount != null && product.discount! > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Text(
                          '-${product.discountText}',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: AppTheme.fontXs,
                            fontWeight: AppTheme.fontBold,
                          ),
                        ),
                      ),
                    ),
                  // مفضلة
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              // معلومات المنتج
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: AppTheme.fontSm,
                          fontWeight: AppTheme.fontSemibold,
                          color: AppTheme.text,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppTheme.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating}',
                            style: const TextStyle(
                              fontSize: AppTheme.fontXs,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.reviews})',
                            style: const TextStyle(
                              fontSize: AppTheme.fontXs,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.discount != null &&
                                  product.discount! > 0)
                                Text(
                                  '${product.price.toInt()} ريال',
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontXs,
                                    color: AppTheme.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                '${product.finalPrice.toInt()} ريال',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontMd,
                                  fontWeight: AppTheme.fontBold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              gradient: AppTheme.gradientPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: AppTheme.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (index * 100).ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 400.ms,
          delay: (index * 100).ms,
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
      case 'بطاقات إيجابية':
        return Icons.card_giftcard;
      case 'صالات رياضية':
        return Icons.location_on;
      case 'عناية رياضية':
        return Icons.spa;
      default:
        return Icons.shopping_bag;
    }
  }
}
