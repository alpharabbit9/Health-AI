import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarUrl = ref.watch(
      healthProfileProvider.select((p) => p?.avatarUrl),
    );

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _FloatingNav(
        currentIndex: navigationShell.currentIndex,
        isDark: Theme.of(context).brightness == Brightness.dark,
        avatarUrl: avatarUrl,
        onTap: (i) {
          HapticFeedback.selectionClick();
          navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

// ─── Nav item model ───────────────────────────────────────────

class _Item {
  const _Item({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const _items = [
  _Item(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  ),
  _Item(
    icon: Icons.medical_services_outlined,
    activeIcon: Icons.medical_services_rounded,
    label: 'Symptoms',
  ),
  _Item(
    icon: Icons.history_outlined,
    activeIcon: Icons.history_rounded,
    label: 'History',
  ),
  _Item(
    icon: Icons.person_search_outlined,
    activeIcon: Icons.person_search_rounded,
    label: 'Doctors',
  ),
  _Item(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profile',
  ),
];

// ─── Floating nav bar ─────────────────────────────────────────

class _FloatingNav extends StatelessWidget {
  const _FloatingNav({
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
    this.avatarUrl,
  });
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, (bottom > 0 ? bottom : 12) + 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDark.withValues(alpha: 0.88)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.05),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.10),
                  blurRadius: 32,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: List.generate(
                _items.length,
                (i) => Expanded(
                  child: i == 4
                      ? _ProfileNavTile(
                          active: currentIndex == 4,
                          isDark: isDark,
                          avatarUrl: avatarUrl,
                          onTap: () => onTap(4),
                        )
                      : _NavTile(
                          item: _items[i],
                          active: currentIndex == i,
                          isDark: isDark,
                          onTap: () => onTap(i),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Profile nav tile (avatar or icon) ───────────────────────

class _ProfileNavTile extends StatelessWidget {
  const _ProfileNavTile({
    required this.active,
    required this.isDark,
    required this.onTap,
    this.avatarUrl,
  });

  final bool active;
  final bool isDark;
  final VoidCallback onTap;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark ? Colors.white38 : Colors.black38;
    final hasPhoto = avatarUrl != null && avatarUrl!.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? AppColors.primary
                    : Colors.transparent,
                width: 2,
              ),
              color: active && !hasPhoto
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
            ),
            child: hasPhoto
                ? CircleAvatar(
                    radius: 13,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    backgroundImage: NetworkImage(avatarUrl!),
                    onBackgroundImageError: (_, __) {},
                  )
                : CircleAvatar(
                    radius: 13,
                    backgroundColor: active
                        ? AppColors.primary.withValues(alpha: 0.14)
                        : Colors.transparent,
                    child: Icon(
                      active
                          ? Icons.person_rounded
                          : Icons.person_outline_rounded,
                      size: 20,
                      color: active ? AppColors.primary : inactiveColor,
                    ),
                  ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: AppTextStyles.labelSmall(
              color: active ? AppColors.primary : inactiveColor,
            ).copyWith(
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              fontSize: 10,
            ),
            child: const Text('Profile'),
          ),
        ],
      ),
    );
  }
}

// ─── Standard nav tile ────────────────────────────────────────

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.active,
    required this.isDark,
    required this.onTap,
  });
  final _Item item;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark ? Colors.white38 : Colors.black38;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              active ? item.activeIcon : item.icon,
              size: 21,
              color: active ? AppColors.primary : inactiveColor,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: AppTextStyles.labelSmall(
              color: active ? AppColors.primary : inactiveColor,
            ).copyWith(
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              fontSize: 10,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}
