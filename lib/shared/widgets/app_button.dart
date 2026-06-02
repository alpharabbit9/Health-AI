import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum AppButtonStyle { primary, secondary, outline, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool isLoading;
  final bool fullWidth;
  final double? height;
  final double? fontSize;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 54,
    this.fontSize = 15,
    this.leading,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: _buildByStyle(isDark),
    );
  }

  Widget _buildByStyle(bool isDark) {
    switch (style) {
      case AppButtonStyle.primary:
        return _PrimaryBtn(
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          leading: leading,
          trailing: trailing,
          fontSize: fontSize!,
          padding: padding,
        );
      case AppButtonStyle.secondary:
        return _SecondaryBtn(
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          leading: leading,
          trailing: trailing,
          fontSize: fontSize!,
          padding: padding,
        );
      case AppButtonStyle.outline:
        return _OutlineBtn(
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          leading: leading,
          trailing: trailing,
          fontSize: fontSize!,
          isDark: isDark,
          padding: padding,
        );
      case AppButtonStyle.ghost:
        return _GhostBtn(
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          leading: leading,
          trailing: trailing,
          fontSize: fontSize!,
          padding: padding,
        );
      case AppButtonStyle.danger:
        return _DangerBtn(
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          leading: leading,
          trailing: trailing,
          fontSize: fontSize!,
          padding: padding,
        );
    }
  }
}

// ─── Primary ──────────────────────────────────────────────
class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const _PrimaryBtn({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.leading,
    required this.trailing,
    required this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null && !isLoading;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: disabled
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              ),
        color: disabled ? AppColors.borderLight : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.38),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.1),
          child: _Content(
            label: label,
            isLoading: isLoading,
            leading: leading,
            trailing: trailing,
            fontSize: fontSize,
            textColor: Colors.white,
            loaderColor: Colors.white,
            padding: padding,
          ),
        ),
      ),
    );
  }
}

// ─── Secondary ────────────────────────────────────────────
class _SecondaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const _SecondaryBtn({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.leading,
    required this.trailing,
    required this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: _Content(
            label: label,
            isLoading: isLoading,
            leading: leading,
            trailing: trailing,
            fontSize: fontSize,
            textColor: AppColors.primaryDark,
            loaderColor: AppColors.primaryDark,
            padding: padding,
          ),
        ),
      ),
    );
  }
}

// ─── Outline ──────────────────────────────────────────────
class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;
  final double fontSize;
  final bool isDark;
  final EdgeInsetsGeometry? padding;

  const _OutlineBtn({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.leading,
    required this.trailing,
    required this.fontSize,
    required this.isDark,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: _Content(
            label: label,
            isLoading: isLoading,
            leading: leading,
            trailing: trailing,
            fontSize: fontSize,
            textColor: textColor,
            loaderColor: textColor,
            padding: padding,
          ),
        ),
      ),
    );
  }
}

// ─── Ghost ────────────────────────────────────────────────
class _GhostBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const _GhostBtn({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.leading,
    required this.trailing,
    required this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: _Content(
          label: label,
          isLoading: isLoading,
          leading: leading,
          trailing: trailing,
          fontSize: fontSize,
          textColor: AppColors.primary,
          loaderColor: AppColors.primary,
          padding: padding,
        ),
      ),
    );
  }
}

// ─── Danger ───────────────────────────────────────────────
class _DangerBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const _DangerBtn({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.leading,
    required this.trailing,
    required this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: _Content(
            label: label,
            isLoading: isLoading,
            leading: leading,
            trailing: trailing,
            fontSize: fontSize,
            textColor: Colors.white,
            loaderColor: Colors.white,
            padding: padding,
          ),
        ),
      ),
    );
  }
}

// ─── Shared content ───────────────────────────────────────
class _Content extends StatelessWidget {
  final String label;
  final bool isLoading;
  final Widget? leading;
  final Widget? trailing;
  final double fontSize;
  final Color textColor;
  final Color loaderColor;
  final EdgeInsetsGeometry? padding;

  const _Content({
    required this.label,
    required this.isLoading,
    required this.leading,
    required this.trailing,
    required this.fontSize,
    required this.textColor,
    required this.loaderColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation(loaderColor),
              ),
            )
          else ...[
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.2,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ],
      ),
    );
  }
}
