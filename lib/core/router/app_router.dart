import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/doctors/presentation/doctors_screen.dart';
import '../../features/history/presentation/health_report_detail_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/symptoms/presentation/screens/symptom_checker_screen.dart';
import '../../features/symptoms/presentation/symptoms_screen.dart';
import '../../shared/widgets/app_shell.dart';

// ─── Route paths ──────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String symptoms = '/symptoms';
  static const String symptomsChecker = '/symptoms/checker';
  static const String history = '/history';
  static const String doctors = '/doctors';
  static const String profile = '/profile';
  static const String settings = '/profile/settings';
}

// ─── Router provider ──────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, state) =>
            _fadeTransitionPage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (_, state) =>
            _slideTransitionPage(state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (_, state) =>
            _slideTransitionPage(state, const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (_, state) =>
            _slideTransitionPage(state, const ForgotPasswordScreen()),
      ),

      // ─── Shell (bottom nav) ─────────────────────────────
      StatefulShellRoute.indexedStack(
        pageBuilder: (_, __, shell) => NoTransitionPage(
          child: AppShell(navigationShell: shell),
        ),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              pageBuilder: (_, state) =>
                  const NoTransitionPage(child: HomeScreen()),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.symptoms,
              pageBuilder: (_, state) =>
                  const NoTransitionPage(child: SymptomsScreen()),
              routes: [
                GoRoute(
                  path: 'checker',
                  pageBuilder: (_, state) => _slideTransitionPage(
                    state,
                    const SymptomCheckerScreen(),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.history,
              pageBuilder: (_, state) =>
                  const NoTransitionPage(child: HistoryScreen()),
              routes: [
                GoRoute(
                  path: ':id',
                  pageBuilder: (_, state) => _slideTransitionPage(
                    state,
                    HealthReportDetailScreen(
                      id: state.pathParameters['id']!,
                    ),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.doctors,
              pageBuilder: (_, state) {
                final specialty =
                    state.uri.queryParameters['specialty'];
                return NoTransitionPage(
                  child: DoctorsScreen(recommendedSpecialty: specialty),
                );
              },
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              pageBuilder: (_, state) =>
                  const NoTransitionPage(child: ProfileScreen()),
              routes: [
                GoRoute(
                  path: 'settings',
                  pageBuilder: (_, state) =>
                      _slideTransitionPage(state, const SettingsScreen()),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});

// ─── Transition helpers ───────────────────────────────────────

CustomTransitionPage<void> _fadeTransitionPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    ),
  );
}

CustomTransitionPage<void> _slideTransitionPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, animation, __, child) {
      final offset = Tween(
        begin: const Offset(0.05, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}
