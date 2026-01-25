import 'package:flutter/material.dart';

/// أنواع الرسائل
enum ToastType { success, error, warning, info }

/// خدمة عرض الرسائل للمستخدم
class ToastService {
  static GlobalKey<ScaffoldMessengerState>? _messengerKey;

  /// تهيئة الخدمة
  static void init(GlobalKey<ScaffoldMessengerState> key) {
    _messengerKey = key;
  }

  /// عرض رسالة نجاح
  static void showSuccess(String message, {Duration? duration}) {
    _show(message, ToastType.success, duration: duration);
  }

  /// عرض رسالة خطأ
  static void showError(String message, {Duration? duration}) {
    _show(message, ToastType.error, duration: duration);
  }

  /// عرض رسالة تحذير
  static void showWarning(String message, {Duration? duration}) {
    _show(message, ToastType.warning, duration: duration);
  }

  /// عرض رسالة معلومات
  static void showInfo(String message, {Duration? duration}) {
    _show(message, ToastType.info, duration: duration);
  }

  /// عرض رسالة عدم اتصال
  static void showNoConnection() {
    _show('لا يوجد اتصال بالإنترنت', ToastType.warning);
  }

  /// عرض رسالة جاري التحميل
  static void showLoading(String message) {
    _show(message, ToastType.info, duration: const Duration(seconds: 30));
  }

  /// إخفاء الرسالة الحالية
  static void hide() {
    _messengerKey?.currentState?.hideCurrentSnackBar();
  }

  /// عرض الرسالة
  static void _show(
    String message,
    ToastType type, {
    Duration? duration,
  }) {
    final messenger = _messengerKey?.currentState;
    if (messenger == null) return;

    // إخفاء أي رسالة سابقة
    messenger.hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIcon(type),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getColor(type),
      duration: duration ?? const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      action: SnackBarAction(
        label: 'إغلاق',
        textColor: Colors.white.withOpacity(0.8),
        onPressed: () {
          messenger.hideCurrentSnackBar();
        },
      ),
    );

    messenger.showSnackBar(snackBar);
  }

  /// الحصول على أيقونة حسب النوع
  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  /// الحصول على لون حسب النوع
  static Color _getColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Color(0xFF4CAF50);
      case ToastType.error:
        return const Color(0xFFF44336);
      case ToastType.warning:
        return const Color(0xFFFF9800);
      case ToastType.info:
        return const Color(0xFF2196F3);
    }
  }
}

/// Widget لعرض dialog التأكيد
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDangerous;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'تأكيد',
    this.cancelText = 'إلغاء',
    this.onConfirm,
    this.onCancel,
    this.isDangerous = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () {
            onCancel?.call();
            Navigator.of(context).pop(false);
          },
          child: Text(
            cancelText,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            onConfirm?.call();
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDangerous ? Colors.red : const Color(0xFFFF69B4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}

/// Widget لعرض dialog التحميل
class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({
    super.key,
    this.message = 'جاري التحميل...',
  });

  static void show(BuildContext context, {String message = 'جاري التحميل...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFFFF69B4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
