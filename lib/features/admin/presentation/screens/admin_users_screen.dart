import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../providers/admin_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(adminUsersProvider);

    return Column(
      children: [
        // ─── Search bar ────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _SearchBar(
            controller: _searchCtrl,
            isDark: isDark,
            onChanged: (v) =>
                ref.read(adminUsersSearchProvider.notifier).state = v,
          ),
        ),

        // ─── List ──────────────────────────────────────
        Expanded(
          child: usersAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => _ErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(adminUsersProvider),
              isDark: isDark,
            ),
            data: (users) => users.isEmpty
                ? _EmptyState(isDark: isDark)
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async =>
                        ref.invalidate(adminUsersProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: users.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) => _UserCard(
                        user: users[i],
                        isDark: isDark,
                        onRoleChange: (role) => ref
                            .read(adminUsersProvider.notifier)
                            .updateRole(users[i].id, role),
                        onToggleStatus: () => ref
                            .read(adminUsersProvider.notifier)
                            .toggleStatus(users[i].id, users[i].status),
                        onDelete: () =>
                            _confirmDelete(context, ref, users[i]),
                      )
                          .animate(delay: (i * 40).ms)
                          .fadeIn(duration: 300.ms)
                          .slideX(
                              begin: 0.05,
                              end: 0,
                              duration: 300.ms,
                              curve: Curves.easeOutCubic),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, AdminUserEntity user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete User',
        message:
            'Are you sure you want to delete ${user.fullName ?? user.email}? This cannot be undone.',
      ),
    );
    if (ok == true) {
      await ref.read(adminUsersProvider.notifier).deleteUser(user.id);
    }
  }
}

// ─── Search Bar ───────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.isDark,
    required this.onChanged,
  });
  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium(dark: isDark),
      decoration: InputDecoration(
        hintText: 'Search by name or email…',
        hintStyle: AppTextStyles.bodyMedium(
          color: isDark
              ? AppColors.textTertiaryDark
              : AppColors.textTertiaryLight,
        ),
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.primary, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// ─── User Card ────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.isDark,
    required this.onRoleChange,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final AdminUserEntity user;
  final bool isDark;
  final ValueChanged<String> onRoleChange;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final initials = (user.fullName?.isNotEmpty == true)
        ? user.fullName!
            .trim()
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join()
            .toUpperCase()
        : user.email.substring(0, 1).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: avatar + name + actions
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? 'No name',
                      style: AppTextStyles.titleSmall(dark: isDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: AppTextStyles.bodySmall(dark: isDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _ActionMenu(
                user: user,
                isDark: isDark,
                onRoleChange: onRoleChange,
                onToggleStatus: onToggleStatus,
                onDelete: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom row: role badge + status badge + date
          Row(
            children: [
              _RoleBadge(role: user.role),
              const SizedBox(width: 8),
              _StatusBadge(status: user.status),
              const Spacer(),
              Text(
                DateFormat('dd MMM yyyy').format(user.createdAt),
                style: AppTextStyles.bodySmall(dark: isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAdmin
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.infoLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isAdmin ? AppColors.primary : AppColors.info,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final active = status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? AppColors.successLight : AppColors.dangerLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: active ? AppColors.success : AppColors.danger,
        ),
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  const _ActionMenu({
    required this.user,
    required this.isDark,
    required this.onRoleChange,
    required this.onToggleStatus,
    required this.onDelete,
  });
  final AdminUserEntity user;
  final bool isDark;
  final ValueChanged<String> onRoleChange;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        size: 20,
      ),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (action) {
        switch (action) {
          case 'make_admin':
            onRoleChange('admin');
          case 'make_user':
            onRoleChange('user');
          case 'toggle_status':
            onToggleStatus();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (_) => [
        if (user.role != 'admin')
          _menuItem('make_admin', Icons.shield_rounded, 'Make Admin',
              AppColors.primary, isDark),
        if (user.role == 'admin')
          _menuItem('make_user', Icons.person_rounded, 'Remove Admin',
              AppColors.warning, isDark),
        _menuItem(
          'toggle_status',
          user.isActive
              ? Icons.block_rounded
              : Icons.check_circle_outline_rounded,
          user.isActive ? 'Disable Account' : 'Enable Account',
          user.isActive ? AppColors.warning : AppColors.success,
          isDark,
        ),
        _menuItem('delete', Icons.delete_outline_rounded, 'Delete User',
            AppColors.danger, isDark),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
      String value, IconData icon, String label, Color color, bool isDark) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: AppTextStyles.titleSmall(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight)),
        ],
      ),
    );
  }
}

// ─── Shared Confirm Dialog ────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AlertDialog(
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title, style: AppTextStyles.headlineSmall(dark: isDark)),
      content:
          Text(message, style: AppTextStyles.bodyMedium(dark: isDark)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel',
              style: AppTextStyles.labelLarge(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}

// ─── Empty / Error states ─────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 56,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight),
          const SizedBox(height: 12),
          Text('No users found',
              style: AppTextStyles.titleMedium(dark: isDark)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState(
      {required this.message, required this.onRetry, required this.isDark});
  final String message;
  final VoidCallback onRetry;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text('Failed to load users',
                style: AppTextStyles.titleMedium(dark: isDark)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
