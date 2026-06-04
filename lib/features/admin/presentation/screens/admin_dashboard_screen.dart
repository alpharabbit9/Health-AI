import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_stat_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(adminStatsProvider);
    final user = ref.watch(currentUserProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(adminStatsProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // ─── Welcome header ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: AppTextStyles.bodyMedium(dark: isDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.fullName?.split(' ').first ?? 'Admin',
                    style: AppTextStyles.displaySmall(dark: isDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Here\'s what\'s happening in HealthAI today.',
                    style: AppTextStyles.bodyMedium(dark: isDark),
                  ),
                  const SizedBox(height: 28),
                ],
              ).animate().fadeIn(duration: 500.ms).slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic),
            ),
          ),

          // ─── Stats grid ──────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: statsAsync.when(
              loading: () => SliverToBoxAdapter(
                child: _StatsLoadingSkeleton(isDark: isDark),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: _ErrorCard(
                  message: e.toString(),
                  onRetry: () =>
                      ref.read(adminStatsProvider.notifier).refresh(),
                  isDark: isDark,
                ),
              ),
              data: (stats) => SliverGrid(
                delegate: SliverChildListDelegate([
                  AdminStatCard(
                    title: 'Total Users',
                    value: stats.totalUsers.toString(),
                    icon: Icons.people_rounded,
                    color: AppColors.info,
                    trend: '+${stats.newUsersThisWeek} this week',
                    trendPositive: true,
                  ).animate(delay: 50.ms).fadeIn(duration: 400.ms).slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic),
                  AdminStatCard(
                    title: 'Total Analyses',
                    value: stats.totalAnalyses.toString(),
                    icon: Icons.analytics_rounded,
                    color: AppColors.primary,
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic),
                  AdminStatCard(
                    title: 'Doctors',
                    value: stats.totalDoctors.toString(),
                    icon: Icons.medical_services_rounded,
                    color: AppColors.warning,
                  ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic),
                  AdminStatCard(
                    title: 'Health Tips',
                    value: stats.totalHealthTips.toString(),
                    icon: Icons.lightbulb_rounded,
                    color: AppColors.success,
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic),
                ]),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.92,
                ),
              ),
            ),
          ),

          // ─── Risk breakdown ───────────────────────────
          SliverToBoxAdapter(
            child: statsAsync.maybeWhen(
              data: (stats) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Level Breakdown',
                      style: AppTextStyles.headlineSmall(dark: isDark),
                    ),
                    const SizedBox(height: 14),
                    _RiskBreakdownCard(
                      low: stats.lowRiskCount,
                      moderate: stats.moderateRiskCount,
                      high: stats.highRiskCount,
                      isDark: isDark,
                    ),
                  ],
                ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ),

          // ─── Quick links ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: AppTextStyles.headlineSmall(dark: isDark),
                  ),
                  const SizedBox(height: 14),
                  _QuickActionsRow(isDark: isDark),
                ],
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Risk Breakdown Card ─────────────────────────────────────

class _RiskBreakdownCard extends StatelessWidget {
  const _RiskBreakdownCard({
    required this.low,
    required this.moderate,
    required this.high,
    required this.isDark,
  });

  final int low, moderate, high;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final total = (low + moderate + high).clamp(1, 999999);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _RiskTile(
                label: 'Low Risk',
                count: low,
                color: AppColors.success,
                isDark: isDark,
              ),
              _RiskTile(
                label: 'Moderate',
                count: moderate,
                color: AppColors.warning,
                isDark: isDark,
              ),
              _RiskTile(
                label: 'High Risk',
                count: high,
                color: AppColors.danger,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                _BarSegment(
                    flex: low, color: AppColors.success, total: total),
                _BarSegment(
                    flex: moderate, color: AppColors.warning, total: total),
                _BarSegment(
                    flex: high, color: AppColors.danger, total: total),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({
    required this.label,
    required this.count,
    required this.color,
    required this.isDark,
  });
  final String label;
  final int count;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: AppTextStyles.headlineMedium(dark: isDark),
          ),
          Text(label, style: AppTextStyles.bodySmall(dark: isDark)),
        ],
      ),
    );
  }
}

class _BarSegment extends StatelessWidget {
  const _BarSegment({
    required this.flex,
    required this.color,
    required this.total,
  });
  final int flex;
  final Color color;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex == 0 ? 0 : (flex * 100 ~/ total).clamp(1, 100),
      child: Container(height: 10, color: color),
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.person_add_rounded,
          label: 'Users',
          color: AppColors.info,
          onTap: () => context.go(AppRoutes.adminUsers),
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _QuickAction(
          icon: Icons.add_circle_outline_rounded,
          label: 'Add Doctor',
          color: AppColors.warning,
          onTap: () => context.go(AppRoutes.adminDoctors),
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _QuickAction(
          icon: Icons.lightbulb_outline_rounded,
          label: 'Add Tip',
          color: AppColors.success,
          onTap: () => context.go(AppRoutes.adminHealthTips),
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _QuickAction(
          icon: Icons.feedback_outlined,
          label: 'Feedback',
          color: AppColors.primary,
          onTap: () => context.go(AppRoutes.adminFeedback),
          isDark: isDark,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelSmall(dark: isDark),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Loading skeleton ────────────────────────────────────────

class _StatsLoadingSkeleton extends StatelessWidget {
  const _StatsLoadingSkeleton({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final shimmer = isDark ? AppColors.cardSecondaryDark : AppColors.cardSecondaryLight;
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.92,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(
        4,
        (_) => Container(
          decoration: BoxDecoration(
            color: shimmer,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

// ─── Error card ───────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard(
      {required this.message, required this.onRetry, required this.isDark});
  final String message;
  final VoidCallback onRetry;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 32),
          const SizedBox(height: 8),
          Text(
            'Failed to load stats',
            style: AppTextStyles.titleSmall(color: AppColors.danger),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
