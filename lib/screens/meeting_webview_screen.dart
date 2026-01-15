import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constants/app_theme.dart';

class MeetingWebViewScreen extends StatefulWidget {
  final String meetingUrl;
  final String meetingTitle;
  final String? meetingId;
  final String? meetingPassword;

  const MeetingWebViewScreen({
    super.key,
    required this.meetingUrl,
    required this.meetingTitle,
    this.meetingId,
    this.meetingPassword,
  });

  @override
  State<MeetingWebViewScreen> createState() => _MeetingWebViewScreenState();
}

class _MeetingWebViewScreenState extends State<MeetingWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
              if (progress == 100) {
                _isLoading = false;
              }
            });
          },
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation for meeting platforms
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.meetingUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppTheme.white),
            onPressed: () => _showExitConfirmation(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.meetingTitle,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: AppTheme.fontMd,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.meetingId != null)
                Text(
                  'Meeting ID: ${widget.meetingId}',
                  style: TextStyle(
                    color: AppTheme.white.withValues(alpha: 0.7),
                    fontSize: AppTheme.fontXs,
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.white),
              onPressed: () => _controller.reload(),
              tooltip: 'تحديث',
            ),
            if (widget.meetingPassword != null)
              IconButton(
                icon: const Icon(Icons.copy, color: AppTheme.white),
                onPressed: () => _copyMeetingInfo(),
                tooltip: 'نسخ معلومات الاجتماع',
              ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _loadingProgress,
                    backgroundColor: AppTheme.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),
                  Expanded(
                    child: Container(
                      color: AppTheme.background.withValues(alpha: 0.8),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppTheme.primary),
                            SizedBox(height: AppTheme.md),
                            Text(
                              'جاري تحميل الجلسة...',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: AppTheme.fontMd,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(AppTheme.md),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(
              top: BorderSide(color: AppTheme.border),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showExitConfirmation(),
                    icon: const Icon(Icons.call_end),
                    label: const Text('إنهاء الجلسة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
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

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text(
            'إنهاء الجلسة',
            style: TextStyle(color: AppTheme.white),
          ),
          content: const Text(
            'هل أنتِ متأكدة من إنهاء الجلسة والخروج؟',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Exit webview
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
              ),
              child: const Text('إنهاء'),
            ),
          ],
        ),
      ),
    );
  }

  void _copyMeetingInfo() {
    final info = StringBuffer();
    info.writeln('معلومات الاجتماع:');
    info.writeln('العنوان: ${widget.meetingTitle}');
    if (widget.meetingId != null) {
      info.writeln('Meeting ID: ${widget.meetingId}');
    }
    if (widget.meetingPassword != null) {
      info.writeln('Password: ${widget.meetingPassword}');
    }
    info.writeln('الرابط: ${widget.meetingUrl}');

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: info.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ معلومات الاجتماع'),
        backgroundColor: AppTheme.success,
      ),
    );
  }
}
