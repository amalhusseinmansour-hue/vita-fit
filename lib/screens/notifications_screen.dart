import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final notifications = await ApiService.getNotifications();
    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(String id) async {
    await ApiService.markNotificationRead(id);
    _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    await ApiService.markAllNotificationsRead();
    _loadNotifications();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديد جميع الإشعارات كمقروءة'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'workout_reminder':
        return Icons.fitness_center;
      case 'promotion':
        return Icons.local_offer;
      case 'session':
        return Icons.videocam;
      case 'order':
        return Icons.local_shipping;
      case 'subscription':
        return Icons.card_membership;
      case 'nutrition':
        return Icons.restaurant_menu;
      case 'achievement':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'workout_reminder':
        return AppTheme.primary;
      case 'promotion':
        return AppTheme.warning;
      case 'session':
        return const Color(0xFF2D8CFF); // Zoom blue
      case 'order':
        return AppTheme.success;
      case 'subscription':
        return Colors.purple;
      case 'nutrition':
        return Colors.orange;
      case 'achievement':
        return Colors.amber;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inHours < 24) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} يوم';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
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
            'الإشعارات',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: AppTheme.fontXl,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            if (_notifications.any((n) => n['read'] == false))
              TextButton(
                onPressed: _markAllAsRead,
                child: const Text(
                  'قراءة الكل',
                  style: TextStyle(color: AppTheme.primary),
                ),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              )
            : _notifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    color: AppTheme.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.md),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return _buildNotificationItem(notification, index);
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
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 60,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.lg),
          const Text(
            'لا توجد إشعارات',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: AppTheme.fontLg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          const Text(
            'سنرسل لك إشعارات عند وجود تحديثات جديدة',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.fontMd,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    final isRead = notification['read'] == true;
    final type = notification['type'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.sm),
      decoration: BoxDecoration(
        color: isRead ? AppTheme.surface : AppTheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isRead ? AppTheme.border : AppTheme.primary.withOpacity(0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isRead) {
              _markAsRead(notification['id'].toString());
            }
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(
                    _getNotificationIcon(type),
                    color: _getNotificationColor(type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] ?? '',
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: AppTheme.fontMd,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['body'] ?? '',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.fontSm,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.sm),
                      Text(
                        _formatTime(notification['created_at']),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.fontXs,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }
}
