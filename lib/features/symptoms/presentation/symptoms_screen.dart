import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../history/domain/entities/health_record.dart';
import '../../history/presentation/providers/history_provider.dart';
import 'providers/symptom_provider.dart';

class SymptomsScreen extends ConsumerWidget {
  const SymptomsScreen({super.key});

  void _launchChecker(BuildContext context, WidgetRef ref) {
    // Reset both providers BEFORE pushing the route so initState reads clean state.
    // Calling mutations here (in a tap handler) is safe; calling them inside
    // initState of the destination screen triggers a Riverpod assertion crash.
    ref.read(analysisProvider.notifier).reset();
    ref.read(checkerFormProvider.notifier).resetForNewCheck();
    context.push(AppRoutes.symptomsChecker);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final records = ref.watch(healthRecordsProvider);
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, top + 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Symptom Checker',
                      style: AppTextStyles.headlineLarge(dark: isDark)),
                  const SizedBox(height: 4),
                  Text('AI-powered health analysis',
                      style: AppTextStyles.bodyMedium(dark: isDark)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Hero CTA card ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _HeroCTACard(
                onTap: () => _launchChecker(context, ref),
              ),
            ),
          ),

          // ── Stats row (when history exists) ─────────────
          if (records.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: _StatsRow(records: records, isDark: isDark),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text('Recent Analyses',
                    style: AppTextStyles.titleLarge(dark: isDark)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: _RecentCard(
                    record: records.take(3).toList()[i],
                    isDark: isDark,
                  ),
                ),
                childCount: records.take(3).length,
              ),
            ),
          ] else ...[
            // ── Feature highlights ───────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Text("What you'll get",
                    style: AppTextStyles.titleLarge(dark: isDark)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: _FeatureTile(
                    icon: _kFeatures[i].$1,
                    title: _kFeatures[i].$2,
                    subtitle: _kFeatures[i].$3,
                    isDark: isDark,
                  ),
                ),
                childCount: _kFeatures.length,
              ),
            ),
          ],

          SliverToBoxAdapter(
            child: SizedBox(height: 100 + bottom),
          ),
        ],
      ),
    );
  }
}

// ─── Hero CTA card ────────────────────────────────────────────

class _HeroCTACard extends StatelessWidget {
  const _HeroCTACard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.medical_services_rounded,
                      size: 26, color: Colors.white),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          size: 12, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        'Groq AI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Start AI Analysis',
              style: AppTextStyles.headlineMedium(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Describe your symptoms and receive instant\nAI-powered health insights.',
              style: AppTextStyles.bodyMedium(
                  color: Colors.white.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: 20),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Begin Check',
                    style:
                        AppTextStyles.labelMedium(color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.records, required this.isDark});
  final List<HealthRecord> records;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final low = records.where((r) => r.riskLevel == RiskLevel.low).length;
    final high = records.where((r) => r.riskLevel == RiskLevel.high).length;

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: 'Total',
            value: '${records.length}',
            color: AppColors.primary,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            label: 'Low Risk',
            value: '$low',
            color: AppColors.success,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            label: 'High Risk',
            value: '$high',
            color: AppColors.danger,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTextStyles.bodySmall(dark: isDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Recent record card ───────────────────────────────────────

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.record, required this.isDark});
  final HealthRecord record;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final risk = record.riskLevel;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: risk.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: risk.color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.symptoms.take(3).join(', '),
                  style: AppTextStyles.titleSmall(dark: isDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _fmt(record.date),
                  style: AppTextStyles.bodySmall(dark: isDark),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: risk.bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              risk.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: risk.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('d MMM, h:mm a').format(d);
  }
}

// ─── Feature tile ─────────────────────────────────────────────

const _kFeatures = [
  (
    Icons.psychology_rounded,
    'AI Risk Assessment',
    'Get Low / Moderate / High risk rating instantly'
  ),
  (
    Icons.medical_information_outlined,
    'Possible Conditions',
    'AI suggests what might be causing your symptoms'
  ),
  (
    Icons.lightbulb_outline_rounded,
    'Smart Recommendations',
    'Personalised self-care and medical advice'
  ),
  (
    Icons.warning_amber_rounded,
    'Emergency Warnings',
    'Know when to seek immediate medical attention'
  ),
];

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.titleSmall(dark: isDark)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.bodySmall(dark: isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
