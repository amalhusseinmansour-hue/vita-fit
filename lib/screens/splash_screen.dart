import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import '../services/api_service.dart';
import '../services/app_tracking_service.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late AnimationController _rotationController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // Animation controllers
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _navigateToHome();
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));

    // Request App Tracking Transparency permission (iOS 14+)
    if (Platform.isIOS) {
      await AppTrackingService.requestTrackingPermission();
    }

    if (mounted) {
      // Check if user is already logged in
      final isLoggedIn = await ApiService.isLoggedIn();

      if (isLoggedIn) {
        // User is logged in, go directly to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Check if user has seen onboarding
        final prefs = await SharedPreferences.getInstance();
        final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

        if (hasSeenOnboarding) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          await prefs.setBool('hasSeenOnboarding', true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A0E2E),
              const Color(0xFF2D1B3D),
              const Color(0xFF3D2857),
              AppTheme.primary.withOpacity(0.2),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(30, (index) {
              return AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  final double angle = _rotationController.value * 2 * 3.14159;
                  final double radius = 100 + (index * 15.0);
                  final double x = MediaQuery.of(context).size.width / 2 +
                      radius * (index % 2 == 0 ? 1 : -1) *
                      (index % 3 == 0 ? math.cos(angle + index) : math.sin(angle + index));
                  final double y = MediaQuery.of(context).size.height / 2 +
                      radius * (index % 2 == 0 ? math.sin(angle + index) : math.cos(angle + index));

                  return Positioned(
                    left: x,
                    top: y,
                    child: Container(
                      width: 4 + (index % 3) * 2,
                      height: 4 + (index % 3) * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: [
                          AppTheme.primary,
                          AppTheme.secondary,
                          AppTheme.accent,
                        ][index % 3]
                            .withOpacity(0.3 + (_glowController.value * 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: [
                              AppTheme.primary,
                              AppTheme.secondary,
                              AppTheme.accent,
                            ][index % 3]
                                .withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),

            // Glass morphism overlay
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo container with glass effect
                  AnimatedBuilder(
                    animation: _heartbeatController,
                    builder: (context, child) {
                      final scale = 1.0 + (_heartbeatController.value * 0.1);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.primary.withOpacity(0.3),
                                AppTheme.primaryDark.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary
                                    .withOpacity(0.5 + (_glowController.value * 0.3)),
                                blurRadius: 40 + (_glowController.value * 20),
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(90),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.primary.withOpacity(0.2),
                                      AppTheme.secondary.withOpacity(0.1),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppTheme.primary.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.favorite,
                                    size: 90,
                                    color: AppTheme.primary,
                                  )
                                      .animate(onPlay: (controller) => controller.repeat())
                                      .shimmer(
                                        duration: 2000.ms,
                                        color: AppTheme.white.withOpacity(0.5),
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(
                        begin: const Offset(0.3, 0.3),
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 40),

                  // App name with beautiful animation
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppTheme.primary,
                        AppTheme.secondary,
                        AppTheme.accent,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'VitaFit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        fontFamily: 'NotoKufiArabic',
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(
                        begin: 0.5,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .then()
                      .shimmer(
                        duration: 1500.ms,
                        color: AppTheme.white.withOpacity(0.3),
                      ),

                  const SizedBox(height: 12),

                  // Tagline with glass effect
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary.withOpacity(0.1),
                              AppTheme.secondary.withOpacity(0.1),
                            ],
                          ),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'أطلقي قوتك… وتألقّي بجمالك',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                            fontFamily: 'NotoKufiArabic',
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideX(
                        begin: -0.3,
                        duration: 600.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 60),

                  // Beautiful animated loading indicator
                  SizedBox(
                    width: 250,
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primary.withOpacity(0.2),
                                  AppTheme.secondary.withOpacity(0.2),
                                ],
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                widthFactor: 0.3,
                                alignment: Alignment(
                                  -1 + (_rotationController.value * 2),
                                  0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppTheme.primary,
                                        AppTheme.secondary,
                                        AppTheme.primary,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1200.ms, duration: 600.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 600.ms,
                      ),

                  const SizedBox(height: 24),

                  // Loading text with fade animation
                  const Text(
                    'جاري التحضير لك...',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      fontFamily: 'NotoKufiArabic',
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(delay: 1400.ms, duration: 800.ms)
                      .then(delay: 500.ms)
                      .fadeOut(duration: 800.ms)
                      .then()
                      .fadeIn(duration: 800.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
