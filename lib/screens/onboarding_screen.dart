import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'خطة تدريب تناسبك',
      description: 'برنامج تدريبي مصمم خصيصاً لك بناءً على أهدافك ومستواك',
      icon: Icons.fitness_center,
      color: const Color(0xFFFF69B4),
    ),
    OnboardingData(
      title: 'جدول غذائي واضح وسهل',
      description: 'نظام غذائي متكامل يساعدك على تحقيق أهدافك الصحية',
      icon: Icons.restaurant_menu,
      color: const Color(0xFFFF1493),
    ),
    OnboardingData(
      title: 'تتبع تقدمك',
      description: 'راقبي تطورك يوماً بيوم مع إحصائيات دقيقة ومحفزة',
      icon: Icons.trending_up,
      color: const Color(0xFFFF87C7),
    ),
    OnboardingData(
      title: 'دعم من المدربات',
      description: 'مدربات متخصصات جاهزات لمساعدتك في كل خطوة',
      icon: Icons.support_agent,
      color: const Color(0xFFDDA0DD),
    ),
    OnboardingData(
      title: 'متجر كامل للنساء',
      description: 'كل ما تحتاجينه من ملابس ومعدات ومكملات رياضية',
      icon: Icons.shopping_bag,
      color: const Color(0xFFFFB6C1),
    ),
    OnboardingData(
      title: 'مجتمع نسائي خاص',
      description: 'انضمي لمجتمع من النساء الملهمات وشاركي تجربتك',
      icon: Icons.groups,
      color: const Color(0xFFFF69B4),
    ),
    OnboardingData(
      title: 'صفحة مخصصة لك',
      description: 'كل شيء مصمم خصيصاً لك لتحقيق أفضل النتائج',
      icon: Icons.person,
      color: const Color(0xFFFF1493),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A0E2E),
                const Color(0xFF2D1B3D),
                _pages[_currentPage].color.withOpacity(0.2),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: _navigateToLogin,
                      child: const Text(
                        'تخطي',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index], index);
                    },
                  ),
                ),

                // Indicators
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[_currentPage].color
                              : AppTheme.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Next/Start button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 8,
                        shadowColor: _pages[_currentPage].color.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'ابدئي الآن'
                                : 'التالي',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == _pages.length - 1
                                ? Icons.check
                                : Icons.arrow_back,
                            size: 22,
                          ),
                        ],
                      ),
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

  Widget _buildPage(OnboardingData data, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glow effect
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  data.color.withOpacity(0.3),
                  data.color.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: data.color.withOpacity(0.4),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    data.color,
                    data.color.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: data.color.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                data.icon,
                size: 60,
                color: AppTheme.white,
              ),
            ),
          )
              .animate(key: ValueKey(index))
              .fadeIn(duration: 600.ms)
              .scale(
                begin: const Offset(0.5, 0.5),
                duration: 600.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: 48),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
              letterSpacing: 0.5,
            ),
          )
              .animate(key: ValueKey('title_$index'))
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.3, duration: 500.ms),

          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.white.withOpacity(0.8),
              height: 1.6,
            ),
          )
              .animate(key: ValueKey('desc_$index'))
              .fadeIn(delay: 400.ms, duration: 500.ms)
              .slideY(begin: 0.3, duration: 500.ms),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
