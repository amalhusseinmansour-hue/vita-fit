import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class TrainerClientsScreen extends StatefulWidget {
  const TrainerClientsScreen({super.key});

  @override
  State<TrainerClientsScreen> createState() => _TrainerClientsScreenState();
}

class _TrainerClientsScreenState extends State<TrainerClientsScreen> {
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterCategory = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    try {
      final clients = await ApiService.getTrainerClients();

      // تحويل البيانات إلى الشكل المطلوب
      final formattedClients = clients.map<Map<String, dynamic>>((client) {
        return {
          'id': client['id']?.toString() ?? '',
          'name': client['name'] ?? 'متدربة',
          'age': client['age'] ?? 25,
          'phone': client['phone'] ?? '',
          'email': client['email'] ?? '',
          'goal': client['goal'] ?? 'لياقة عامة',
          'progress': client['progress'] ?? 50,
          'joinDate': client['joined_at'] ?? '2024-01-01',
          'sessionsCompleted': client['total_sessions'] ?? 0,
          'totalSessions': (client['total_sessions'] ?? 0) + 12,
          'weight': client['weight'] ?? 60,
          'targetWeight': client['target_weight'] ?? 55,
          'status': client['status'] ?? 'نشطة',
          'subscription': client['subscription'] ?? 'Basic',
          'lastSession': client['last_session'] ?? '',
        };
      }).toList();

      setState(() {
        _clients = formattedClients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredClients {
    var filtered = _clients;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((client) {
        final name = client['name'].toString().toLowerCase();
        final goal = client['goal'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || goal.contains(query);
      }).toList();
    }

    // Filter by category
    if (_filterCategory != 'الكل') {
      if (_filterCategory == 'نشطة') {
        filtered = filtered.where((c) => c['status'] == 'نشطة').toList();
      } else if (_filterCategory == 'متوقفة') {
        filtered = filtered.where((c) => c['status'] == 'متوقفة').toList();
      }
    }

    return filtered;
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
                          'متدرباتي',
                          style: TextStyle(
                            fontSize: AppTheme.fontXl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.white,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _loadClients,
                              icon: const Icon(Icons.refresh, color: AppTheme.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.md),
                    // Search Bar
                    TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: const TextStyle(color: AppTheme.white),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن متدربة...',
                        hintStyle: TextStyle(
                          color: AppTheme.white.withValues(alpha: 0.6),
                        ),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.white),
                        filled: true,
                        fillColor: AppTheme.white.withValues(alpha: 0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Chips
              Container(
                padding: const EdgeInsets.all(AppTheme.md),
                child: Row(
                  children: [
                    _buildFilterChip('الكل'),
                    const SizedBox(width: AppTheme.sm),
                    _buildFilterChip('نشطة'),
                    const SizedBox(width: AppTheme.sm),
                    _buildFilterChip('متوقفة'),
                  ],
                ),
              ),

              // Stats
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.md),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'الإجمالي',
                        _clients.length.toString(),
                        Icons.people,
                        AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    Expanded(
                      child: _buildStatCard(
                        'نشطة',
                        _clients.where((c) => c['status'] == 'نشطة').length.toString(),
                        Icons.check_circle,
                        AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.md),

              // Clients List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredClients.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 50,
                                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: AppTheme.sm),
                                const Text(
                                  'لا توجد نتائج',
                                  style: TextStyle(
                                    fontSize: AppTheme.fontMd,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppTheme.md),
                            itemCount: _filteredClients.length,
                            itemBuilder: (context, index) {
                              final client = _filteredClients[index];
                              return _buildClientCard(client, index);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _filterCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.md,
          vertical: AppTheme.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppTheme.fontSm,
            fontWeight: AppTheme.fontMedium,
            color: isSelected ? AppTheme.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.sm),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: AppTheme.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: AppTheme.fontLg,
                  fontWeight: AppTheme.fontBold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppTheme.fontXs,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client, int index) {
    final progress = client['progress'] as int;
    final statusColor = client['status'] == 'نشطة' ? AppTheme.success : AppTheme.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.md),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showClientDetails(client),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.md),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.gradientSecondary,
                      ),
                      child: Center(
                        child: Text(
                          client['name'].toString().substring(0, 1),
                          style: const TextStyle(
                            fontSize: AppTheme.fontXl,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  client['name'],
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontLg,
                                    fontWeight: AppTheme.fontBold,
                                    color: AppTheme.white,
                                  ),
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
                                  client['status'],
                                  style: const TextStyle(
                                    color: AppTheme.white,
                                    fontSize: AppTheme.fontXs,
                                    fontWeight: AppTheme.fontBold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            client['goal'],
                            style: const TextStyle(
                              fontSize: AppTheme.fontSm,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.fitness_center,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${client['sessionsCompleted']}/${client['totalSessions']} جلسة',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontXs,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: AppTheme.md),
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                client['joinDate'],
                                style: const TextStyle(
                                  fontSize: AppTheme.fontXs,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.md),
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'التقدم',
                          style: TextStyle(
                            fontSize: AppTheme.fontXs,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '$progress%',
                          style: const TextStyle(
                            fontSize: AppTheme.fontXs,
                            fontWeight: AppTheme.fontBold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 6,
                        backgroundColor: AppTheme.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms);
  }

  void _showClientDetails(Map<String, dynamic> client) {
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
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppTheme.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      client['name'],
                      style: const TextStyle(
                        fontSize: AppTheme.fontXl,
                        fontWeight: AppTheme.fontBold,
                        color: AppTheme.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppTheme.white),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.lg),

                // Details
                _buildDetailRow(Icons.cake, 'العمر', '${client['age']} سنة'),
                _buildDetailRow(Icons.phone, 'الجوال', client['phone']),
                _buildDetailRow(Icons.email, 'البريد', client['email']),
                _buildDetailRow(Icons.flag, 'الهدف', client['goal']),
                _buildDetailRow(Icons.fitness_center, 'الجلسات', '${client['sessionsCompleted']}/${client['totalSessions']}'),
                _buildDetailRow(Icons.trending_down, 'الوزن الحالي', '${client['weight']} كجم'),
                _buildDetailRow(Icons.flag_outlined, 'الوزن المستهدف', '${client['targetWeight']} كجم'),
                _buildDetailRow(Icons.calendar_today, 'تاريخ الانضمام', client['joinDate']),
                _buildDetailRow(Icons.percent, 'نسبة التقدم', '${client['progress']}%'),

                const SizedBox(height: AppTheme.xl),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          // فتح المحادثة مع المتدربة
                          final traineeId = client['id']?.toString() ?? '';
                          final profile = await ApiService.getProfile();
                          final trainerId = profile['id']?.toString() ?? profile['_id']?.toString() ?? '';

                          // إنشاء أو الحصول على المحادثة
                          final conversation = await ChatService.createConversation(
                            trainerId: trainerId,
                            traineeId: traineeId,
                          );

                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  conversationId: conversation['id'] ?? '${trainerId}_$traineeId',
                                  otherUserName: client['name'] ?? 'متدربة',
                                  currentUserId: trainerId,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          padding: const EdgeInsets.all(AppTheme.md),
                        ),
                        icon: const Icon(Icons.chat),
                        label: const Text('محادثة'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يمكنك تعديل البيانات من لوحة التحكم'),
                              backgroundColor: AppTheme.info,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.all(AppTheme.md),
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text('تعديل'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يمكنك عرض التقارير من قسم التقارير'),
                              backgroundColor: AppTheme.info,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                          padding: const EdgeInsets.all(AppTheme.md),
                        ),
                        icon: const Icon(Icons.assessment),
                        label: const Text('التقرير'),
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
}
