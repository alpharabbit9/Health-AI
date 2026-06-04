import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
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
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_users_screen.dart';
import '../../features/admin/presentation/screens/admin_analyses_screen.dart';
import '../../features/admin/presentation/screens/admin_doctors_screen.dart';
import '../../features/admin/presentation/screens/admin_health_tips_screen.dart';
import '../../features/admin/presentation/screens/admin_feedback_screen.dart';
import '../../features/admin/presentation/widgets/admin_shell.dart';
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

  // ─── Admin ────────────────────────────────────────────────
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminAnalyses = '/admin/analyses';
  static const String adminDoctors = '/admin/doctors';
  static const String adminHealthTips = '/admin/health-tips';
  static const String adminFeedback = '/admin/feedback';
}

// ─── Router refresh notifier ──────────────────────────────────
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

// ─── Router provider ──────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;
      final isAdminRoute = loc.startsWith('/admin');

      if (isAdminRoute) {
        // While auth is still resolving (app cold-start), don't bounce —
        // the splash only routes here after confirming an admin session.
        if (auth is AuthInitial || auth is AuthLoading) return null;
        if (auth is! AuthAuthenticated) return AppRoutes.login;
        if (!auth.user.isAdmin) return AppRoutes.home;
      }
      return null;
    },
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

      // ─── Admin shell ──────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.admin,
            pageBuilder: (_, state) =>
                const NoTransitionPage(child: AdminDashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminUsers,
            pageBuilder: (_, state) =>
                _slideTransitionPage(state, const AdminUsersScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminAnalyses,
            pageBuilder: (_, state) =>
                _slideTransitionPage(state, const AdminAnalysesScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminDoctors,
            pageBuilder: (_, state) =>
                _slideTransitionPage(state, const AdminDoctorsScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminHealthTips,
            pageBuilder: (_, state) =>
                _slideTransitionPage(state, const AdminHealthTipsScreen()),
          ),
          GoRoute(
            path: AppRoutes.adminFeedback,
            pageBuilder: (_, state) =>
                _slideTransitionPage(state, const AdminFeedbackScreen()),
          ),
        ],
      ),

      // ─── User shell (bottom nav) ───────────────────────────
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
                  pageBuilder: (_, state) =>
                      _slideTransitionPage(state, const SymptomCheckerScreen()),
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
                final specialty = state.uri.queryParameters['specialty'];
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
      ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}
