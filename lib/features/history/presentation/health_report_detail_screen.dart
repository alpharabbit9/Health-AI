import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/entities/health_record.dart';
import 'providers/history_provider.dart';

class HealthReportDetailScreen extends ConsumerWidget {
  const HealthReportDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(healthRecordsProvider);
    final record = records.cast<HealthRecord?>().firstWhere(
          (r) => r?.id == id,
          orElse: () => null,
        );

    if (record == null) {
      return Scaffold(
        backgroundColor: context.bgColor,
        body: const Center(child: Text('Record not found')),
      );
    }

    final isDark = context.isDark;
    final risk = record.riskLevel;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── App bar ───────────────────────────────────
          SliverAppBar(
            backgroundColor: context.bgColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            floating: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: context.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Health Report',
              style: AppTextStyles.titleLarge(dark: isDark),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share_outlined,
                    color: context.textSecondary),
                onPressed: () => context.showInfoSnack(
                    'PDF export coming in Part 2'),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Date ────────────────────────────────
                  Text(
                    DateFormat('EEEE, d MMMM y — h:mm a')
                        .format(record.date),
                    style: AppTextStyles.bodySmall(dark: isDark),
                  ),
                  const SizedBox(height: 20),

                  // ─── Risk banner ─────────────────────────
                  _RiskBanner(risk: risk),
                  const SizedBox(height: 24),

                  // ─── Symptoms ────────────────────────────
                  _Section(
                    icon: Icons.sick_outlined,
                    title: 'Reported Symptoms',
                    isDark: isDark,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: record.symptoms
                          .map((s) => _Chip(label: s, isDark: isDark))
                          .toList(),
                    ),
                  ),

                  // ─── Possible conditions ─────────────────
                  if (record.possibleConditions != null) ...[
                    const SizedBox(height: 20),
                    _Section(
                      icon: Icons.psychology_outlined,
                      title: 'Possible Conditions',
                      isDark: isDark,
                      child: _bullet(
                        record.possibleConditions!,
                        isDark,
                        context,
                      ),
                    ),
                  ],

                  // ─── AI Recommendations ───────────────────
                  if (record.aiRecommendations != null) ...[
                    const SizedBox(height: 20),
                    _Section(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'AI Recommendations',
                      isDark: isDark,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          record.aiRecommendations!,
                          style: AppTextStyles.bodyMedium(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ─── Disclaimer ────────────────────────────
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardSecondaryDark
                          : AppColors.cardSecondaryLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: context.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This report is for informational purposes only '
                            'and does not constitute medical advice. '
                            'Always consult a qualified healthcare professional.',
                            style: AppTextStyles.bodySmall(dark: isDark),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ─── Export / Share buttons ───────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.showInfoSnack(
                              'PDF export coming in Part 2'),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Export PDF'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => context
                              .showInfoSnack('Share coming in Part 2'),
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('Share'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 40 + MediaQuery.of(context).padding.bottom,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text, bool isDark, BuildContext context) {
    final items = text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.bodyMedium(dark: isDark),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────

class _RiskBanner extends StatelessWidget {
  const _RiskBanner({required this.risk});
  final RiskLevel risk;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: risk.bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: risk.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(risk.icon, color: risk.color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Risk Assessment',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: risk.color.withValues(alpha: 0.8),
                ),
              ),
              Text(
                risk.label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: risk.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.child,
  });

  final IconData icon;
  final String title;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.titleLarge(dark: isDark)),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Text(label, style: AppTextStyles.labelMedium(dark: isDark)),
    );
  }
}
