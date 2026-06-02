import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../shared/widgets/health_ai_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = context.isDark;
    final firstName = user?.fullName?.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: _buildAppBar(context, ref, isDark),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                _buildGreeting(firstName, isDark),
                const SizedBox(height: 24),
                _buildFeatureGrid(context, isDark),
                const SizedBox(height: 24),
                _buildQuickStats(isDark),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, bool isDark) {
    return AppBar(
      backgroundColor: context.bgColor,
      elevation: 0,
      leadingWidth: 160,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: Center(child: HealthAILogoChip(height: 30)),
      ),
      actions: [
        // Notification bell
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Icon(
            Icons.notifications_outlined,
            size: 20,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        // Profile avatar
        GestureDetector(
          onTap: () => _showSignOutDialog(context, ref),
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: AppColors.primaryGradient),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(String name, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '👋 Hello, $name!',
          style: AppTextStyles.headlineLarge(dark: isDark),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15, end: 0),
        const SizedBox(height: 4),
        Text(
          'How are you feeling today?',
          style: AppTextStyles.bodyMedium(dark: isDark),
        ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context, bool isDark) {
    final features = [
      _FeatureItem(
        icon: Icons.psychology_rounded,
        title: 'AI Analysis',
        subtitle: 'Analyze symptoms',
        color: AppColors.primary,
        bgColor: AppColors.primaryLight,
        comingSoon: false,
      ),
      _FeatureItem(
        icon: Icons.local_hospital_rounded,
        title: 'Find Doctors',
        subtitle: 'Nearby specialists',
        color: AppColors.illustrationBlue,
        bgColor: AppColors.infoLight,
        comingSoon: true,
      ),
      _FeatureItem(
        icon: Icons.timeline_rounded,
        title: 'Health History',
        subtitle: 'Track your health',
        color: AppColors.warning,
        bgColor: AppColors.warningLight,
        comingSoon: true,
      ),
      _FeatureItem(
        icon: Icons.recommend_rounded,
        title: 'Recommendations',
        subtitle: 'Personalized tips',
        color: AppColors.illustrationPurple,
        bgColor: const Color(0xFFF5F3FF),
        comingSoon: true,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemCount: features.length,
      itemBuilder: (context, i) => _FeatureCard(
        item: features[i],
        isDark: isDark,
      )
          .animate(delay: (i * 80).ms)
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.92, 0.92), duration: 400.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildQuickStats(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today\'s Health Score', style: AppTextStyles.titleLarge(dark: isDark))
            .animate(delay: 300.ms)
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '86/100',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Good health today! Keep it up.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 0.86,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        )
            .animate(delay: 350.ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            ctx.isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Sign Out',
            style: AppTextStyles.headlineSmall(dark: ctx.isDark)),
        content: Text('Are you sure you want to sign out?',
            style: AppTextStyles.bodyMedium(dark: ctx.isDark)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.labelLarge(
                    color: ctx.isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: Text('Sign Out',
                style: AppTextStyles.labelLarge(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final bool comingSoon;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.comingSoon,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  final bool isDark;

  const _FeatureCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.comingSoon
          ? () => context.showInfoSnack('${item.title} — Coming in Part 2!')
          : null,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(isDark ? 0.06 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? item.color.withOpacity(0.18) : item.bgColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(item.icon, color: item.color, size: 24),
            ),
            const Spacer(),
            // Title
            Text(
              item.title,
              style: AppTextStyles.titleLarge(dark: isDark),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            // Subtitle / Coming soon badge
            if (item.comingSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: item.color,
                  ),
                ),
              )
            else
              Text(
                item.subtitle,
                style: AppTextStyles.bodySmall(dark: isDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
