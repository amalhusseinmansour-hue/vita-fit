import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/language_provider.dart';
import '../services/app_settings_service.dart';

/// شاشة إعدادات اللغة للمستخدم
class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isRTL = languageProvider.isRTL;

        return Directionality(
          textDirection: languageProvider.textDirection,
          child: Scaffold(
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.gradientPrimary,
                      ),
                      padding: const EdgeInsets.all(AppTheme.lg),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                              color: AppTheme.white,
                            ),
                          ),
                          const SizedBox(width: AppTheme.sm),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.language,
                              size: 28,
                              color: AppTheme.white,
                            ),
                          ),
                          const SizedBox(width: AppTheme.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isRTL ? 'اللغة' : 'Language',
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontXl,
                                    fontWeight: AppTheme.fontBold,
                                    color: AppTheme.white,
                                  ),
                                ),
                                Text(
                                  isRTL
                                      ? 'اختر لغة التطبيق'
                                      : 'Choose app language',
                                  style: const TextStyle(
                                    fontSize: AppTheme.fontSm,
                                    color: AppTheme.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 600.ms),
                  ),

                  // Language Options
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.md),
                      child: Column(
                        children: [
                          const SizedBox(height: AppTheme.md),
                          ...AppSettingsService.supportedLanguages.map((lang) {
                            final isSelected =
                                languageProvider.languageCode == lang['code'];
                            final index =
                                AppSettingsService.supportedLanguages.indexOf(lang);

                            return _buildLanguageOption(
                              context: context,
                              lang: lang,
                              isSelected: isSelected,
                              isRTL: isRTL,
                              delay: index * 100,
                              onTap: () async {
                                await languageProvider.setLanguage(lang['code']!);
                              },
                            );
                          }),
                          const SizedBox(height: AppTheme.xl),

                          // Info Card
                          Container(
                            padding: const EdgeInsets.all(AppTheme.md),
                            decoration: BoxDecoration(
                              color: AppTheme.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(
                                  color: AppTheme.info.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline,
                                    color: AppTheme.info, size: 24),
                                const SizedBox(width: AppTheme.sm),
                                Expanded(
                                  child: Text(
                                    isRTL
                                        ? 'سيتم تطبيق اللغة الجديدة فوراً على جميع شاشات التطبيق.'
                                        : 'The new language will be applied immediately to all app screens.',
                                    style: const TextStyle(
                                      fontSize: AppTheme.fontSm,
                                      color: AppTheme.info,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required Map<String, String> lang,
    required bool isSelected,
    required bool isRTL,
    required int delay,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.md),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: isSelected ? AppTheme.primary : AppTheme.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.lg),
            child: Row(
              children: [
                // Language Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.textSecondary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      lang['code']!.toUpperCase(),
                      style: TextStyle(
                        fontSize: AppTheme.fontLg,
                        fontWeight: AppTheme.fontBold,
                        color: isSelected ? AppTheme.white : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.md),

                // Language Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang['name']!,
                        style: TextStyle(
                          fontSize: AppTheme.fontLg,
                          fontWeight: AppTheme.fontBold,
                          color: isSelected ? AppTheme.primary : AppTheme.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            lang['direction'] == 'rtl'
                                ? Icons.format_textdirection_r_to_l
                                : Icons.format_textdirection_l_to_r,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lang['direction'] == 'rtl'
                                ? (isRTL ? 'من اليمين لليسار' : 'Right to Left')
                                : (isRTL ? 'من اليسار لليمين' : 'Left to Right'),
                            style: const TextStyle(
                              fontSize: AppTheme.fontSm,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Check Icon
                if (isSelected)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppTheme.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delay.ms).slideX(
          begin: isRTL ? -0.2 : 0.2,
          end: 0,
          duration: 400.ms,
          delay: delay.ms,
        );
  }
}
