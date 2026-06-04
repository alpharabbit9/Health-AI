import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/feedback_entity.dart';
import '../providers/admin_provider.dart';

class AdminFeedbackScreen extends ConsumerWidget {
  const AdminFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final feedbackAsync = ref.watch(adminFeedbackProvider);

    return feedbackAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text('Failed to load feedback',
                style: AppTextStyles.titleMedium(dark: isDark)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => ref.invalidate(adminFeedbackProvider),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feedback_outlined,
                    size: 56,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight),
                const SizedBox(height: 12),
                Text('No feedback yet',
                    style: AppTextStyles.titleMedium(dark: isDark)),
              ],
            ),
          );
        }

        final pending =
            items.where((f) => f.status == 'pending').toList();
        final resolved =
            items.where((f) => f.status == 'resolved').toList();

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(adminFeedbackProvider),
          child: CustomScrollView(
            slivers: [
              // Summary chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      _CountChip(
                          label: 'All',
                          count: items.length,
                          color: AppColors.info,
                          isDark: isDark),
                      const SizedBox(width: 10),
                      _CountChip(
                          label: 'Pending',
                          count: pending.length,
                          color: AppColors.warning,
                          isDark: isDark),
                      const SizedBox(width: 10),
                      _CountChip(
                          label: 'Resolved',
                          count: resolved.length,
                          color: AppColors.success,
                          isDark: isDark),
                    ],
                  ),
                ),
              ),

              if (pending.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text('Pending',
                        style: AppTextStyles.titleMedium(dark: isDark)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _FeedbackCard(
                          feedback: pending[i],
                          isDark: isDark,
                          onResolve: () => ref
                              .read(adminFeedbackProvider.notifier)
                              .markResolved(pending[i].id),
                          onDelete: () => _confirmDelete(
                              context, ref, pending[i]),
                        )
                            .animate(delay: (i * 40).ms)
                            .fadeIn(duration: 300.ms),
                      ),
                      childCount: pending.length,
                    ),
                  ),
                ),
              ],

              if (resolved.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('Resolved',
                        style: AppTextStyles.titleMedium(dark: isDark)),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _FeedbackCard(
                          feedback: resolved[i],
                          isDark: isDark,
                          onResolve: null,
                          onDelete: () => _confirmDelete(
                              context, ref, resolved[i]),
                        )
                            .animate(delay: (i * 30).ms)
                            .fadeIn(duration: 300.ms),
                      ),
                      childCount: resolved.length,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, FeedbackEntity item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmDialog(
        title: 'Delete Feedback',
        message: 'Delete this feedback? This cannot be undone.',
      ),
    );
    if (ok == true) {
      await ref.read(adminFeedbackProvider.notifier).delete(item.id);
    }
  }
}

// ─── Count Chip ───────────────────────────────────────────────

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isDark,
  });
  final String label;
  final int count;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: AppTextStyles.titleSmall(color: color),
          ),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.bodySmall(color: color)),
        ],
      ),
    );
  }
}

// ─── Feedback Card ────────────────────────────────────────────

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.feedback,
    required this.isDark,
    required this.onResolve,
    required this.onDelete,
  });

  final FeedbackEntity feedback;
  final bool isDark;
  final VoidCallback? onResolve;
  final VoidCallback onDelete;

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'bug':
        return AppColors.danger;
      case 'suggestion':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bug':
        return Icons.bug_report_outlined;
      case 'suggestion':
        return Icons.lightbulb_outline_rounded;
      default:
        return Icons.feedback_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(feedback.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: feedback.isResolved
              ? (isDark ? AppColors.borderDark : AppColors.borderLight)
              : typeColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_typeIcon(feedback.type),
                        size: 11, color: typeColor),
                    const SizedBox(width: 4),
                    Text(
                      feedback.type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (feedback.isResolved)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'RESOLVED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
              const Spacer(),
              if (onResolve != null)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline_rounded,
                      size: 18, color: AppColors.success),
                  onPressed: onResolve,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  tooltip: 'Mark resolved',
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.danger),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                tooltip: 'Delete',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(feedback.title,
              style: AppTextStyles.titleSmall(dark: isDark)),
          const SizedBox(height: 6),
          Text(
            feedback.message,
            style: AppTextStyles.bodySmall(dark: isDark),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  size: 13,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight),
              const SizedBox(width: 4),
              Text(
                feedback.userName ?? 'Anonymous',
                style: AppTextStyles.bodySmall(dark: isDark),
              ),
              const Spacer(),
              Icon(Icons.access_time_rounded,
                  size: 12,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM yyyy').format(feedback.createdAt),
                style: AppTextStyles.bodySmall(dark: isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Confirm Dialog ───────────────────────────────────────────

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
      content: Text(message, style: AppTextStyles.bodyMedium(dark: isDark)),
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
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// User-facing feedback submission widget (can be embedded in
// ProfileScreen / SettingsScreen)
// ──────────────────────────────────────────────────────────────

class FeedbackSubmitSheet extends ConsumerStatefulWidget {
  const FeedbackSubmitSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FeedbackSubmitSheet(),
    );
  }

  @override
  ConsumerState<FeedbackSubmitSheet> createState() =>
      _FeedbackSubmitSheetState();
}

class _FeedbackSubmitSheetState extends ConsumerState<FeedbackSubmitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _type = 'feedback';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await ref.read(submitFeedbackProvider.notifier).submit(
          title: _titleCtrl.text.trim(),
          message: _messageCtrl.text.trim(),
          type: _type,
        );
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Thank you for your feedback!'
              : 'Failed to submit. Please try again.'),
          backgroundColor: ok ? AppColors.success : AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading =
        ref.watch(submitFeedbackProvider).isLoading;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  Text('Send Feedback',
                      style: AppTextStyles.headlineSmall(dark: isDark)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  children: [
                    // Type selector
                    Text('Type',
                        style: AppTextStyles.labelMedium(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _TypeChip(
                            label: 'Feedback',
                            value: 'feedback',
                            selected: _type == 'feedback',
                            icon: Icons.feedback_outlined,
                            isDark: isDark,
                            onTap: () => setState(() => _type = 'feedback')),
                        const SizedBox(width: 8),
                        _TypeChip(
                            label: 'Suggestion',
                            value: 'suggestion',
                            selected: _type == 'suggestion',
                            icon: Icons.lightbulb_outline_rounded,
                            isDark: isDark,
                            onTap: () =>
                                setState(() => _type = 'suggestion')),
                        const SizedBox(width: 8),
                        _TypeChip(
                            label: 'Bug',
                            value: 'bug',
                            selected: _type == 'bug',
                            icon: Icons.bug_report_outlined,
                            isDark: isDark,
                            onTap: () => setState(() => _type = 'bug')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Title
                    Text('Title *',
                        style: AppTextStyles.labelMedium(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleCtrl,
                      style: AppTextStyles.bodyMedium(dark: isDark),
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Title required' : null,
                      decoration: _inputDec(
                          'Brief summary', isDark),
                    ),
                    const SizedBox(height: 16),
                    // Message
                    Text('Message *',
                        style: AppTextStyles.labelMedium(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _messageCtrl,
                      maxLines: 4,
                      style: AppTextStyles.bodyMedium(dark: isDark),
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Message required' : null,
                      decoration: _inputDec(
                          'Describe in detail…', isDark),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text('Submit Feedback',
                                style: AppTextStyles.button(
                                    color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint, bool isDark) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium(
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight),
        filled: true,
        fillColor: isDark
            ? AppColors.cardSecondaryDark
            : AppColors.cardSecondaryLight,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 1),
        ),
      );
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });
  final String label;
  final String value;
  final bool selected;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : (isDark
                    ? AppColors.cardSecondaryDark
                    : AppColors.cardSecondaryLight),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight),
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color: selected
                      ? Colors.white
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
