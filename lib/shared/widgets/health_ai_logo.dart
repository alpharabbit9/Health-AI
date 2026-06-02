import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HealthAILogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? iconColor;
  final Color? bgColor;

  const HealthAILogo({
    super.key,
    this.size = 64,
    this.showText = false,
    this.iconColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoIcon(size: size, iconColor: iconColor, bgColor: bgColor),
        if (showText) ...[
          SizedBox(height: size * 0.18),
          Text(
            'HealthAI',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: size * 0.45,
              fontWeight: FontWeight.w800,
              color: iconColor ?? Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoIcon extends StatelessWidget {
  final double size;
  final Color? iconColor;
  final Color? bgColor;

  const _LogoIcon({required this.size, this.iconColor, this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.55, size * 0.55),
          painter: _CrossHeartPainter(iconColor ?? Colors.white),
        ),
      ),
    );
  }
}

class _CrossHeartPainter extends CustomPainter {
  final Color color;
  _CrossHeartPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final strokeW = w * 0.22;

    // Vertical bar of cross
    final vBar = RRect.fromRectAndRadius(
      Rect.fromLTWH((w - strokeW) / 2, 0, strokeW, h),
      Radius.circular(strokeW / 2),
    );
    canvas.drawRRect(vBar, paint);

    // Horizontal bar of cross
    final hBar = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, (h - strokeW) / 2, w, strokeW),
      Radius.circular(strokeW / 2),
    );
    canvas.drawRRect(hBar, paint);
  }

  @override
  bool shouldRepaint(_CrossHeartPainter old) => old.color != color;
}

// ─── Small inline logo chip ──────────────────────────────
class HealthAILogoChip extends StatelessWidget {
  final double height;
  const HealthAILogoChip({super.key, this.height = 32});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoIcon(size: height, bgColor: AppColors.primary, iconColor: Colors.white),
        SizedBox(width: height * 0.22),
        Text(
          'HealthAI',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: height * 0.56,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}
