import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/health_tip_entity.dart';
import '../providers/admin_provider.dart';

const _categories = [
  'General',
  'Hydration',
  'Sleep',
  'Exercise',
  'Nutrition',
  'Mental Health',
];

class AdminHealthTipsScreen extends ConsumerWidget {
  const AdminHealthTipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tipsAsync = ref.watch(adminHealthTipsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTipForm(context, ref, isDark),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Tip'),
      ),
      body: tipsAsync.when(
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
              Text('Failed to load tips',
                  style: AppTextStyles.titleMedium(dark: isDark)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => ref.invalidate(adminHealthTipsProvider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (tips) => tips.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 56,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight),
                    const SizedBox(height: 12),
                    Text('No health tips yet',
                        style: AppTextStyles.titleMedium(dark: isDark)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showTipForm(context, ref, isDark),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add First Tip'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async =>
                    ref.invalidate(adminHealthTipsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: tips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _TipCard(
                    tip: tips[i],
                    isDark: isDark,
                    onEdit: () =>
                        _showTipForm(context, ref, isDark, tip: tips[i]),
                    onDelete: () => _confirmDelete(context, ref, tips[i]),
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
    );
  }

  Future<void> _showTipForm(
    BuildContext context,
    WidgetRef ref,
    bool isDark, {
    HealthTipEntity? tip,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TipFormSheet(
        tip: tip,
        isDark: isDark,
        onSave: (t) async {
          if (tip == null) {
            await ref.read(adminHealthTipsProvider.notifier).create(t);
          } else {
            await ref.read(adminHealthTipsProvider.notifier).edit(t);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, HealthTipEntity tip) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete Tip',
        message: 'Delete "${tip.title}"? This cannot be undone.',
      ),
    );
    if (ok == true) {
      await ref.read(adminHealthTipsProvider.notifier).delete(tip.id);
    }
  }
}

// ─── Tip Card ─────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.tip,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  final HealthTipEntity tip;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'hydration':
        return AppColors.info;
      case 'sleep':
        return const Color(0xFF8B5CF6);
      case 'exercise':
        return AppColors.success;
      case 'nutrition':
        return AppColors.warning;
      case 'mental health':
        return const Color(0xFFEC4899);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(tip.category);

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
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_rounded, size: 11, color: color),
                    const SizedBox(width: 4),
                    Text(
                      tip.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 17, color: AppColors.primary),
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 17, color: AppColors.danger),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(tip.title,
              style: AppTextStyles.titleSmall(dark: isDark)),
          const SizedBox(height: 6),
          Text(
            tip.description,
            style: AppTextStyles.bodySmall(dark: isDark),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Tip Form Sheet ───────────────────────────────────────────

class _TipFormSheet extends StatefulWidget {
  const _TipFormSheet({
    this.tip,
    required this.isDark,
    required this.onSave,
  });
  final HealthTipEntity? tip;
  final bool isDark;
  final Future<void> Function(HealthTipEntity) onSave;

  @override
  State<_TipFormSheet> createState() => _TipFormSheetState();
}

class _TipFormSheetState extends State<_TipFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late String _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.tip?.title ?? '');
    _description =
        TextEditingController(text: widget.tip?.description ?? '');
    _category = widget.tip?.category ?? _categories.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final tip = HealthTipEntity(
        id: widget.tip?.id ?? '',
        title: _title.text.trim(),
        description: _description.text.trim(),
        category: _category,
        createdAt: widget.tip?.createdAt ?? DateTime.now(),
      );
      await widget.onSave(tip);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Row(
                children: [
                  Text(
                    widget.tip == null ? 'Add Health Tip' : 'Edit Tip',
                    style: AppTextStyles.headlineSmall(dark: isDark),
                  ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Category picker
                    Text(
                      'Category',
                      style: AppTextStyles.labelMedium(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories
                          .map((cat) => _CategoryChip(
                                label: cat,
                                selected: _category == cat,
                                isDark: isDark,
                                onTap: () =>
                                    setState(() => _category = cat),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    _TipField(
                      controller: _title,
                      label: 'Title *',
                      hint: 'e.g. Drink 8 glasses of water daily',
                      isDark: isDark,
                      validator: (v) => v?.trim().isEmpty == true
                          ? 'Title is required'
                          : null,
                    ),
                    // Description
                    _TipField(
                      controller: _description,
                      label: 'Description *',
                      hint:
                          'Explain the health tip in detail…',
                      isDark: isDark,
                      maxLines: 4,
                      validator: (v) => v?.trim().isEmpty == true
                          ? 'Description is required'
                          : null,
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
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : Text('Save',
                                style: AppTextStyles.button(
                                    color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? AppColors.cardSecondaryDark : AppColors.cardSecondaryLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
              color: selected
                  ? Colors.white
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight)),
        ),
      ),
    );
  }
}

class _TipField extends StatelessWidget {
  const _TipField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    this.validator,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelMedium(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            maxLines: maxLines,
            style: AppTextStyles.bodyMedium(dark: isDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight),
              filled: true,
              fillColor: isDark
                  ? AppColors.cardSecondaryDark
                  : AppColors.cardSecondaryLight,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.danger, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confirm dialog ───────────────────────────────────────────

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
