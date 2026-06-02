import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../data/onboarding_data.dart';
import 'providers/onboarding_provider.dart';
import 'widgets/onboarding_illustration.dart';
import 'widgets/page_indicator_widget.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) context.go(AppRoutes.login);
  }

  Future<void> _next() async {
    final notifier = ref.read(onboardingProvider.notifier);
    final current = ref.read(onboardingProvider);

    if (current < onboardingItems.length - 1) {
      notifier.nextPage();
      _pageController.animateToPage(
        current + 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await notifier.completeOnboarding();
      if (mounted) context.go(AppRoutes.login);
    }
  }

  void _onPageChanged(int page) {
    ref.read(onboardingProvider.notifier).setPage(page);
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(onboardingProvider);
    final isDark = context.isDark;
    final isLast = currentPage == onboardingItems.length - 1;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          // ─── Page view ──────────────────────────
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: onboardingItems.length,
            itemBuilder: (_, i) => _OnboardingPage(
              item: onboardingItems[i],
              isDark: isDark,
            ),
          ),

          // ─── Top bar (skip button) ───────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo chip
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'HealthAI',
                        style: AppTextStyles.titleLarge(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondaryLight,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.labelLarge(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ).animate(key: ValueKey(currentPage)).fadeIn(duration: 300.ms),
                ],
              ),
            ),
          ),

          // ─── Bottom controls ─────────────────────
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      // Page indicator
                      PageIndicator(
                        count: onboardingItems.length,
                        current: currentPage,
                      ),
                      const SizedBox(height: 28),

                      // CTA button
                      AppButton(
                        label: isLast ? 'Get Started' : 'Continue',
                        onPressed: _next,
                        style: AppButtonStyle.primary,
                        fullWidth: true,
                        height: 56,
                        trailing: Icon(
                          isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Login prompt
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.bodySmall(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          GestureDetector(
                            onTap: _skip,
                            child: Text(
                              'Sign In',
                              style: AppTextStyles.bodySmall(
                                  color: AppColors.primary)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  final bool isDark;

  const _OnboardingPage({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── Illustration area (top 56%) ──────────
        Expanded(
          flex: 56,
          child: OnboardingIllustration(
            type: item.illustration,
            bgColors: item.gradientColors,
          ),
        ),

        // ─── Text area (bottom 44%) ───────────────
        Expanded(
          flex: 44,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.headlineLarge(
                    dark: isDark,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(
                    begin: 0.25, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 12),
                Text(
                  item.subtitle,
                  style: AppTextStyles.bodyMedium(dark: isDark),
                ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(
                    begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
