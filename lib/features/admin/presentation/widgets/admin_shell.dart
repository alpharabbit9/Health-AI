import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/health_ai_logo.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      drawer: _AdminDrawer(currentLocation: loc),
      appBar: _AdminAppBar(location: loc, isDark: isDark),
      body: child,
    );
  }
}

// ─── App Bar ─────────────────────────────────────────────────

class _AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AdminAppBar({required this.location, required this.isDark});
  final String location;
  final bool isDark;

  String get _title {
    if (location.startsWith(AppRoutes.adminUsers)) return 'User Management';
    if (location.startsWith(AppRoutes.adminAnalyses)) {
      return 'Analysis Monitor';
    }
    if (location.startsWith(AppRoutes.adminDoctors)) return 'Doctor Management';
    if (location.startsWith(AppRoutes.adminHealthTips)) return 'Health Tips';
    if (location.startsWith(AppRoutes.adminFeedback)) return 'Feedback';
    return 'Admin Dashboard';
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          isDark ? AppColors.cardDark : AppColors.cardLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 64,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Text(
        _title,
        style: AppTextStyles.headlineSmall(dark: isDark),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
    );
  }
}

// ─── Drawer ───────────────────────────────────────────────────

class _AdminDrawer extends ConsumerWidget {
  const _AdminDrawer({required this.currentLocation});
  final String currentLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);

    return Drawer(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────
            _DrawerHeader(user: user, isDark: isDark),
            const SizedBox(height: 8),
            Divider(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              height: 1,
            ),
            const SizedBox(height: 8),

            // ─── Nav items ───────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _NavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    route: AppRoutes.admin,
                    currentLocation: currentLocation,
                    isDark: isDark,
                  ),
                  _NavItem(
                    icon: Icons.people_outline_rounded,
                    activeIcon: Icons.people_rounded,
                    label: 'Users',
                    route: AppRoutes.adminUsers,
                    currentLocation: currentLocation,
                    isDark: isDark,
                  ),
                  _NavItem(
                    icon: Icons.analytics_outlined,
                    activeIcon: Icons.analytics_rounded,
                    label: 'Analyses',
                    route: AppRoutes.adminAnalyses,
                    currentLocation: currentLocation,
                    isDark: isDark,
                  ),
                  _NavItem(
                    icon: Icons.medical_services_outlined,
                    activeIcon: Icons.medical_services_rounded,
                    label: 'Doctors',
                    route: AppRoutes.adminDoctors,
                    currentLocation: currentLocation,
                    isDark: isDark,
                  ),
                  _NavItem(
                    icon: Icons.lightbulb_outline_rounded,
                    activeIcon: Icons.lightbulb_rounded,
                    label: 'Health Tips',
                    route: AppRoutes.adminHealthTips,
                    currentLocation: currentLocation,
                    isDark: isDark,
                  ),
                  _NavItem(
                    icon: Icons.feedback_outlined,
                    activeIcon: Icons.feedback_rounded,
                    label: 'Feedback',
                    route: AppRoutes.adminFeedback,
                    currentLocation: currentLocation,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // ─── Footer ──────────────────────────────────
            Divider(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _SignOutTile(isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.user, required this.isDark});
  final dynamic user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          const HealthAILogo(
            size: 40,
            bgColor: AppColors.primary,
            iconColor: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HealthAI Admin',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: AppTextStyles.bodySmall(dark: isDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.currentLocation,
    required this.isDark,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String currentLocation;
  final bool isDark;

  bool get _active => currentLocation == route ||
      (route != AppRoutes.admin && currentLocation.startsWith(route));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).pop(); // close drawer
            context.go(route);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: _active
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _active ? activeIcon : icon,
                  size: 20,
                  color: _active
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTextStyles.titleSmall(
                    color: _active
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ).copyWith(
                    fontWeight:
                        _active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignOutTile extends ConsumerWidget {
  const _SignOutTile({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          Navigator.of(context).pop();
          await ref.read(authProvider.notifier).signOut();
          if (context.mounted) context.go(AppRoutes.login);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              const Icon(Icons.logout_rounded,
                  size: 20, color: AppColors.danger),
              const SizedBox(width: 12),
              Text(
                'Sign Out',
                style: AppTextStyles.titleSmall(color: AppColors.danger),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
