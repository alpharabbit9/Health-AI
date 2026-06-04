import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/doctor_entity.dart';
import '../providers/admin_provider.dart';

class AdminDoctorsScreen extends ConsumerWidget {
  const AdminDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final doctorsAsync = ref.watch(adminDoctorsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDoctorForm(context, ref, isDark),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Doctor'),
      ),
      body: doctorsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.invalidate(adminDoctorsProvider),
          isDark: isDark,
        ),
        data: (doctors) => doctors.isEmpty
            ? _EmptyView(
                onAdd: () => _showDoctorForm(context, ref, isDark),
                isDark: isDark,
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async => ref.invalidate(adminDoctorsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _DoctorCard(
                    doctor: doctors[i],
                    isDark: isDark,
                    onEdit: () =>
                        _showDoctorForm(context, ref, isDark, doctor: doctors[i]),
                    onDelete: () =>
                        _confirmDelete(context, ref, doctors[i]),
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

  Future<void> _showDoctorForm(
    BuildContext context,
    WidgetRef ref,
    bool isDark, {
    DoctorEntity? doctor,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DoctorFormSheet(
        doctor: doctor,
        isDark: isDark,
        onSave: (d) async {
          if (doctor == null) {
            await ref.read(adminDoctorsProvider.notifier).create(d);
          } else {
            await ref.read(adminDoctorsProvider.notifier).edit(d);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, DoctorEntity doctor) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete Doctor',
        message: 'Delete Dr. ${doctor.name}? This cannot be undone.',
      ),
    );
    if (ok == true) {
      await ref.read(adminDoctorsProvider.notifier).delete(doctor.id);
    }
  }
}

// ─── Doctor Card ──────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  final DoctorEntity doctor;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. ${doctor.name}',
                  style: AppTextStyles.titleSmall(dark: isDark),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        doctor.specialization,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (doctor.hospital != null) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          doctor.hospital!,
                          style: AppTextStyles.bodySmall(dark: isDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                if (doctor.availability != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        doctor.availability!,
                        style: AppTextStyles.bodySmall(dark: isDark),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.primary),
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.danger),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Doctor Form Bottom Sheet ─────────────────────────────────

class _DoctorFormSheet extends StatefulWidget {
  const _DoctorFormSheet({
    this.doctor,
    required this.isDark,
    required this.onSave,
  });
  final DoctorEntity? doctor;
  final bool isDark;
  final Future<void> Function(DoctorEntity) onSave;

  @override
  State<_DoctorFormSheet> createState() => _DoctorFormSheetState();
}

class _DoctorFormSheetState extends State<_DoctorFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _spec;
  late final TextEditingController _hospital;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _availability;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.doctor;
    _name = TextEditingController(text: d?.name ?? '');
    _spec = TextEditingController(text: d?.specialization ?? '');
    _hospital = TextEditingController(text: d?.hospital ?? '');
    _phone = TextEditingController(text: d?.phone ?? '');
    _email = TextEditingController(text: d?.email ?? '');
    _address = TextEditingController(text: d?.address ?? '');
    _availability = TextEditingController(text: d?.availability ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _spec.dispose();
    _hospital.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _availability.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final doctor = DoctorEntity(
        id: widget.doctor?.id ?? '',
        name: _name.text.trim(),
        specialization: _spec.text.trim(),
        hospital: _hospital.text.trim().isEmpty ? null : _hospital.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        availability: _availability.text.trim().isEmpty
            ? null
            : _availability.text.trim(),
        createdAt: widget.doctor?.createdAt ?? DateTime.now(),
      );
      await widget.onSave(doctor);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
          ),
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
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Row(
                children: [
                  Text(
                    widget.doctor == null ? 'Add Doctor' : 'Edit Doctor',
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
                    _FormField(
                        controller: _name,
                        label: 'Full Name *',
                        hint: 'e.g. Ahmed Hassan',
                        isDark: isDark,
                        validator: (v) =>
                            v?.trim().isEmpty == true ? 'Name is required' : null),
                    _FormField(
                        controller: _spec,
                        label: 'Specialization *',
                        hint: 'e.g. Cardiologist',
                        isDark: isDark,
                        validator: (v) => v?.trim().isEmpty == true
                            ? 'Specialization is required'
                            : null),
                    _FormField(
                        controller: _hospital,
                        label: 'Hospital',
                        hint: 'e.g. City General Hospital',
                        isDark: isDark),
                    _FormField(
                        controller: _phone,
                        label: 'Phone',
                        hint: '+1 234 567 8900',
                        isDark: isDark,
                        keyboardType: TextInputType.phone),
                    _FormField(
                        controller: _email,
                        label: 'Email',
                        hint: 'doctor@hospital.com',
                        isDark: isDark,
                        keyboardType: TextInputType.emailAddress),
                    _FormField(
                        controller: _address,
                        label: 'Address',
                        hint: '123 Medical St.',
                        isDark: isDark,
                        maxLines: 2),
                    _FormField(
                        controller: _availability,
                        label: 'Availability',
                        hint: 'Mon–Fri, 9am–5pm',
                        isDark: isDark),
                    const SizedBox(height: 24),
                    _SaveButton(saving: _saving, onSave: _save),
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

// ─── Shared form helpers ──────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
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
            keyboardType: keyboardType,
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

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saving, required this.onSave});
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: saving ? null : onSave,
        child: saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text('Save', style: AppTextStyles.button(color: Colors.white)),
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

// ─── Empty / Error views ──────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onAdd, required this.isDark});
  final VoidCallback onAdd;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services_outlined,
              size: 56,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight),
          const SizedBox(height: 12),
          Text('No doctors added yet',
              style: AppTextStyles.titleMedium(dark: isDark)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add First Doctor'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry, required this.isDark});
  final VoidCallback onRetry;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.danger),
          const SizedBox(height: 12),
          Text('Failed to load doctors',
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
    );
  }
}
