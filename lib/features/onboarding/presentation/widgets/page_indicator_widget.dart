import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PageIndicator extends StatelessWidget {
  final int count;
  final int current;
  final Color? activeColor;
  final Color? inactiveColor;

  const PageIndicator({
    super.key,
    required this.count,
    required this.current,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.primary;
    final inactive = inactiveColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.borderDark
            : AppColors.borderLight);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          width: isActive ? 28 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? active : inactive,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
