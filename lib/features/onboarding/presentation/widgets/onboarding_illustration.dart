import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/onboarding_data.dart';

class OnboardingIllustration extends StatelessWidget {
  final IllustrationType type;
  final List<Color> bgColors;

  const OnboardingIllustration({
    super.key,
    required this.type,
    required this.bgColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bgColors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _bgCircles(),
          Center(child: _buildIllustration()),
        ],
      ),
    );
  }

  Widget _bgCircles() {
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: bgColors[1].withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          left: -30,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: bgColors[1].withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    switch (type) {
      case IllustrationType.aiAnalysis:
        return const _AiAnalysisIllustration();
      case IllustrationType.findDoctors:
        return const _FindDoctorsIllustration();
      case IllustrationType.healthHistory:
        return const _HealthHistoryIllustration();
      case IllustrationType.recommendations:
        return const _RecommendationsIllustration();
    }
  }
}

// ─── AI Analysis Illustration ─────────────────────────────
class _AiAnalysisIllustration extends StatelessWidget {
  const _AiAnalysisIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.illustrationGreen.withValues(alpha: 0.2),
                  width: 1.5),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1.05, 1.05),
              duration: 2000.ms,
              curve: Curves.easeInOut),

          // Middle ring
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.illustrationGreen.withValues(alpha: 0.3),
                  width: 1.5),
            ),
          ),

          // Main circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.illustrationGreen.withValues(alpha: 0.25),
                    blurRadius: 40,
                    offset: const Offset(0, 12)),
              ],
            ),
            child: const Icon(
              Icons.psychology_rounded,
              size: 68,
              color: AppColors.illustrationGreen,
            ),
          ),

          // Floating node indicators
          ..._buildNodes(),
        ],
      ),
    );
  }

  List<Widget> _buildNodes() {
    final positions = [
      const Offset(-108, -40),
      const Offset(108, -60),
      const Offset(-90, 80),
      const Offset(100, 70),
      const Offset(0, -118),
    ];
    final colors = [
      AppColors.illustrationGreen,
      AppColors.illustrationBlue,
      AppColors.illustrationGreen,
      AppColors.illustrationAmber,
      AppColors.illustrationGreen,
    ];

    return List.generate(positions.length, (i) {
      return Positioned(
        left: 140 + positions[i].dx,
        top: 140 + positions[i].dy,
        child: _NodeDot(color: colors[i])
            .animate(delay: (i * 120).ms)
            .scale(
                begin: const Offset(0, 0),
                duration: 500.ms,
                curve: Curves.elasticOut)
            .fadeIn(duration: 300.ms),
      );
    });
  }
}

class _NodeDot extends StatelessWidget {
  final Color color;
  const _NodeDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)],
      ),
    );
  }
}

// ─── Find Doctors Illustration ────────────────────────────
class _FindDoctorsIllustration extends StatelessWidget {
  const _FindDoctorsIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Map grid background
          CustomPaint(
            size: const Size(300, 300),
            painter: _MapGridPainter(),
          ),

          // Main location pin
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.illustrationBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.illustrationBlue.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: Colors.white, size: 42),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                  begin: 0,
                  end: -8,
                  duration: 1800.ms,
                  curve: Curves.easeInOut),
              const SizedBox(height: 4),
              CustomPaint(
                size: const Size(24, 12),
                painter: _ShadowEllipsePainter(),
              ),
            ],
          ),

          // Surrounding pins
          ..._buildSmallPins(),
        ],
      ),
    );
  }

  List<Widget> _buildSmallPins() {
    final positions = [
      const Offset(-100, -60),
      const Offset(95, -80),
      const Offset(-80, 80),
      const Offset(105, 60),
    ];

    return List.generate(4, (i) {
      return Positioned(
        left: 150 + positions[i].dx,
        top: 150 + positions[i].dy,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: i.isEven
                ? AppColors.illustrationGreen
                : AppColors.illustrationAmber,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (i.isEven
                        ? AppColors.illustrationGreen
                        : AppColors.illustrationAmber)
                    .withValues(alpha: 0.35),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(
            i.isEven ? Icons.person_rounded : Icons.star_rounded,
            color: Colors.white,
            size: 18,
          ),
        ).animate(delay: (200 + i * 150).ms).scale(
            begin: const Offset(0, 0),
            duration: 500.ms,
            curve: Curves.elasticOut),
      );
    });
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.illustrationBlue.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ShadowEllipsePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Health History Illustration ──────────────────────────
class _HealthHistoryIllustration extends StatelessWidget {
  const _HealthHistoryIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 280,
      child: Column(
        children: [
          // Chart card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                    color: AppColors.illustrationAmber.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.illustrationAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Heart Rate',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.illustrationAmber,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.favorite_rounded,
                        color: AppColors.danger, size: 20),
                    const SizedBox(width: 4),
                    const Text(
                      '72 bpm',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomPaint(
                  size: const Size(260, 80),
                  painter: _HeartbeatChartPainter(),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms),
          const SizedBox(height: 14),
          // Stats row
          Row(
            children: [
              Expanded(
                child: const _StatCard(
                  icon: Icons.directions_walk_rounded,
                  label: 'Steps',
                  value: '8,240',
                  color: AppColors.illustrationGreen,
                )
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: -0.2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: const _StatCard(
                  icon: Icons.water_drop_rounded,
                  label: 'Water',
                  value: '2.1 L',
                  color: AppColors.illustrationBlue,
                )
                    .animate(delay: 250.ms)
                    .fadeIn(duration: 500.ms)
                    .slideX(begin: 0.2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiaryLight)),
          ],
        ),
    );
  }
}

class _HeartbeatChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.danger
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.5),
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.28, size.height * 0.1),
      Offset(size.width * 0.33, size.height * 0.9),
      Offset(size.width * 0.38, size.height * 0.3),
      Offset(size.width * 0.44, size.height * 0.5),
      Offset(size.width * 0.55, size.height * 0.5),
      Offset(size.width * 0.65, size.height * 0.5),
      Offset(size.width * 0.73, size.height * 0.1),
      Offset(size.width * 0.78, size.height * 0.9),
      Offset(size.width * 0.83, size.height * 0.3),
      Offset(size.width * 0.88, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (var p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Recommendations Illustration ────────────────────────
class _RecommendationsIllustration extends StatelessWidget {
  const _RecommendationsIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 290,
      child: Stack(
        children: [
          // Back card
          Positioned(
            top: 0,
            left: 30,
            right: 30,
            child: const _RecommendCard(
              icon: Icons.self_improvement_rounded,
              label: 'Mindfulness',
              subtitle: '10 min meditation',
              progress: 0.6,
              color: AppColors.illustrationPurple,
            )
                .animate(delay: 100.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1),
          ),

          // Middle card
          Positioned(
            top: 72,
            left: 15,
            right: 15,
            child: const _RecommendCard(
              icon: Icons.directions_run_rounded,
              label: 'Daily Exercise',
              subtitle: '30 min cardio',
              progress: 0.75,
              color: AppColors.illustrationAmber,
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1),
          ),

          // Front card
          Positioned(
            top: 144,
            left: 0,
            right: 0,
            child: const _RecommendCard(
              icon: Icons.eco_rounded,
              label: 'Healthy Diet',
              subtitle: '5 servings of veggies',
              progress: 0.45,
              color: AppColors.illustrationGreen,
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1),
          ),
        ],
      ),
    );
  }
}

class _RecommendCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final double progress;
  final Color color;

  const _RecommendCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondaryLight)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
