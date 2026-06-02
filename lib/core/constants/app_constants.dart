class AppConstants {
  AppConstants._();

  // ─── App Identity ────────────────────────────────────
  static const String appName = 'HealthAI';
  static const String appTagline = 'Your AI-Powered Health Companion';
  static const String appVersion = '1.0.0';

  // ─── Storage Keys ────────────────────────────────────
  static const String onboardingSeenKey = 'onboarding_seen';
  static const String themeModeKey = 'theme_mode';
  static const String rememberMeKey = 'remember_me';
  static const String savedEmailKey = 'saved_email';

  // ─── Durations ───────────────────────────────────────
  static const Duration splashDelay = Duration(milliseconds: 2800);
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration pageTransition = Duration(milliseconds: 380);

  // ─── Radius ──────────────────────────────────────────
  static const double radiusXS = 6.0;
  static const double radiusSM = 10.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 24.0;
  static const double radiusXL = 32.0;
  static const double radiusXXL = 40.0;

  // ─── Spacing ─────────────────────────────────────────
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ─── Screen Padding ──────────────────────────────────
  static const double horizontalPad = 24.0;
  static const double verticalPad = 24.0;
}
