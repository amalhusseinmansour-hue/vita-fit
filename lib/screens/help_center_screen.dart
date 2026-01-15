import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  List<dynamic> _faq = [];
  bool _isLoading = true;
  final Set<int> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    _loadFAQ();
  }

  Future<void> _loadFAQ() async {
    final faq = await ApiService.getFAQ();
    setState(() {
      _faq = faq;
      _isLoading = false;
    });
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
            'مركز المساعدة',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: AppTheme.fontXl,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const TextField(
                  style: TextStyle(color: AppTheme.white),
                  decoration: InputDecoration(
                    hintText: 'ابحثي عن سؤالك...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: Icon(Icons.search, color: AppTheme.primary),
                    border: InputBorder.none,
                  ),
                ),
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),

              const SizedBox(height: AppTheme.xl),

              // Quick Actions
              const Text(
                'تواصلي معنا',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: AppTheme.fontLg,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: AppTheme.md),

              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.chat_bubble_outline,
                      title: 'محادثة مباشرة',
                      color: AppTheme.primary,
                      onTap: () => _openChat(),
                    ),
                  ),
                  const SizedBox(width: AppTheme.md),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.email_outlined,
                      title: 'البريد الإلكتروني',
                      color: AppTheme.info,
                      onTap: () => _sendEmail(),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: AppTheme.md),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.phone_outlined,
                      title: 'اتصال هاتفي',
                      color: AppTheme.success,
                      onTap: () => _makeCall(),
                    ),
                  ),
                  const SizedBox(width: AppTheme.md),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.chat,
                      title: 'واتساب',
                      color: const Color(0xFF25D366),
                      onTap: () => _openWhatsApp(),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: AppTheme.xl),

              // FAQ Section
              const Text(
                'الأسئلة الشائعة',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: AppTheme.fontLg,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: AppTheme.md),

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                )
              else
                ...List.generate(_faq.length, (index) {
                  final item = _faq[index];
                  final isExpanded = _expandedItems.contains(index);

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppTheme.sm),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: isExpanded ? AppTheme.primary : AppTheme.border,
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        title: Text(
                          item['question'] ?? '',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Icon(
                          isExpanded ? Icons.remove : Icons.add,
                          color: AppTheme.primary,
                        ),
                        onExpansionChanged: (expanded) {
                          setState(() {
                            if (expanded) {
                              _expandedItems.add(index);
                            } else {
                              _expandedItems.remove(index);
                            }
                          });
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppTheme.md),
                            child: Text(
                              item['answer'] ?? '',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (300 + index * 50).ms);
                }),

              const SizedBox(height: AppTheme.xl),

              // Didn't find answer
              Container(
                padding: const EdgeInsets.all(AppTheme.lg),
                decoration: BoxDecoration(
                  gradient: AppTheme.gradientPrimary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.help_outline,
                      color: AppTheme.white,
                      size: 48,
                    ),
                    const SizedBox(height: AppTheme.md),
                    const Text(
                      'لم تجدي إجابة لسؤالك؟',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: AppTheme.fontLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.sm),
                    const Text(
                      'فريق الدعم جاهز لمساعدتك على مدار الساعة',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: AppTheme.fontSm,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.md),
                    ElevatedButton(
                      onPressed: () => _openChat(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.white,
                        foregroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.xl,
                          vertical: AppTheme.md,
                        ),
                      ),
                      child: const Text('تحدثي مع الدعم'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: AppTheme.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.md),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: AppTheme.sm),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: AppTheme.fontSm,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري فتح المحادثة...'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Future<void> _sendEmail() async {
    final uri = Uri.parse('mailto:support@vitafit.online?subject=مساعدة VitaFit');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _makeCall() async {
    final uri = Uri.parse('tel:+971528344410');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/971528344410?text=مرحباً، أحتاج مساعدة من فريق الدعم الفني');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
