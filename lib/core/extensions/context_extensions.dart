import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

extension BuildContextX on BuildContext {
  // ─── Theme shortcuts ──────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ─── Screen dimensions ────────────────────────────────
  MediaQueryData get mq => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenW => MediaQuery.of(this).size.width;
  double get screenH => MediaQuery.of(this).size.height;
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;

  // ─── Semantic color helpers ───────────────────────────
  Color get surfaceColor => isDark ? AppColors.cardDark : AppColors.cardLight;
  Color get bgColor => isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  Color get textPrimary => isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textTertiary =>
      isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
  Color get borderColor => isDark ? AppColors.borderDark : AppColors.borderLight;
  Color get dividerColor => isDark ? AppColors.dividerDark : AppColors.dividerLight;

  // ─── Snackbar helpers ────────────────────────────────
  void showSuccessSnack(String message) => _showSnack(message, AppColors.success);
  void showErrorSnack(String message) => _showSnack(message, AppColors.danger);
  void showInfoSnack(String message) => _showSnack(message, AppColors.info);

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
