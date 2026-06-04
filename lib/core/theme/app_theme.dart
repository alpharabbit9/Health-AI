import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgColor,

      // ─── Text ────────────────────────────────────────
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
            fontSize: 36, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -1),
        displayMedium: GoogleFonts.plusJakartaSans(
            fontSize: 30, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.5),
        displaySmall: GoogleFonts.plusJakartaSans(
            fontSize: 26, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.3),
        headlineLarge: GoogleFonts.plusJakartaSans(
            fontSize: 24, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.2),
        headlineMedium: GoogleFonts.plusJakartaSans(
            fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
        headlineSmall: GoogleFonts.plusJakartaSans(
            fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
        titleLarge: GoogleFonts.plusJakartaSans(
            fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
        titleMedium:
            GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: textColor),
        titleSmall:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
        bodyLarge:
            GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
        bodyMedium:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
        bodySmall:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textColor),
        labelLarge:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
        labelMedium:
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
        labelSmall:
            GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
      ),

      // ─── AppBar ──────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: bgColor,
        foregroundColor: textColor,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),

      // ─── Card ────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.06),
      ),

      // ─── Input ───────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.cardSecondaryDark : AppColors.cardLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        errorStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.danger),
      ),

      // ─── Elevated Button ─────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),

      // ─── Outlined Button ─────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),

      // ─── Text Button ─────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ─── Checkbox ────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),

      // ─── Switch ──────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return isDark ? AppColors.cardSecondaryDark : AppColors.borderLight;
        }),
      ),

      // ─── Divider ─────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        thickness: 1,
        space: 1,
      ),

      // ─── Bottom Sheet ────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        elevation: 0,
      ),

      // ─── Snack Bar ───────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.cardSecondaryDark : AppColors.textPrimaryLight,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textPrimaryDark : Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    );
  }

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.primaryDark,
    onSecondary: Colors.white,
    surface: AppColors.cardLight,
    onSurface: AppColors.textPrimaryLight,
    error: AppColors.danger,
    onError: Colors.white,
    outline: AppColors.borderLight,
    surfaceContainerHighest: AppColors.cardSecondaryLight,
    onSurfaceVariant: AppColors.textSecondaryLight,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF0D5C2E),
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.primaryLight,
    onSecondary: AppColors.primaryDark,
    surface: AppColors.cardDark,
    onSurface: AppColors.textPrimaryDark,
    error: AppColors.danger,
    onError: Colors.white,
    outline: AppColors.borderDark,
    surfaceContainerHighest: AppColors.cardSecondaryDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
  );
}
