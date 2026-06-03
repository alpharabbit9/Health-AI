import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/symptom_analysis.dart';
import '../providers/symptom_provider.dart';

class AiResultScreen extends ConsumerWidget {
  const AiResultScreen({super.key, required this.analysis});
  final SymptomAnalysis analysis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final risk = analysis.riskLevel;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ────────────────────────────────────
          SliverAppBar(
            backgroundColor: context.bgColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            floating: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: context.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('AI Analysis Result',
                style: AppTextStyles.titleLarge(dark: isDark)),
            actions: [
              TextButton.icon(
                onPressed: () {
                  ref.read(checkerFormProvider.notifier).reset();
                  ref.read(analysisProvider.notifier).reset();
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst);
                  context.go(AppRoutes.history);
                },
                icon: const Icon(Icons.history_rounded, size: 16),
                label: const Text('View History'),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Risk meter ──────────────────────────
                  _RiskMeter(risk: risk, isDark: isDark),
                  const SizedBox(height: 20),

                  // ── Summary ─────────────────────────────
                  if (analysis.summary.isNotEmpty) ...[
                    _SectionTitle(
                        title: 'Summary',
                        icon: Icons.summarize_outlined,
                        isDark: isDark),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Text(
                        analysis.summary,
                        style: AppTextStyles.bodyMedium(dark: isDark),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Emergency warnings ───────────────────
                  if (analysis.emergencyWarnings.isNotEmpty) ...[
                    _EmergencyWarnings(
                        warnings: analysis.emergencyWarnings),
                    const SizedBox(height: 24),
                  ],

                  // ── Possible conditions ──────────────────
                  if (analysis.possibleConditions.isNotEmpty) ...[
                    _SectionTitle(
                        title: 'Possible Conditions',
                        icon: Icons.psychology_outlined,
                        isDark: isDark),
                    const SizedBox(height: 10),
                    ...analysis.possibleConditions.map((c) =>
                        _ConditionCard(
                            condition: c, isDark: isDark)),
                    const SizedBox(height: 24),
                  ],

                  // ── Recommendations ──────────────────────
                  if (analysis.recommendations.isNotEmpty) ...[
                    _SectionTitle(
                        title: 'Recommendations',
                        icon: Icons.lightbulb_outline_rounded,
                        isDark: isDark),
                    const SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: analysis.recommendations
                          .map((r) => _RecommendationCard(
                              rec: r, isDark: isDark))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Self-care advice ─────────────────────
                  if (analysis.selfCareAdvice.isNotEmpty) ...[
                    _SectionTitle(
                        title: 'Self-Care Advice',
                        icon: Icons.self_improvement_rounded,
                        isDark: isDark),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        analysis.selfCareAdvice,
                        style: AppTextStyles.bodyMedium(
                            color: AppColors.primaryDark),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── When to see doctor ───────────────────
                  if (analysis.whenToSeeDoctor.isNotEmpty) ...[
                    _SectionTitle(
                        title: 'When to See a Doctor',
                        icon: Icons.local_hospital_outlined,
                        isDark: isDark),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.medical_services_outlined,
                              size: 20, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              analysis.whenToSeeDoctor,
                              style:
                                  AppTextStyles.bodyMedium(dark: isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Action buttons ───────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            final specialty =
                                analysis.recommendedSpecialty;
                            final uri = specialty != null &&
                                    specialty.isNotEmpty
                                ? '${AppRoutes.doctors}?specialty=${Uri.encodeComponent(specialty)}'
                                : AppRoutes.doctors;
                            context.go(uri);
                          },
                          icon: const Icon(
                              Icons.person_search_outlined,
                              size: 18),
                          label: const Text('Find Doctors'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ref
                                .read(checkerFormProvider.notifier)
                                .reset();
                            ref
                                .read(analysisProvider.notifier)
                                .reset();
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                            context.go(AppRoutes.history);
                          },
                          icon: const Icon(Icons.history_rounded,
                              size: 18),
                          label: const Text('View History'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Disclaimer ───────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardSecondaryDark
                          : AppColors.cardSecondaryLight,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            analysis.disclaimer,
                            style:
                                AppTextStyles.bodySmall(dark: isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: 32 +
                          MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Risk meter ───────────────────────────────────────────────

class _RiskMeter extends StatelessWidget {
  const _RiskMeter({required this.risk, required this.isDark});
  final RiskLevel risk;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            risk.color.withValues(alpha: 0.12),
            risk.color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: risk.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Gauge
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: risk == RiskLevel.low
                        ? 0.28
                        : risk == RiskLevel.moderate
                            ? 0.6
                            : 0.95,
                  ),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => CustomPaint(
                    size: const Size(110, 110),
                    painter: _RiskArcPainter(v, risk.color),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      risk == RiskLevel.high
                          ? Icons.warning_rounded
                          : risk == RiskLevel.moderate
                              ? Icons.info_rounded
                              : Icons.check_circle_rounded,
                      color: risk.color,
                      size: 28,
                    ),
                    Text(
                      risk == RiskLevel.low
                          ? 'LOW'
                          : risk == RiskLevel.moderate
                              ? 'MOD'
                              : 'HIGH',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: risk.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Risk Assessment',
                    style: AppTextStyles.labelMedium(
                        color: risk.color.withValues(alpha: 0.8))),
                const SizedBox(height: 4),
                Text(risk.label,
                    style: AppTextStyles.headlineMedium(
                        color: risk.color)),
                const SizedBox(height: 8),
                // Three-segment indicator
                Row(
                  children: [
                    _RiskSegment(
                      label: 'Low',
                      active: risk == RiskLevel.low,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    _RiskSegment(
                      label: 'Moderate',
                      active: risk == RiskLevel.moderate,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    _RiskSegment(
                      label: 'High',
                      active: risk == RiskLevel.high,
                      color: AppColors.danger,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskArcPainter extends CustomPainter {
  const _RiskArcPainter(this.progress, this.color);
  final double progress;
  final Color color;

  static const _start = math.pi + math.pi / 4;
  static const _sweep = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const sw = 9.0;

    canvas.drawArc(
      rect, _start, _sweep, false,
      Paint()
        ..color = color.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );
    if (progress > 0.01) {
      canvas.drawArc(
        rect, _start, _sweep * progress, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RiskArcPainter old) => old.progress != progress;
}

class _RiskSegment extends StatelessWidget {
  const _RiskSegment({
    required this.label,
    required this.active,
    required this.color,
  });
  final String label;
  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 6,
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

// ─── Emergency warnings ───────────────────────────────────────

class _EmergencyWarnings extends StatelessWidget {
  const _EmergencyWarnings({required this.warnings});
  final List<String> warnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_rounded,
                  color: AppColors.danger, size: 20),
              const SizedBox(width: 8),
              Text(
                'Emergency Warnings',
                style: AppTextStyles.titleSmall(color: AppColors.danger),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...warnings.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      w,
                      style: AppTextStyles.bodyMedium(
                          color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Condition card ───────────────────────────────────────────

class _ConditionCard extends StatelessWidget {
  const _ConditionCard(
      {required this.condition, required this.isDark});
  final PossibleCondition condition;
  final bool isDark;

  Color _confidenceColor(int c) {
    if (c >= 70) return AppColors.warning;
    if (c >= 40) return AppColors.info;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final color = _confidenceColor(condition.confidence);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(condition.name,
                    style:
                        AppTextStyles.titleSmall(dark: isDark)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${condition.confidence}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: condition.confidence / 100),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                backgroundColor:
                    color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 5,
              ),
            ),
          ),
          if (condition.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              condition.description,
              style: AppTextStyles.bodySmall(dark: isDark),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Recommendation card ──────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard(
      {required this.rec, required this.isDark});
  final AiRecommendation rec;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(rec.icon, size: 20, color: AppColors.primary),
          ),
          const Spacer(),
          Text(rec.title,
              style: AppTextStyles.titleSmall(dark: isDark)),
          const SizedBox(height: 3),
          Text(
            rec.description,
            style: AppTextStyles.bodySmall(dark: isDark),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Section title ────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.isDark,
  });
  final String title;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleLarge(dark: isDark)),
      ],
    );
  }
}
