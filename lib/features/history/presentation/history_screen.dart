import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/entities/health_record.dart';
import 'providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(healthRecordsProvider);
    final isDark = context.isDark;
    final top = MediaQuery.of(context).padding.top;
    final grouped = _groupByDate(records);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: records.isEmpty
          ? _EmptyState(isDark: isDark, top: top)
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.fromLTRB(24, top + 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Health Journal',
                          style:
                              AppTextStyles.headlineLarge(dark: isDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${records.length} record${records.length == 1 ? '' : 's'}',
                          style:
                              AppTextStyles.bodyMedium(dark: isDark),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                for (final entry in grouped.entries) ...[
                  SliverToBoxAdapter(
                    child: _DateDivider(
                      label: entry.key,
                      isDark: isDark,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _RecordCard(
                        record: entry.value[i],
                        isDark: isDark,
                        onTap: () =>
                            context.push('/history/${entry.value[i].id}'),
                      ),
                      childCount: entry.value.length,
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100 +
                        MediaQuery.of(context).padding.bottom,
                  ),
                ),
              ],
            ),
    );
  }
}

// ─── Date grouping ────────────────────────────────────────────

Map<String, List<HealthRecord>> _groupByDate(List<HealthRecord> records) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final result = <String, List<HealthRecord>>{};

  for (final r in records) {
    final d = DateTime(r.date.year, r.date.month, r.date.day);
    final String key;
    if (d == today) {
      key = 'Today';
    } else if (d == yesterday) {
      key = 'Yesterday';
    } else {
      final diff = today.difference(d).inDays;
      key = diff < 7
          ? '$diff days ago'
          : DateFormat('d MMM y').format(r.date);
    }
    result.putIfAbsent(key, () => []).add(r);
  }
  return result;
}

// ─── Widgets ──────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              color: context.dividerColor,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.isDark,
    required this.onTap,
  });
  final HealthRecord record;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final risk = record.riskLevel;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Timeline dot
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: risk.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: risk.color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.symptoms.take(3).join(', '),
                          style: AppTextStyles.titleSmall(dark: isDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RiskBadge(level: risk),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(record.date),
                    style: AppTextStyles.bodySmall(dark: isDark),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: context.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('d MMM, h:mm a').format(date);
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.level});
  final RiskLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: level.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: level.color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark, required this.top});
  final bool isDark;
  final double top;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: top + 20),
              child: Text(
                'Health Journal',
                style: AppTextStyles.headlineLarge(dark: isDark),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        size: 52,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No records yet',
                      style: AppTextStyles.headlineSmall(dark: isDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your health analysis history\nwill appear here.',
                      style: AppTextStyles.bodyMedium(dark: isDark),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
