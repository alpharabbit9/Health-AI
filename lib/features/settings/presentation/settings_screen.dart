import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: context.bgColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            floating: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: context.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Settings',
                style: AppTextStyles.titleLarge(dark: isDark)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Appearance ──────────────────────────────
                  _SectionHeader(title: '🎨  Appearance', isDark: isDark),
                  _SettingsCard(
                    isDark: isDark,
                    child: _ThemeSelector(
                      current: themeMode,
                      isDark: isDark,
                      onChanged: ref.read(themeModeProvider.notifier).setTheme,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Notifications ────────────────────────────
                  _SectionHeader(
                      title: '🔔  Notifications', isDark: isDark),
                  _SettingsCard(
                    isDark: isDark,
                    child: Column(
                      children: [
                        _ToggleTile(
                          title: 'Enable Notifications',
                          subtitle:
                              'Receive health alerts and reminders',
                          value: settings.notificationsEnabled,
                          isDark: isDark,
                          onChanged: ref
                              .read(appSettingsProvider.notifier)
                              .setNotifications,
                        ),
                        _Divider(isDark: isDark),
                        _ToggleTile(
                          title: 'Medication Reminders',
                          subtitle: 'Get reminded to take medications',
                          value: settings.medicationReminders,
                          isDark: isDark,
                          enabled: settings.notificationsEnabled,
                          onChanged: ref
                              .read(appSettingsProvider.notifier)
                              .setMedicationReminders,
                        ),
                        _Divider(isDark: isDark),
                        _ToggleTile(
                          title: 'Daily Health Tips',
                          subtitle: 'Tips for a healthier lifestyle',
                          value: settings.healthTipsEnabled,
                          isDark: isDark,
                          enabled: settings.notificationsEnabled,
                          onChanged: ref
                              .read(appSettingsProvider.notifier)
                              .setHealthTips,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Privacy & Security ───────────────────────
                  _SectionHeader(
                      title: '🔒  Privacy & Security',
                      isDark: isDark),
                  _SettingsCard(
                    isDark: isDark,
                    child: Column(
                      children: [
                        _ActionTile(
                          title: 'Change Password',
                          icon: Icons.lock_outline_rounded,
                          isDark: isDark,
                          onTap: () =>
                              _showChangePassword(context),
                        ),
                        _Divider(isDark: isDark),
                        _ToggleTile(
                          title: 'Biometric Login',
                          subtitle: 'Use fingerprint or Face ID',
                          value: settings.biometricLogin,
                          isDark: isDark,
                          onChanged: (_) => context.showInfoSnack(
                              'Biometric login coming in Part 2'),
                        ),
                        _Divider(isDark: isDark),
                        _ActionTile(
                          title: 'Delete Account',
                          icon: Icons.delete_outline_rounded,
                          isDark: isDark,
                          titleColor: AppColors.danger,
                          iconColor: AppColors.danger,
                          onTap: () => _showDeleteAccount(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Language ─────────────────────────────────
                  _SectionHeader(title: '🌐  Language', isDark: isDark),
                  _SettingsCard(
                    isDark: isDark,
                    child: _ActionTile(
                      title: 'English',
                      icon: Icons.translate_rounded,
                      isDark: isDark,
                      trailing: Text(
                        settings.language,
                        style: AppTextStyles.bodySmall(dark: isDark),
                      ),
                      onTap: () => context
                          .showInfoSnack('More languages coming soon'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── About ─────────────────────────────────────
                  _SectionHeader(title: 'ℹ️  About', isDark: isDark),
                  _SettingsCard(
                    isDark: isDark,
                    child: Column(
                      children: [
                        _InfoTile(
                            title: 'Version',
                            value: '1.0.0',
                            isDark: isDark),
                        _Divider(isDark: isDark),
                        _ActionTile(
                          title: 'Privacy Policy',
                          icon: Icons.privacy_tip_outlined,
                          isDark: isDark,
                          onTap: () => context
                              .showInfoSnack('Opening privacy policy…'),
                        ),
                        _Divider(isDark: isDark),
                        _ActionTile(
                          title: 'Terms of Service',
                          icon: Icons.article_outlined,
                          isDark: isDark,
                          onTap: () => context.showInfoSnack(
                              'Opening terms of service…'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Sign out ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _confirmSignOut(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(
                            color: AppColors.danger),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded,
                          size: 18),
                      label: Text(
                        'Sign Out',
                        style: AppTextStyles.button(
                            color: AppColors.danger),
                      ),
                    ),
                  ),

                  SizedBox(
                    height:
                        40 + MediaQuery.of(context).padding.bottom,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _showDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account'),
        content: const Text(
          'To delete your account and all associated data, please '
          'contact us at support@healthai.app. Your data will be '
          'permanently removed within 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content:
            const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).signOut();
            },
            style: TextButton.styleFrom(
                foregroundColor: AppColors.danger),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ─── Change password sheet ─────────────────────────────────────

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState
    extends State<_ChangePasswordSheet> {
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Change Password',
              style: AppTextStyles.headlineSmall(dark: isDark)),
          const SizedBox(height: 20),
          _PasswordField(
            controller: _newCtrl,
            label: 'New Password',
            obscure: _obscureNew,
            onToggle: () =>
                setState(() => _obscureNew = !_obscureNew),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _PasswordField(
            controller: _confirmCtrl,
            label: 'Confirm New Password',
            obscure: _obscureConfirm,
            onToggle: () => setState(
                () => _obscureConfirm = !_obscureConfirm),
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Update Password',
                      style:
                          AppTextStyles.button(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final newPw = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    if (newPw.isEmpty || newPw.length < 8) {
      context.showErrorSnack(
          'Password must be at least 8 characters');
      return;
    }
    if (newPw != confirm) {
      context.showErrorSnack('Passwords do not match');
      return;
    }
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth
          .updateUser(UserAttributes(password: newPw));
      if (mounted) {
        Navigator.of(context).pop();
        context.showSuccessSnack('Password updated successfully');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnack('Failed to update password');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    required this.isDark,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

// ─── Reusable sub-widgets ─────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.isDark});
  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: AppTextStyles.titleSmall(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child, required this.isDark});
  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor),
      ),
      child: child,
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.current,
    required this.isDark,
    required this.onChanged,
  });

  final ThemeMode current;
  final bool isDark;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _ThemeOption(
            label: 'Light',
            icon: Icons.wb_sunny_rounded,
            selected: current == ThemeMode.light,
            isDark: isDark,
            onTap: () => onChanged(ThemeMode.light),
          ),
          const SizedBox(width: 8),
          _ThemeOption(
            label: 'Dark',
            icon: Icons.nightlight_round,
            selected: current == ThemeMode.dark,
            isDark: isDark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
          const SizedBox(width: 8),
          _ThemeOption(
            label: 'System',
            icon: Icons.settings_suggest_outlined,
            selected: current == ThemeMode.system,
            isDark: isDark,
            onTap: () => onChanged(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? AppColors.primary
                    : context.textTertiary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: selected
                      ? AppColors.primary
                      : context.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final bool value;
  final bool isDark;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.titleSmall(dark: isDark)
                        .copyWith(
                      color: enabled
                          ? null
                          : context.textTertiary,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.bodySmall(dark: isDark)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.trailing,
    this.titleColor,
    this.iconColor,
  });

  final String title;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? titleColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? context.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleSmall(
                  color: titleColor,
                  dark: isDark,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: context.textTertiary,
                ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
    required this.isDark,
  });

  final String title;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: AppTextStyles.titleSmall(dark: isDark)),
          ),
          Text(value,
              style: AppTextStyles.bodySmall(dark: isDark)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 50,
      color: context.dividerColor,
    );
  }
}
