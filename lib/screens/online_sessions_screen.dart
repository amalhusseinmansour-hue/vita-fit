import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import 'meeting_webview_screen.dart';

class OnlineSessionsScreen extends StatefulWidget {
  const OnlineSessionsScreen({super.key});

  @override
  State<OnlineSessionsScreen> createState() => _OnlineSessionsScreenState();
}

class _OnlineSessionsScreenState extends State<OnlineSessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _upcomingSessions = [];
  List<dynamic> _pastSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);

    try {
      final sessions = await ApiService.getMySessions();

      final now = DateTime.now();
      final upcoming = <dynamic>[];
      final past = <dynamic>[];

      for (var session in sessions) {
        final scheduledAt = DateTime.parse(session['scheduled_at']);
        if (scheduledAt.isAfter(now)) {
          upcoming.add(session);
        } else {
          past.add(session);
        }
      }

      // Sort upcoming by date (soonest first)
      upcoming.sort((a, b) => DateTime.parse(a['scheduled_at'])
          .compareTo(DateTime.parse(b['scheduled_at'])));

      // Sort past by date (most recent first)
      past.sort((a, b) => DateTime.parse(b['scheduled_at'])
          .compareTo(DateTime.parse(a['scheduled_at'])));

      setState(() {
        _upcomingSessions = upcoming;
        _pastSessions = past;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinSession(dynamic session) async {
    final meetingUrl = _getMeetingLink(session);
    if (meetingUrl == null || meetingUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رابط الجلسة غير متوفر'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
      return;
    }

    // On web, use external browser (WebView doesn't work well on web)
    if (kIsWeb) {
      final uri = Uri.parse(meetingUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح رابط الجلسة'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } else {
      // On mobile, use in-app WebView
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingWebViewScreen(
              meetingUrl: meetingUrl,
              meetingTitle: session['title'] ?? 'جلسة تدريبية',
              meetingId: session['meeting_id']?.toString(),
              meetingPassword: session['meeting_password']?.toString(),
            ),
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
            'الجلسات الأونلاين',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: AppTheme.fontXl,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: const [
              Tab(text: 'القادمة'),
              Tab(text: 'السابقة'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildSessionsList(_upcomingSessions, isUpcoming: true),
                  _buildSessionsList(_pastSessions, isUpcoming: false),
                ],
              ),
      ),
    );
  }

  Widget _buildSessionsList(List<dynamic> sessions, {required bool isUpcoming}) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_available : Icons.history,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: AppTheme.md),
            Text(
              isUpcoming ? 'لا توجد جلسات قادمة' : 'لا توجد جلسات سابقة',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.fontLg,
              ),
            ),
            if (isUpcoming) ...[
              const SizedBox(height: AppTheme.md),
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to trainers to book session
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('احجزي جلسة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.white,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSessions,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.md),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return _buildSessionCard(session, isUpcoming, index);
        },
      ),
    );
  }

  Widget _buildSessionCard(dynamic session, bool isUpcoming, int index) {
    final scheduledAt = DateTime.parse(session['scheduled_at']);
    final duration = session['duration_minutes'] ?? 45;
    final status = session['status'] ?? 'scheduled';

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
            decoration: BoxDecoration(
              gradient: isUpcoming ? AppTheme.gradientPrimary : null,
              color: isUpcoming ? null : AppTheme.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLg),
                topRight: Radius.circular(AppTheme.radiusLg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(isUpcoming ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(
                    Icons.videocam,
                    color: isUpcoming ? AppTheme.white : AppTheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session['title'] ?? 'جلسة تدريبية',
                        style: TextStyle(
                          color: isUpcoming ? AppTheme.white : AppTheme.text,
                          fontSize: AppTheme.fontMd,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'مع ${session['trainer_name'] ?? 'المدربة'}',
                        style: TextStyle(
                          color: isUpcoming
                              ? AppTheme.white.withOpacity(0.8)
                              : AppTheme.textSecondary,
                          fontSize: AppTheme.fontSm,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status, isUpcoming),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(AppTheme.md),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDetailItem(
                      icon: Icons.calendar_today,
                      label: 'التاريخ',
                      value: _formatDate(scheduledAt),
                    ),
                    const SizedBox(width: AppTheme.lg),
                    _buildDetailItem(
                      icon: Icons.access_time,
                      label: 'الوقت',
                      value: _formatTime(scheduledAt),
                    ),
                    const SizedBox(width: AppTheme.lg),
                    _buildDetailItem(
                      icon: Icons.timer,
                      label: 'المدة',
                      value: '$duration دقيقة',
                    ),
                  ],
                ),

                if (session['notes'] != null && session['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: AppTheme.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.sm),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
                        const SizedBox(width: AppTheme.sm),
                        Expanded(
                          child: Text(
                            session['notes'],
                            style: const TextStyle(
                              color: AppTheme.text,
                              fontSize: AppTheme.fontSm,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (isUpcoming && _getMeetingLink(session) != null) ...[
                  const SizedBox(height: AppTheme.md),

                  // Meeting Details
                  if (session['meeting_id'] != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.md),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _getMeetingIcon(session),
                              const SizedBox(width: AppTheme.sm),
                              Text(
                                'معلومات ${_getPlatformName(session)}',
                                style: const TextStyle(
                                  color: AppTheme.text,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppTheme.fontSm,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.sm),
                          Row(
                            children: [
                              const Text(
                                'Meeting ID: ',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: AppTheme.fontSm),
                              ),
                              SelectableText(
                                session['meeting_id'] ?? '',
                                style: const TextStyle(
                                  color: AppTheme.text,
                                  fontWeight: FontWeight.w500,
                                  fontSize: AppTheme.fontSm,
                                ),
                              ),
                            ],
                          ),
                          if (session['meeting_password'] != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text(
                                  'Password: ',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: AppTheme.fontSm),
                                ),
                                SelectableText(
                                  session['meeting_password'],
                                  style: const TextStyle(
                                    color: AppTheme.text,
                                    fontWeight: FontWeight.w500,
                                    fontSize: AppTheme.fontSm,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.sm),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _joinSession(session),
                      icon: const Icon(Icons.video_call),
                      label: Text('انضمي للجلسة عبر ${_getPlatformName(session)}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getPlatformColor(session),
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],

                if (!isUpcoming && session['rating'] != null) ...[
                  const SizedBox(height: AppTheme.md),
                  Row(
                    children: [
                      const Text(
                        'تقييمك: ',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < (session['rating'] ?? 0)
                              ? Icons.star
                              : Icons.star_border,
                          color: AppTheme.warning,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (index * 100).ms);
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.fontXs,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: AppTheme.fontSm,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isUpcoming) {
    Color color;
    String text;

    switch (status) {
      case 'scheduled':
        color = isUpcoming ? AppTheme.white : AppTheme.info;
        text = 'مجدولة';
        break;
      case 'in_progress':
        color = AppTheme.success;
        text = 'جارية';
        break;
      case 'completed':
        color = AppTheme.success;
        text = 'مكتملة';
        break;
      case 'cancelled':
        color = AppTheme.error;
        text = 'ملغاة';
        break;
      default:
        color = AppTheme.textSecondary;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUpcoming ? AppTheme.white.withOpacity(0.2) : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isUpcoming ? AppTheme.white : color,
          fontSize: AppTheme.fontXs,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'م' : 'ص';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  // Helper methods for meeting platforms
  String? _getMeetingLink(dynamic session) {
    return session['meeting_link'] ?? session['meeting_url'] ?? session['zoom_join_url'];
  }

  String _getPlatformName(dynamic session) {
    final platform = session['meeting_platform'] ?? 'zoom';
    switch (platform) {
      case 'google_meet':
        return 'Google Meet';
      case 'zoom':
        return 'Zoom';
      default:
        return 'الفيديو';
    }
  }

  Color _getPlatformColor(dynamic session) {
    final platform = session['meeting_platform'] ?? 'zoom';
    switch (platform) {
      case 'google_meet':
        return const Color(0xFF00897B); // Google Meet green
      case 'zoom':
        return const Color(0xFF2D8CFF); // Zoom blue
      default:
        return AppTheme.primary;
    }
  }

  Widget _getMeetingIcon(dynamic session) {
    final platform = session['meeting_platform'] ?? 'zoom';
    switch (platform) {
      case 'google_meet':
        return const Icon(
          Icons.video_camera_front,
          color: Color(0xFF00897B),
          size: 20,
        );
      case 'zoom':
        return Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Zoom_Logo_2022.svg/120px-Zoom_Logo_2022.svg.png',
          height: 20,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.videocam,
            color: Color(0xFF2D8CFF),
            size: 20,
          ),
        );
      default:
        return const Icon(
          Icons.videocam,
          color: AppTheme.primary,
          size: 20,
        );
    }
  }
}
