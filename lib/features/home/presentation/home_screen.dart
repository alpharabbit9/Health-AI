import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../history/domain/entities/health_record.dart';
import '../../history/presentation/providers/history_provider.dart';
import '../../profile/presentation/providers/profile_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final records = ref.watch(healthRecordsProvider);
    final score = ref.watch(healthScoreProvider);
    final isDark = context.isDark;
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    final firstName = user?.fullName?.split(' ').first ??
        user?.email.split('@').first ??
        'there';

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _Header(
              firstName: firstName,
              isDark: isDark,
              topPadding: top,
              initials: _initials(user?.fullName ?? ''),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: _HealthScoreCard(score: score),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _SectionHeader(title: 'Quick Stats', isDark: isDark),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: _QuickStatsGrid(records: records, isDark: isDark),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child:
                _SectionHeader(title: 'Quick Actions', isDark: isDark),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: _QuickActionsGrid(
              recordCount: records.length,
              isDark: isDark,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child:
                _SectionHeader(title: 'Health Tips', isDark: isDark),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          const SliverToBoxAdapter(child: _HealthTipsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          if (records.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Recent Analysis',
                isDark: isDark,
                actionLabel: 'See All',
                onAction: () => context.go(AppRoutes.history),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: _RecentAnalysis(
                records: records.take(3).toList(),
                isDark: isDark,
              ),
            ),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 100 + bottom)),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.isEmpty) return 'H';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

// ─── Header ───────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.firstName,
    required this.isDark,
    required this.topPadding,
    required this.initials,
  });

  final String firstName;
  final bool isDark;
  final double topPadding;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Padding(
      padding: EdgeInsets.fromLTRB(24, topPadding + 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting 👋',
                    style: AppTextStyles.bodyMedium(dark: isDark)),
                const SizedBox(height: 2),
                Text(firstName,
                    style:
                        AppTextStyles.headlineLarge(dark: isDark)),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: context.borderColor),
            ),
            child: Icon(Icons.notifications_outlined,
                size: 20, color: context.textSecondary),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: AppColors.primaryGradient),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─── Health score card ────────────────────────────────────────

class _HealthScoreCard extends StatelessWidget {
  const _HealthScoreCard({required this.score});
  final int score;

  String get _label {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 55) return 'Fair';
    return 'Needs Attention';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 176,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.38),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: 56,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Health Score',
                          style: AppTextStyles.labelMedium(
                            color:
                                Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _label,
                          style: AppTextStyles.headlineLarge(
                              color: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          'Based on your health profile',
                          style: AppTextStyles.bodySmall(
                            color:
                                Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Updated just now',
                          style: AppTextStyles.labelSmall(
                            color:
                                Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _ScoreGauge(score: score),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreGauge extends StatelessWidget {
  const _ScoreGauge({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score / 100),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeOutCubic,
      builder: (_, progress, __) {
        final displayed =
            progress < 0.001 ? 0 : (progress * score / progress).round();
        return SizedBox(
          width: 112,
          height: 112,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(112, 112),
                painter: _ArcPainter(progress),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$displayed',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter(this.progress);
  final double progress;

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
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0.01) {
      canvas.drawArc(
        rect, _start, _sweep * progress, false,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ─── Quick stats ──────────────────────────────────────────────

class _QuickStatsGrid extends StatelessWidget {
  const _QuickStatsGrid(
      {required this.records, required this.isDark});
  final List<HealthRecord> records;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData(
        icon: Icons.health_and_safety_outlined,
        value: records.length,
        label: 'Symptom\nChecks',
        color: const Color(0xFF8B5CF6),
        bgLight: const Color(0xFFF3F0FF),
        bgDark: const Color(0xFF2D1F4E),
      ),
      _StatData(
        icon: Icons.description_outlined,
        value: records.length,
        label: 'Reports\nSaved',
        color: AppColors.info,
        bgLight: AppColors.infoLight,
        bgDark: const Color(0xFF1A2A4A),
      ),
      _StatData(
        icon: Icons.local_hospital_outlined,
        value: 1,
        label: 'Doctor\nConsults',
        color: AppColors.primary,
        bgLight: AppColors.primaryLight,
        bgDark: const Color(0xFF0D2E1C),
      ),
      _StatData(
        icon: Icons.water_drop_outlined,
        value: 6,
        label: 'Water\nCups',
        color: const Color(0xFF06B6D4),
        bgLight: const Color(0xFFE0F7FA),
        bgDark: const Color(0xFF0A2A30),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
        children: stats
            .map((s) => _StatCard(data: s, isDark: isDark))
            .toList(),
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bgLight,
    required this.bgDark,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color color;
  final Color bgLight;
  final Color bgDark;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data, required this.isDark});
  final _StatData data;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? data.bgDark : data.bgLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, size: 18, color: data.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: data.value),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (_, val, __) => Text(
                    '$val',
                    style: AppTextStyles.headlineMedium(
                            dark: isDark)
                        .copyWith(fontSize: 22),
                  ),
                ),
                Text(data.label,
                    style:
                        AppTextStyles.bodySmall(dark: isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick actions ────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid(
      {required this.recordCount, required this.isDark});
  final int recordCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData(
        icon: Icons.medical_services_outlined,
        title: 'Check Symptoms',
        subtitle: 'AI Analysis',
        gradient: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        route: AppRoutes.symptoms,
      ),
      _ActionData(
        icon: Icons.person_search_outlined,
        title: 'Find Doctors',
        subtitle: 'Nearby',
        gradient: AppColors.primaryGradient,
        route: AppRoutes.doctors,
      ),
      _ActionData(
        icon: Icons.history_rounded,
        title: 'Health History',
        subtitle: '$recordCount records',
        gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
        route: AppRoutes.history,
      ),
      _ActionData(
        icon: Icons.emergency_rounded,
        title: 'Emergency Help',
        subtitle: 'SOS',
        gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
        route: null,
        onTap: (ctx) => ctx.showErrorSnack('Calling 911…'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.05,
        children: actions
            .map((a) => _ActionCard(data: a))
            .toList(),
      ),
    );
  }
}

class _ActionData {
  const _ActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    this.route,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final String? route;
  final void Function(BuildContext)? onTap;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.data});
  final _ActionData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (data.onTap != null) {
          data.onTap!(context);
        } else if (data.route != null) {
          context.go(data.route!);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: data.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: data.gradient.first.withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(data.icon, size: 22, color: Colors.white),
            ),
            const Spacer(),
            Text(data.title,
                style: AppTextStyles.titleSmall(
                    color: Colors.white)),
            const SizedBox(height: 2),
            Text(
              data.subtitle,
              style: AppTextStyles.bodySmall(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Health tips ──────────────────────────────────────────────

class _HealthTipsSection extends StatelessWidget {
  const _HealthTipsSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 156,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _kTips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _TipCard(tip: _kTips[i]),
      ),
    );
  }
}

class _TipData {
  const _TipData({
    required this.emoji,
    required this.title,
    required this.body,
    required this.color,
  });

  final String emoji;
  final String title;
  final String body;
  final Color color;
}

const _kTips = [
  _TipData(
    emoji: '💧',
    title: 'Stay Hydrated',
    body: 'Drink 8 glasses of water daily',
    color: Color(0xFF06B6D4),
  ),
  _TipData(
    emoji: '🏃',
    title: 'Exercise Daily',
    body: '30 min of moderate activity',
    color: Color(0xFF16C35B),
  ),
  _TipData(
    emoji: '😴',
    title: 'Sleep Better',
    body: 'Aim for 7–9 hours each night',
    color: Color(0xFF8B5CF6),
  ),
  _TipData(
    emoji: '🥗',
    title: 'Eat Balanced',
    body: 'Include fruits and vegetables',
    color: Color(0xFFF59E0B),
  ),
  _TipData(
    emoji: '🧘',
    title: 'Manage Stress',
    body: 'Practise mindfulness daily',
    color: Color(0xFFEF4444),
  ),
];

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});
  final _TipData tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tip.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: tip.color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tip.emoji,
              style: const TextStyle(fontSize: 30)),
          const Spacer(),
          Text(
            tip.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: tip.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tip.body,
            style: TextStyle(
              fontSize: 11,
              color: tip.color.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recent analysis ──────────────────────────────────────────

class _RecentAnalysis extends StatelessWidget {
  const _RecentAnalysis(
      {required this.records, required this.isDark});
  final List<HealthRecord> records;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: records
            .map((r) => _RecentCard(record: r, isDark: isDark))
            .toList(),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard(
      {required this.record, required this.isDark});
  final HealthRecord record;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final risk = record.riskLevel;
    final diff = DateTime.now().difference(record.date);
    final timeLabel = diff.inMinutes < 60
        ? '${diff.inMinutes}m ago'
        : diff.inHours < 24
            ? '${diff.inHours}h ago'
            : '${diff.inDays}d ago';

    return GestureDetector(
      onTap: () => context.push('/history/${record.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.symptoms.take(2).join(', '),
                    style:
                        AppTextStyles.titleSmall(dark: isDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(timeLabel,
                      style:
                          AppTextStyles.bodySmall(dark: isDark)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
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
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: context.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.isDark,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final bool isDark;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: AppTextStyles.titleLarge(dark: isDark)),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.labelMedium(
                    color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
