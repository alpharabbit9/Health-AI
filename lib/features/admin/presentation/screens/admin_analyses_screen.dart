import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/admin_provider.dart';

class AdminAnalysesScreen extends ConsumerWidget {
  const AdminAnalysesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(adminAnalysesFilterProvider);
    final analysesAsync = ref.watch(adminAnalysesProvider);

    return Column(
      children: [
        // ─── Filter chips ──────────────────────────────
        _FilterBar(selected: filter, isDark: isDark, onSelect: (v) {
          ref.read(adminAnalysesProvider.notifier).setFilter(v);
        }),

        // ─── List ──────────────────────────────────────
        Expanded(
          child: analysesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: AppColors.danger),
                  const SizedBox(height: 12),
                  Text('Failed to load analyses',
                      style: AppTextStyles.titleMedium(dark: isDark)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => ref.invalidate(adminAnalysesProvider),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (analyses) {
              // Risk summary
              int low = 0, moderate = 0, high = 0;
              for (final a in analyses) {
                final level =
                    (a['risk_level'] as String? ?? '').toLowerCase();
                if (level.contains('low')) {
                  low++;
                } else if (level.contains('moderate') ||
                    level.contains('medium')) {
                  moderate++;
                } else if (level.contains('high')) {
                  high++;
                }
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => ref.invalidate(adminAnalysesProvider),
                child: CustomScrollView(
                  slivers: [
                    // Summary row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: _RiskSummaryRow(
                          low: low,
                          moderate: moderate,
                          high: high,
                          total: analyses.length,
                          isDark: isDark,
                        ),
                      ),
                    ),

                    if (analyses.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics_outlined,
                                  size: 56,
                                  color: isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight),
                              const SizedBox(height: 12),
                              Text('No analyses for this period',
                                  style: AppTextStyles.titleMedium(
                                      dark: isDark)),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _AnalysisCard(
                                data: analyses[i],
                                isDark: isDark,
                              )
                                  .animate(delay: (i * 30).ms)
                                  .fadeIn(duration: 300.ms),
                            ),
                            childCount: analyses.length,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Filter Bar ───────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });
  final String? selected;
  final bool isDark;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final filters = [
      (null, 'All'),
      ('today', 'Today'),
      ('week', 'This Week'),
      ('month', 'This Month'),
    ];

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: filters
            .map((f) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: f.$2,
                    selected: selected == f.$1,
                    isDark: isDark,
                    onTap: () => onSelect(f.$1),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(
            color: selected
                ? Colors.white
                : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}

// ─── Risk Summary Row ─────────────────────────────────────────

class _RiskSummaryRow extends StatelessWidget {
  const _RiskSummaryRow({
    required this.low,
    required this.moderate,
    required this.high,
    required this.total,
    required this.isDark,
  });
  final int low, moderate, high, total;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryChip(
            label: 'Total', value: total, color: AppColors.info, isDark: isDark),
        const SizedBox(width: 8),
        _SummaryChip(
            label: 'Low', value: low, color: AppColors.success, isDark: isDark),
        const SizedBox(width: 8),
        _SummaryChip(
            label: 'Moderate',
            value: moderate,
            color: AppColors.warning,
            isDark: isDark),
        const SizedBox(width: 8),
        _SummaryChip(
            label: 'High', value: high, color: AppColors.danger, isDark: isDark),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });
  final String label;
  final int value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: AppTextStyles.headlineMedium(color: color),
            ),
            Text(label,
                style: AppTextStyles.labelSmall(color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── Analysis Card ────────────────────────────────────────────

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.data, required this.isDark});
  final Map<String, dynamic> data;
  final bool isDark;

  Color _riskColor(String level) {
    final l = level.toLowerCase();
    if (l.contains('high')) return AppColors.danger;
    if (l.contains('moderate') || l.contains('medium')) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final riskLevel = data['risk_level'] as String? ?? 'Unknown';
    final riskColor = _riskColor(riskLevel);
    final createdAt = DateTime.tryParse(data['created_at'] as String? ?? '');
    final user = data['users'] as Map<String, dynamic>?;
    final userName = user?['full_name'] as String? ??
        user?['email'] as String? ??
        'Unknown user';

    final symptoms = (data['symptoms'] as List<dynamic>?)
            ?.map((s) => s.toString())
            .take(3)
            .join(', ') ??
        'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  userName,
                  style: AppTextStyles.titleSmall(dark: isDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  riskLevel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: riskColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.medical_services_outlined,
                  size: 14,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  symptoms,
                  style: AppTextStyles.bodySmall(dark: isDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (createdAt != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 13,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(createdAt),
                  style: AppTextStyles.bodySmall(dark: isDark),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
