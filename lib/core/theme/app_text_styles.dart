import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─── Display ──────────────────────────────────────────
  static TextStyle displayLarge({Color? color, bool dark = false}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.1,
        color: color ?? (dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      );

  static TextStyle displayMedium({Color? color, bool dark = false}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
        color: color ?? (dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      );

  static TextStyle displaySmall({Color? color, bool dark = false}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.2,
        color: color ?? (dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      );

  // ─── Headlines ────────────────────────────────────────
  static TextStyle headlineLarge({Color? color, bool dark = false}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.25,
        color: color ?? (dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      );

  static TextStyle headlineMedium({Color? color, bool dark = false}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.3,
        color: color ?? (dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      );

  static TextStyle headlineSmall({Color? color, bool dark = false}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: color ?? (dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      );

  // ─── Titles ───────────────────────────────────────────
  static TextStyle titleLarge({Color? color, bool dark = false}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color ?? (dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      );

  static TextStyle titleMedium({Color? color, bool dark = false}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color ?? (dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      );

  static TextStyle titleSmall({Color? color, bool dark = false}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color ?? (dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      );

  // ─── Body ─────────────────────────────────────────────
  static TextStyle bodyLarge({Color? color, bool dark = false}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: color ?? (dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      );

  static TextStyle bodyMedium({Color? color, bool dark = false}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: color ?? (dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      );

  static TextStyle bodySmall({Color? color, bool dark = false}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? (dark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
      );

  // ─── Labels ───────────────────────────────────────────
  static TextStyle labelLarge({Color? color, bool dark = false}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color ?? (dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      );

  static TextStyle labelMedium({Color? color, bool dark = false}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: color ?? (dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
      );

  static TextStyle labelSmall({Color? color, bool dark = false}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color ?? (dark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
      );

  // ─── Special ──────────────────────────────────────────
  static TextStyle appTitle({Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: color ?? Colors.white,
      );

  static TextStyle button({Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle buttonSmall({Color? color}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle tagline({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: color ?? Colors.white.withValues(alpha: 0.8),
      );
}
