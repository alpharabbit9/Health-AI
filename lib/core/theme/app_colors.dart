import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primary Brand ───────────────────────────────────
  static const Color primary = Color(0xFF16C35B);
  static const Color primaryDark = Color(0xFF109848);
  static const Color primaryMid = Color(0xFF12A84D);
  static const Color primaryLight = Color(0xFFEAFBF1);
  static const Color primarySurface = Color(0xFFD1F5E3);

  // ─── Backgrounds ─────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8FAF9);
  static const Color backgroundDark = Color(0xFF111315);

  // ─── Cards ────────────────────────────────────────────
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1A1D20);
  static const Color cardSecondaryLight = Color(0xFFF0F5F2);
  static const Color cardSecondaryDark = Color(0xFF22262A);

  // ─── Text ─────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);

  // ─── Semantic ─────────────────────────────────────────
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ─── Borders & Dividers ───────────────────────────────
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF2D3238);
  static const Color dividerLight = Color(0xFFF3F4F6);
  static const Color dividerDark = Color(0xFF1F2328);

  // ─── Gradients ────────────────────────────────────────
  static const List<Color> primaryGradient = [
    Color(0xFF16C35B),
    Color(0xFF109848),
  ];

  static const List<Color> splashGradient = [
    Color(0xFF0D5C35),
    Color(0xFF111315),
  ];

  static const List<Color> cardGradientLight = [
    Color(0xFFFFFFFF),
    Color(0xFFF8FAF9),
  ];

  static const List<Color> cardGradientDark = [
    Color(0xFF1E2226),
    Color(0xFF1A1D20),
  ];

  // ─── Onboarding illustrations ─────────────────────────
  static const Color illustrationGreen = Color(0xFF16C35B);
  static const Color illustrationGreenLight = Color(0xFFB7EDD4);
  static const Color illustrationBlue = Color(0xFF60A5FA);
  static const Color illustrationBlueLight = Color(0xFFDBEAFE);
  static const Color illustrationAmber = Color(0xFFFBBF24);
  static const Color illustrationPurple = Color(0xFFA78BFA);

  // ─── Shimmer ──────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE0E5E2);
  static const Color shimmerHighlight = Color(0xFFF5F8F6);
  static const Color shimmerBaseDark = Color(0xFF252A2E);
  static const Color shimmerHighlightDark = Color(0xFF2E3438);
}
