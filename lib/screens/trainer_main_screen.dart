import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'trainer_home_screen.dart';
import 'trainer_clients_screen.dart';
import 'trainer_schedule_screen.dart';
import 'trainer_reports_screen.dart';
import 'more_screen.dart';

class TrainerMainScreen extends StatefulWidget {
  const TrainerMainScreen({super.key});

  @override
  State<TrainerMainScreen> createState() => _TrainerMainScreenState();
}

class _TrainerMainScreenState extends State<TrainerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TrainerHomeScreen(),
    TrainerClientsScreen(),
    TrainerScheduleScreen(),
    TrainerReportsScreen(),
    MoreScreen(),
  ];

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      icon: Icons.person,
      label: 'صفحتي',
    ),
    NavigationItem(
      icon: Icons.people,
      label: 'المتدربات',
    ),
    NavigationItem(
      icon: Icons.calendar_today,
      label: 'البرنامج',
    ),
    NavigationItem(
      icon: Icons.bar_chart,
      label: 'التقارير',
    ),
    NavigationItem(
      icon: Icons.menu,
      label: 'المزيد',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: const Border(
              top: BorderSide(
                color: AppTheme.border,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF69B4).withValues(alpha: 0.1),
                offset: const Offset(0, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  _navigationItems.length,
                  (index) => _buildNavItem(
                    _navigationItems[index],
                    index,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavigationItem item, int index) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 24,
                color: isSelected ? const Color(0xFFFF69B4) : AppTheme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected
                      ? AppTheme.fontMedium
                      : AppTheme.fontRegular,
                  color: isSelected ? const Color(0xFFFF69B4) : AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 32,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF69B4) : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  const NavigationItem({
    required this.icon,
    required this.label,
  });
}

