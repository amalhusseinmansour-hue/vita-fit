import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';

class TrainerPendingScreen extends StatelessWidget {
  final String trainerName;
  final String trainerEmail;

  const TrainerPendingScreen({
    super.key,
    required this.trainerName,
    required this.trainerEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.background,
              AppTheme.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success icon with animation
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.success.withValues(alpha: 0.3),
                          AppTheme.success.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.success.withValues(alpha: 0.5),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.success.withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.hourglass_top_rounded,
                        size: 50,
                        color: AppTheme.success,
                      ),
                    ),
                  )
                      .animate(
                        onPlay: (controller) => controller.repeat(reverse: true),
                      )
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.05, 1.05),
                        duration: 1500.ms,
                      ),

                  const SizedBox(height: AppTheme.xl),

                  // Title
                  const Text(
                    'تم استلام طلبك',
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: AppTheme.lg),

                  // Greeting
                  Text(
                    'مرحباً $trainerName',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: AppTheme.fontXl,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms),

                  const SizedBox(height: AppTheme.xl),

                  // Main message card
                  Container(
                    padding: const EdgeInsets.all(AppTheme.lg),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 40,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(height: AppTheme.md),
                        const Text(
                          'نحن نراجع معلوماتك وسيتم قبولك فور المراجعة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: AppTheme.fontLg,
                            fontWeight: FontWeight.w500,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),

                  const SizedBox(height: AppTheme.lg),

                  // Email info card
                  Container(
                    padding: const EdgeInsets.all(AppTheme.md),
                    decoration: BoxDecoration(
                      color: AppTheme.card.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: AppTheme.border.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.sm),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            color: AppTheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppTheme.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'سنرسل إشعاراً إلى بريدك الإلكتروني',
                                style: TextStyle(
                                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                                  fontSize: AppTheme.fontSm,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                trainerEmail,
                                style: const TextStyle(
                                  color: AppTheme.white,
                                  fontSize: AppTheme.fontMd,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms),

                  const SizedBox(height: AppTheme.md),

                  // Time estimate
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.lg,
                      vertical: AppTheme.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: AppTheme.info.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: AppTheme.info,
                          size: 20,
                        ),
                        SizedBox(width: AppTheme.sm),
                        Text(
                          'عادة ما تتم المراجعة خلال 24 ساعة',
                          style: TextStyle(
                            color: AppTheme.info,
                            fontSize: AppTheme.fontSm,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 700.ms, duration: 600.ms),

                  const SizedBox(height: AppTheme.xl * 2),

                  // Back to login button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppTheme.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: AppTheme.md + 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back, size: 20),
                            SizedBox(width: AppTheme.sm),
                            Text(
                              'العودة لتسجيل الدخول',
                              style: TextStyle(
                                fontSize: AppTheme.fontLg,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
