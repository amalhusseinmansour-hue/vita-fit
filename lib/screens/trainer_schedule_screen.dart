import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';

class TrainerScheduleScreen extends StatefulWidget {
  const TrainerScheduleScreen({super.key});

  @override
  State<TrainerScheduleScreen> createState() => _TrainerScheduleScreenState();
}

class _TrainerScheduleScreenState extends State<TrainerScheduleScreen> {
  bool _isLoading = true;
  int _selectedDayIndex = DateTime.now().weekday - 1;

  final List<String> _days = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];

  List<Map<String, dynamic>> _allSessions = [];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);

    // Load sessions from API/Demo
    final sessions = await ApiService.getTrainerSessions();

    setState(() {
      _allSessions = List<Map<String, dynamic>>.from(sessions);
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getSessionsForDay(String day) {
    return _allSessions.where((s) => s['day'] == day).toList();
  }

  void _showCreateSessionDialog() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    final durationController = TextEditingController(text: '45');
    final maxParticipantsController = TextEditingController(text: '10');
    final zoomLinkController = TextEditingController();
    final zoomIdController = TextEditingController();
    final zoomPasswordController = TextEditingController();
    final notesController = TextEditingController();

    String selectedType = 'جماعي';
    String selectedDay = _days[_selectedDayIndex];
    bool isOnline = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientPrimary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Icon(Icons.add, color: AppTheme.white, size: 24),
                ),
                const SizedBox(width: AppTheme.md),
                const Text(
                  'إنشاء جلسة جديدة',
                  style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Session Title
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: _inputDecoration('عنوان الجلسة', Icons.title),
                  ),
                  const SizedBox(height: AppTheme.md),

                  // Day Selection
                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    dropdownColor: AppTheme.card,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: _inputDecoration('اليوم', Icons.calendar_today),
                    items: _days.map((day) => DropdownMenuItem(
                      value: day,
                      child: Text(day),
                    )).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedDay = value!);
                    },
                  ),
                  const SizedBox(height: AppTheme.md),

                  // Time
                  TextField(
                    controller: timeController,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: _inputDecoration('الوقت (مثال: 10:00 صباحاً)', Icons.access_time),
                  ),
                  const SizedBox(height: AppTheme.md),

                  // Duration
                  TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: _inputDecoration('المدة (بالدقائق)', Icons.timer),
                  ),
                  const SizedBox(height: AppTheme.md),

                  // Session Type
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => selectedType = 'جماعي'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                            decoration: BoxDecoration(
                              gradient: selectedType == 'جماعي' ? AppTheme.gradientPrimary : null,
                              color: selectedType == 'جماعي' ? null : AppTheme.card,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.group, color: selectedType == 'جماعي' ? AppTheme.white : AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Text('جماعي', style: TextStyle(color: selectedType == 'جماعي' ? AppTheme.white : AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.sm),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => selectedType = 'فردي'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: AppTheme.md),
                            decoration: BoxDecoration(
                              gradient: selectedType == 'فردي' ? AppTheme.gradientPrimary : null,
                              color: selectedType == 'فردي' ? null : AppTheme.card,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person, color: selectedType == 'فردي' ? AppTheme.white : AppTheme.textSecondary),
                                const SizedBox(width: 8),
                                Text('فردي', style: TextStyle(color: selectedType == 'فردي' ? AppTheme.white : AppTheme.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.md),

                  // Max Participants
                  if (selectedType == 'جماعي')
                    TextField(
                      controller: maxParticipantsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppTheme.white),
                      decoration: _inputDecoration('الحد الأقصى للمشتركات', Icons.people),
                    ),
                  if (selectedType == 'جماعي') const SizedBox(height: AppTheme.md),

                  // Online/Offline Toggle
                  Container(
                    padding: const EdgeInsets.all(AppTheme.md),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: isOnline ? const Color(0xFF2D8CFF) : AppTheme.border, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOnline ? Icons.videocam : Icons.location_on,
                          color: isOnline ? const Color(0xFF2D8CFF) : AppTheme.primary,
                        ),
                        const SizedBox(width: AppTheme.sm),
                        Expanded(
                          child: Text(
                            isOnline ? 'جلسة أونلاين عبر Zoom' : 'جلسة حضورية',
                            style: const TextStyle(color: AppTheme.white),
                          ),
                        ),
                        Switch(
                          value: isOnline,
                          activeColor: const Color(0xFF2D8CFF),
                          onChanged: (value) => setDialogState(() => isOnline = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.md),

                  // Zoom Details (if online)
                  if (isOnline) ...[
                    Container(
                      padding: const EdgeInsets.all(AppTheme.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D8CFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: const Color(0xFF2D8CFF).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Zoom_Logo_2022.svg/120px-Zoom_Logo_2022.svg.png',
                                height: 20,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.videocam,
                                  color: Color(0xFF2D8CFF),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppTheme.sm),
                              const Text(
                                'معلومات Zoom',
                                style: TextStyle(
                                  color: Color(0xFF2D8CFF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.md),
                          TextField(
                            controller: zoomLinkController,
                            style: const TextStyle(color: AppTheme.white),
                            decoration: _inputDecoration('رابط Zoom', Icons.link),
                          ),
                          const SizedBox(height: AppTheme.sm),
                          TextField(
                            controller: zoomIdController,
                            style: const TextStyle(color: AppTheme.white),
                            decoration: _inputDecoration('Meeting ID', Icons.numbers),
                          ),
                          const SizedBox(height: AppTheme.sm),
                          TextField(
                            controller: zoomPasswordController,
                            style: const TextStyle(color: AppTheme.white),
                            decoration: _inputDecoration('Password', Icons.lock),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.md),
                  ],

                  // Notes
                  TextField(
                    controller: notesController,
                    maxLines: 2,
                    style: const TextStyle(color: AppTheme.white),
                    decoration: _inputDecoration('ملاحظات للمتدربات', Icons.note),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  if (titleController.text.isEmpty || timeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('الرجاء إدخال عنوان الجلسة والوقت'),
                        backgroundColor: AppTheme.error,
                      ),
                    );
                    return;
                  }

                  // Create session
                  final newSession = {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'title': titleController.text,
                    'day': selectedDay,
                    'time': timeController.text,
                    'duration': int.tryParse(durationController.text) ?? 45,
                    'type': selectedType,
                    'maxParticipants': selectedType == 'جماعي'
                        ? int.tryParse(maxParticipantsController.text) ?? 10
                        : 1,
                    'participants': 0,
                    'status': 'مجدولة',
                    'isOnline': isOnline,
                    'location': isOnline ? 'أونلاين عبر Zoom' : 'الصالة الرياضية',
                    'meeting_url': zoomLinkController.text,
                    'meeting_id': zoomIdController.text,
                    'meeting_password': zoomPasswordController.text,
                    'notes': notesController.text,
                    'trainer_name': 'كابتن سارة الحربي',
                  };

                  // Save to API
                  final result = await ApiService.createTrainerSession(newSession);

                  if (mounted) {
                    Navigator.pop(context);

                    if (result['success'] == true) {
                      setState(() {
                        _allSessions.add(newSession);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppTheme.white),
                              const SizedBox(width: 8),
                              Text(isOnline
                                  ? 'تم إنشاء الجلسة الأونلاين بنجاح!'
                                  : 'تم إنشاء الجلسة بنجاح!'),
                            ],
                          ),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg, vertical: AppTheme.md),
                ),
                icon: const Icon(Icons.add, color: AppTheme.white),
                label: const Text('إنشاء الجلسة', style: TextStyle(color: AppTheme.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
      filled: true,
      fillColor: AppTheme.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: BorderSide(color: AppTheme.border.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.md, vertical: AppTheme.sm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppTheme.lg),
                decoration: const BoxDecoration(
                  gradient: AppTheme.gradientPrimary,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'جدولي الأسبوعي',
                          style: TextStyle(
                            fontSize: AppTheme.fontXl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _loadSchedule,
                          icon: const Icon(Icons.refresh, color: AppTheme.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.md),
                    // Week Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeekStat(
                          'حصص الأسبوع',
                          _allSessions.length.toString(),
                          Icons.event,
                        ),
                        _buildWeekStat(
                          'المشتركات',
                          _getTotalParticipants().toString(),
                          Icons.people,
                        ),
                        _buildWeekStat(
                          'جلسات أونلاين',
                          _allSessions.where((s) => s['isOnline'] == true).length.toString(),
                          Icons.videocam,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Days Tabs
              Container(
                height: 70,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.sm),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
                  itemCount: _days.length,
                  itemBuilder: (context, index) {
                    return _buildDayTab(index);
                  },
                ),
              ),

              // Sessions List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                    : _buildSessionsList(),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateSessionDialog,
          backgroundColor: AppTheme.primary,
          icon: const Icon(Icons.add, color: AppTheme.white),
          label: const Text('إضافة جلسة', style: TextStyle(color: AppTheme.white)),
        ),
      ),
    );
  }

  Widget _buildWeekStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppTheme.fontLg,
            fontWeight: AppTheme.fontBold,
            color: AppTheme.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTheme.fontXs,
            color: AppTheme.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDayTab(int index) {
    final isSelected = _selectedDayIndex == index;
    final day = _days[index];
    final sessionsCount = _getSessionsForDay(day).length;

    return GestureDetector(
      onTap: () => setState(() => _selectedDayIndex = index),
      child: Container(
        margin: const EdgeInsets.only(left: AppTheme.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.md,
          vertical: AppTheme.sm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.gradientPrimary : null,
          color: isSelected ? null : AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: AppTheme.fontSm,
                fontWeight: isSelected ? AppTheme.fontBold : AppTheme.fontMedium,
                color: isSelected ? AppTheme.white : AppTheme.textSecondary,
              ),
            ),
            if (sessionsCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.white : AppTheme.primary,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  '$sessionsCount',
                  style: TextStyle(
                    fontSize: AppTheme.fontXs,
                    fontWeight: AppTheme.fontBold,
                    color: isSelected ? AppTheme.primary : AppTheme.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    final selectedDay = _days[_selectedDayIndex];
    final sessions = _getSessionsForDay(selectedDay);

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppTheme.md),
            const Text(
              'لا توجد جلسات في هذا اليوم',
              style: TextStyle(
                fontSize: AppTheme.fontLg,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.md),
            ElevatedButton.icon(
              onPressed: _showCreateSessionDialog,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              icon: const Icon(Icons.add, color: AppTheme.white),
              label: const Text('إنشاء جلسة', style: TextStyle(color: AppTheme.white)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.md),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(session, index);
      },
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, int index) {
    final status = session['status'] as String? ?? 'مجدولة';
    final statusColor = status == 'مكتملة'
        ? AppTheme.textSecondary
        : status == 'جارية'
            ? AppTheme.success
            : AppTheme.primary;

    final type = session['type'] as String? ?? 'جماعي';
    final typeIcon = type == 'فردي' ? Icons.person : Icons.group;
    final isOnline = session['isOnline'] == true;

    final participants = session['participants'] as int? ?? 0;
    final maxParticipants = session['maxParticipants'] as int? ?? 1;
    final occupancyRate = maxParticipants > 0 ? participants / maxParticipants : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
        border: Border.all(
          color: isOnline ? const Color(0xFF2D8CFF).withOpacity(0.5) : statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSessionDetails(session),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.sm),
                      decoration: BoxDecoration(
                        gradient: isOnline
                            ? const LinearGradient(colors: [Color(0xFF2D8CFF), Color(0xFF0066CC)])
                            : AppTheme.gradientPrimary,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Icon(
                        isOnline ? Icons.videocam : typeIcon,
                        color: AppTheme.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  session['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontMd,
                                    fontWeight: AppTheme.fontBold,
                                    color: AppTheme.white,
                                  ),
                                ),
                              ),
                              if (isOnline)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2D8CFF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Zoom',
                                    style: TextStyle(
                                      color: AppTheme.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                session['time'] ?? '',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSm,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              if (session['duration'] != null) ...[
                                const Text(' • ', style: TextStyle(color: AppTheme.textSecondary)),
                                Text(
                                  '${session['duration']} دقيقة',
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontSm,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: AppTheme.fontXs,
                          fontWeight: AppTheme.fontBold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.md),
                Row(
                  children: [
                    Icon(
                      isOnline ? Icons.language : Icons.location_on,
                      size: 16,
                      color: isOnline ? const Color(0xFF2D8CFF) : AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      session['location'] ?? '',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSm,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.people,
                      size: 16,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$participants/$maxParticipants',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSm,
                        color: AppTheme.white,
                        fontWeight: AppTheme.fontMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  child: LinearProgressIndicator(
                    value: occupancyRate,
                    minHeight: 4,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      occupancyRate >= 1.0
                          ? AppTheme.error
                          : occupancyRate >= 0.8
                              ? AppTheme.warning
                              : AppTheme.success,
                    ),
                  ),
                ),
                if (isOnline && session['meeting_url'] != null && (session['meeting_url'] as String).isNotEmpty) ...[
                  const SizedBox(height: AppTheme.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchZoom(session['meeting_url']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D8CFF),
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.sm),
                      ),
                      icon: const Icon(Icons.videocam, color: AppTheme.white, size: 18),
                      label: const Text('بدء الجلسة', style: TextStyle(color: AppTheme.white)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2, end: 0);
  }

  Future<void> _launchZoom(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح رابط Zoom'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _showSessionDetails(Map<String, dynamic> session) {
    final isOnline = session['isOnline'] == true;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppTheme.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        session['title'] ?? '',
                        style: const TextStyle(
                          fontSize: AppTheme.fontXl,
                          fontWeight: AppTheme.fontBold,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppTheme.white),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.lg),
                _buildDetailRow(Icons.access_time, 'الوقت', session['time'] ?? ''),
                _buildDetailRow(Icons.timer, 'المدة', '${session['duration'] ?? 45} دقيقة'),
                _buildDetailRow(
                  isOnline ? Icons.language : Icons.location_on,
                  'المكان',
                  session['location'] ?? '',
                ),
                _buildDetailRow(Icons.category, 'النوع', session['type'] ?? 'جماعي'),
                _buildDetailRow(
                  Icons.people,
                  'المشتركات',
                  '${session['participants'] ?? 0}/${session['maxParticipants'] ?? 1}',
                ),
                _buildDetailRow(Icons.flag, 'الحالة', session['status'] ?? 'مجدولة'),

                if (session['notes'] != null && (session['notes'] as String).isNotEmpty) ...[
                  const SizedBox(height: AppTheme.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.md),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.note, color: AppTheme.primary, size: 18),
                            SizedBox(width: 8),
                            Text('ملاحظات', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          session['notes'],
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],

                if (isOnline && session['meeting_id'] != null) ...[
                  const SizedBox(height: AppTheme.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D8CFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: const Color(0xFF2D8CFF).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.videocam, color: Color(0xFF2D8CFF), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'معلومات Zoom',
                              style: TextStyle(
                                color: Color(0xFF2D8CFF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.md),
                        Text('Meeting ID: ${session['meeting_id']}', style: const TextStyle(color: AppTheme.white)),
                        if (session['meeting_password'] != null)
                          Text('Password: ${session['meeting_password']}', style: const TextStyle(color: AppTheme.white)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppTheme.xl),

                if (isOnline && session['meeting_url'] != null && (session['meeting_url'] as String).isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _launchZoom(session['meeting_url']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D8CFF),
                        padding: const EdgeInsets.all(AppTheme.md),
                      ),
                      icon: const Icon(Icons.videocam, color: AppTheme.white),
                      label: const Text('بدء الجلسة عبر Zoom', style: TextStyle(color: AppTheme.white)),
                    ),
                  ),

                const SizedBox(height: AppTheme.md),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('لتعديل الجلسة، احذفها وأنشئ جلسة جديدة'),
                              backgroundColor: AppTheme.info,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.all(AppTheme.md),
                        ),
                        icon: const Icon(Icons.edit, color: AppTheme.white),
                        label: const Text('تعديل', style: TextStyle(color: AppTheme.white)),
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteSession(session);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.error,
                          padding: const EdgeInsets.all(AppTheme.md),
                        ),
                        icon: const Icon(Icons.delete, color: AppTheme.white),
                        label: const Text('حذف', style: TextStyle(color: AppTheme.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteSession(Map<String, dynamic> session) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('حذف الجلسة', style: TextStyle(color: AppTheme.error)),
          content: Text(
            'هل أنتِ متأكدة من حذف "${session['title']}"؟',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _allSessions.removeWhere((s) => s['id'] == session['id']);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف الجلسة'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              child: const Text('حذف', style: TextStyle(color: AppTheme.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.md),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: AppTheme.sm),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: AppTheme.fontMd,
              color: AppTheme.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppTheme.fontMd,
                color: AppTheme.white,
                fontWeight: AppTheme.fontMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalParticipants() {
    return _allSessions.fold(0, (sum, session) => sum + ((session['participants'] as int?) ?? 0));
  }
}
