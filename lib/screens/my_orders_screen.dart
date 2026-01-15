import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final orders = await ApiService.getMyOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
            'طلباتي',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: AppTheme.fontXl,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              )
            : _orders.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    color: AppTheme.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.md),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(_orders[index], index);
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: AppTheme.md),
          const Text(
            'لا توجد طلبات',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.fontLg,
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          const Text(
            'ابدئي التسوق من متجرنا',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.fontMd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order, int index) {
    final status = order['status'] ?? 'pending';
    final statusInfo = _getStatusInfo(status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppTheme.md),
            decoration: const BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLg),
                topRight: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['order_number'] ?? 'طلب #${order['id']}',
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: AppTheme.fontMd,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order['created_at'] ?? '',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.fontSm,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusInfo.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusInfo.icon,
                        color: statusInfo.color,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusInfo.label,
                        style: TextStyle(
                          color: statusInfo.color,
                          fontSize: AppTheme.fontXs,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(AppTheme.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'عدد المنتجات',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    Text(
                      '${order['items_count'] ?? 0} منتج',
                      style: const TextStyle(color: AppTheme.white),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.sm),
                const Divider(color: AppTheme.border),
                const SizedBox(height: AppTheme.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الإجمالي',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(order['total'] ?? 0).toStringAsFixed(2)} AED',
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

          // Progress indicator for pending/shipped orders
          if (status == 'pending' || status == 'processing' || status == 'shipped')
            Container(
              padding: const EdgeInsets.all(AppTheme.md),
              decoration: const BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.radiusLg),
                  bottomRight: Radius.circular(AppTheme.radiusLg),
                ),
              ),
              child: _buildProgressIndicator(status),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms);
  }

  Widget _buildProgressIndicator(String status) {
    final steps = ['pending', 'processing', 'shipped', 'delivered'];
    final stepLabels = ['قيد الانتظار', 'جاري التحضير', 'تم الشحن', 'تم التوصيل'];
    final currentIndex = steps.indexOf(status);

    return Row(
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentIndex;
        final isLast = index == steps.length - 1;

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.primary
                          : AppTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? AppTheme.primary
                            : AppTheme.border,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: AppTheme.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stepLabels[index],
                    style: TextStyle(
                      color: isCompleted
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: index < currentIndex
                        ? AppTheme.primary
                        : AppTheme.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return _StatusInfo(
          label: 'قيد الانتظار',
          color: AppTheme.warning,
          icon: Icons.schedule,
        );
      case 'processing':
        return _StatusInfo(
          label: 'جاري التحضير',
          color: AppTheme.info,
          icon: Icons.inventory,
        );
      case 'shipped':
        return _StatusInfo(
          label: 'تم الشحن',
          color: AppTheme.primary,
          icon: Icons.local_shipping,
        );
      case 'delivered':
        return _StatusInfo(
          label: 'تم التوصيل',
          color: AppTheme.success,
          icon: Icons.check_circle,
        );
      case 'cancelled':
        return _StatusInfo(
          label: 'ملغي',
          color: AppTheme.error,
          icon: Icons.cancel,
        );
      default:
        return _StatusInfo(
          label: status,
          color: AppTheme.textSecondary,
          icon: Icons.info,
        );
    }
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  _StatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}
