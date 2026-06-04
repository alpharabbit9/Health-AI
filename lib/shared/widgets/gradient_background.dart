import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  const GradientBackground.splash({super.key, required this.child})
      : colors = AppColors.splashGradient,
        begin = Alignment.topCenter,
        end = Alignment.bottomCenter;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: colors ?? AppColors.primaryGradient,
        ),
      ),
      child: child,
    );
  }
}

// ─── Decorative background circles ────────────────────────
class BlobDecoration extends StatelessWidget {
  final bool topRight;
  final bool bottomLeft;
  final Color? color;

  const BlobDecoration({
    super.key,
    this.topRight = true,
    this.bottomLeft = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary.withValues(alpha: 0.07);
    return Stack(
      children: [
        if (topRight)
          Positioned(
            top: -80,
            right: -80,
            child: _Blob(size: 260, color: c),
          ),
        if (bottomLeft)
          Positioned(
            bottom: -100,
            left: -60,
            child: _Blob(size: 220, color: c),
          ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
