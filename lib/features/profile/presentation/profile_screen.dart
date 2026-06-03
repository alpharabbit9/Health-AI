import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/entities/health_profile.dart';
import 'providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadAvatar() async {
    final isDark = context.isDark;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SourcePickerSheet(isDark: isDark),
    );
    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last.toLowerCase();

    setState(() => _isUploading = true);
    try {
      await ref.read(healthProfileProvider.notifier).uploadAvatar(bytes, ext);
      if (mounted) context.showSuccessSnack('Profile picture updated');
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        context.showErrorSnack(
          msg.length > 100 ? 'Upload failed — check debug console' : msg,
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(healthProfileProvider);
    final isDark = context.isDark;
    final top = MediaQuery.of(context).padding.top;

    if (profile == null) {
      return Scaffold(
        backgroundColor: context.bgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient header ──────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(
              profile: profile,
              isDark: isDark,
              topPadding: top,
              isUploading: _isUploading,
              onAvatarTap: _pickAndUploadAvatar,
              onEdit: () => _showEditSheet(context, ref, profile),
              onSettings: () => context.push(AppRoutes.settings),
            ),
          ),

          // ── Stats row ────────────────────────────────────
          SliverToBoxAdapter(
            child: _StatsRow(profile: profile, isDark: isDark),
          ),

          // ── Personal info ────────────────────────────────
          SliverToBoxAdapter(
            child: _InfoSection(
              title: 'Personal Information',
              icon: Icons.person_outline_rounded,
              isDark: isDark,
              rows: [
                _InfoRow(
                    label: 'Full Name',
                    value: profile.fullName.isEmpty
                        ? '—'
                        : profile.fullName),
                _InfoRow(label: 'Email', value: profile.email),
                _InfoRow(
                    label: 'Phone',
                    value: profile.phone ?? '—'),
              ],
            ),
          ),

          // ── Health info ───────────────────────────────────
          SliverToBoxAdapter(
            child: _InfoSection(
              title: 'Health Information',
              icon: Icons.favorite_outline_rounded,
              isDark: isDark,
              rows: [
                _InfoRow(
                    label: 'Age',
                    value: profile.age != null
                        ? '${profile.age} years'
                        : '—'),
                _InfoRow(
                    label: 'Gender',
                    value: profile.gender ?? '—'),
                _InfoRow(
                    label: 'Height',
                    value: profile.heightCm != null
                        ? '${profile.heightCm!.toStringAsFixed(0)} cm'
                        : '—'),
                _InfoRow(
                    label: 'Weight',
                    value: profile.weightKg != null
                        ? '${profile.weightKg!.toStringAsFixed(1)} kg'
                        : '—'),
                _InfoRow(
                    label: 'Blood Group',
                    value: profile.bloodGroup ?? '—'),
                if (profile.bmi != null)
                  _InfoRow(
                    label: 'BMI',
                    value:
                        '${profile.bmi!.toStringAsFixed(1)} · ${profile.bmiCategory}',
                  ),
              ],
            ),
          ),

          // ── Medical history ───────────────────────────────
          SliverToBoxAdapter(
            child: _MedicalSection(
                profile: profile, isDark: isDark),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 100 + MediaQuery.of(context).padding.bottom,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(
    BuildContext context,
    WidgetRef ref,
    HealthProfile profile,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(profile: profile, ref: ref),
    );
  }
}

// ─── Source picker bottom sheet ───────────────────────────────

class _SourcePickerSheet extends StatelessWidget {
  const _SourcePickerSheet({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
              child: Text(
                'Change Profile Photo',
                style: AppTextStyles.titleLarge(dark: isDark),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.primary),
              ),
              title: Text('Camera',
                  style: AppTextStyles.titleSmall(dark: isDark)),
              subtitle: Text('Take a new photo',
                  style: AppTextStyles.bodySmall(dark: isDark)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_rounded,
                    color: AppColors.info),
              ),
              title: Text('Photo Library',
                  style: AppTextStyles.titleSmall(dark: isDark)),
              subtitle: Text('Choose from your gallery',
                  style: AppTextStyles.bodySmall(dark: isDark)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Profile header ───────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.isDark,
    required this.topPadding,
    required this.isUploading,
    required this.onAvatarTap,
    required this.onEdit,
    required this.onSettings,
  });

  final HealthProfile profile;
  final bool isDark;
  final double topPadding;
  final bool isUploading;
  final VoidCallback onAvatarTap;
  final VoidCallback onEdit;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(profile.fullName);
    return Container(
      padding: EdgeInsets.fromLTRB(24, topPadding + 16, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Profile',
                style: AppTextStyles.titleLarge(color: Colors.white),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: onEdit,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Edit',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.white, size: 22),
                    onPressed: onSettings,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Avatar with camera badge ────────────────────
          GestureDetector(
            onTap: isUploading ? null : onAvatarTap,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                // Avatar circle
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(child: _avatarContent(initials)),
                ),
                // Camera badge
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: isUploading
                      ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Icons.camera_alt_rounded,
                          size: 15, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            profile.fullName.isEmpty ? 'HealthAI User' : profile.fullName,
            style: AppTextStyles.headlineSmall(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: AppTextStyles.bodySmall(
                color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 16),
          _CompletionBar(percent: profile.completenessPercent),
        ],
      ),
    );
  }

  Widget _avatarContent(String initials) {
    if (isUploading) {
      return Container(
        color: Colors.white.withValues(alpha: 0.2),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
      );
    }
    final url = profile.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: 92,
        height: 92,
        errorBuilder: (_, __, ___) => _initialsPlaceholder(initials),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.white.withValues(alpha: 0.2),
            child: const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
          );
        },
      );
    }
    return _initialsPlaceholder(initials);
  }

  Widget _initialsPlaceholder(String initials) {
    return Container(
      color: Colors.white.withValues(alpha: 0.25),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.headlineLarge(color: Colors.white),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.isEmpty) return 'H';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _CompletionBar extends StatelessWidget {
  const _CompletionBar({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Profile completeness',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile, required this.isDark});
  final HealthProfile profile;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bmiText = profile.bmi != null
        ? profile.bmi!.toStringAsFixed(1)
        : '—';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          _StatChip(
            label: 'BMI',
            value: bmiText,
            icon: Icons.monitor_weight_outlined,
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Blood Group',
            value: profile.bloodGroup ?? '—',
            icon: Icons.bloodtype_outlined,
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Age',
            value: profile.age != null ? '${profile.age}' : '—',
            icon: Icons.cake_outlined,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.titleSmall(dark: isDark),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall(dark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Info sections ────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final bool isDark;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTextStyles.titleLarge(dark: isDark)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              children: rows
                  .asMap()
                  .entries
                  .map(
                    (e) => Column(
                      children: [
                        e.value._buildTile(isDark, context),
                        if (e.key < rows.length - 1)
                          Divider(
                            height: 1,
                            indent: 16,
                            color: context.dividerColor,
                          ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  Widget _buildTile(bool isDark, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium(dark: isDark),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.titleSmall(dark: isDark),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Medical section (chips) ──────────────────────────────────

class _MedicalSection extends StatelessWidget {
  const _MedicalSection(
      {required this.profile, required this.isDark});
  final HealthProfile profile;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_information_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Medical History',
                  style:
                      AppTextStyles.titleLarge(dark: isDark)),
            ],
          ),
          const SizedBox(height: 12),
          _ChipGroup(
            title: 'Allergies',
            items: profile.allergies,
            emptyLabel: 'No allergies recorded',
            isDark: isDark,
            color: AppColors.danger,
          ),
          const SizedBox(height: 14),
          _ChipGroup(
            title: 'Chronic Conditions',
            items: profile.chronicConditions,
            emptyLabel: 'No conditions recorded',
            isDark: isDark,
            color: AppColors.warning,
          ),
          const SizedBox(height: 14),
          _ChipGroup(
            title: 'Current Medications',
            items: profile.currentMedications,
            emptyLabel: 'No medications recorded',
            isDark: isDark,
            color: AppColors.info,
          ),
        ],
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({
    required this.title,
    required this.items,
    required this.emptyLabel,
    required this.isDark,
    required this.color,
  });

  final String title;
  final List<String> items;
  final String emptyLabel;
  final bool isDark;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTextStyles.labelMedium(dark: isDark)),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(emptyLabel,
                style:
                    AppTextStyles.bodySmall(dark: isDark))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                color.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

// ─── Edit profile sheet ───────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet(
      {required this.profile, required this.ref});
  final HealthProfile profile;
  final WidgetRef ref;

  @override
  State<_EditProfileSheet> createState() =>
      _EditProfileSheetState();
}

class _EditProfileSheetState
    extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _allergiesCtrl;
  late final TextEditingController _conditionsCtrl;
  late final TextEditingController _medsCtrl;

  String? _selectedGender;
  String? _selectedBloodGroup;
  bool _loading = false;

  static const _bloodGroups = [
    'A+', 'A−', 'B+', 'B−', 'AB+', 'AB−', 'O+', 'O−'
  ];
  static const _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameCtrl = TextEditingController(text: p.fullName);
    _phoneCtrl = TextEditingController(text: p.phone ?? '');
    _ageCtrl = TextEditingController(
        text: p.age != null ? '${p.age}' : '');
    _heightCtrl = TextEditingController(
        text: p.heightCm != null
            ? p.heightCm!.toStringAsFixed(0)
            : '');
    _weightCtrl = TextEditingController(
        text: p.weightKg != null
            ? p.weightKg!.toStringAsFixed(1)
            : '');
    _allergiesCtrl = TextEditingController(
        text: p.allergies.join(', '));
    _conditionsCtrl = TextEditingController(
        text: p.chronicConditions.join(', '));
    _medsCtrl = TextEditingController(
        text: p.currentMedications.join(', '));
    _selectedGender = p.gender;
    _selectedBloodGroup = p.bloodGroup;
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _phoneCtrl, _ageCtrl, _heightCtrl,
      _weightCtrl, _allergiesCtrl, _conditionsCtrl, _medsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottom),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Profile',
                    style: AppTextStyles.headlineSmall(
                        dark: isDark)),
                TextButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2))
                      : Text('Save',
                          style: AppTextStyles.labelLarge(
                              color: AppColors.primary)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label('Full Name', isDark),
                  TextField(controller: _nameCtrl,
                      textCapitalization:
                          TextCapitalization.words),
                  const SizedBox(height: 16),

                  _Label('Phone', isDark),
                  TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),

                  _Label('Age', isDark),
                  TextField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ]),
                  const SizedBox(height: 16),

                  _Label('Gender', isDark),
                  _DropdownField<String>(
                    value: _selectedGender,
                    items: _genders,
                    hint: 'Select gender',
                    onChanged: (v) =>
                        setState(() => _selectedGender = v),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _Label('Height (cm)', isDark),
                            TextField(
                              controller: _heightCtrl,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                          decimal: true),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _Label('Weight (kg)', isDark),
                            TextField(
                              controller: _weightCtrl,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                          decimal: true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _Label('Blood Group', isDark),
                  _DropdownField<String>(
                    value: _selectedBloodGroup,
                    items: _bloodGroups,
                    hint: 'Select blood group',
                    onChanged: (v) => setState(
                        () => _selectedBloodGroup = v),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  _Label('Allergies', isDark),
                  _HintField(
                    controller: _allergiesCtrl,
                    hint: 'e.g. Peanuts, Shellfish',
                  ),
                  const SizedBox(height: 16),

                  _Label('Chronic Conditions', isDark),
                  _HintField(
                    controller: _conditionsCtrl,
                    hint: 'e.g. Diabetes, Hypertension',
                  ),
                  const SizedBox(height: 16),

                  _Label('Current Medications', isDark),
                  _HintField(
                    controller: _medsCtrl,
                    hint: 'e.g. Metformin, Lisinopril',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _parseList(String text) => text
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final updated = widget.profile.copyWith(
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty
            ? null
            : _phoneCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text.trim()),
        gender: _selectedGender,
        heightCm: double.tryParse(_heightCtrl.text.trim()),
        weightKg: double.tryParse(_weightCtrl.text.trim()),
        bloodGroup: _selectedBloodGroup,
        allergies: _parseList(_allergiesCtrl.text),
        chronicConditions: _parseList(_conditionsCtrl.text),
        currentMedications: _parseList(_medsCtrl.text),
      );
      await widget.ref
          .read(healthProfileProvider.notifier)
          .updateProfile(updated);
      if (mounted) {
        Navigator.of(context).pop();
        context.showSuccessSnack('Profile updated');
      }
    } catch (e) {
      if (mounted) {
        final msg = e is PostgrestException
            ? 'DB error: ${e.message}'
            : e.toString().replaceFirst('Exception: ', '');
        context.showErrorSnack(
          msg.length > 100 ? 'Save failed — check debug console' : msg,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.isDark);
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTextStyles.labelMedium(dark: isDark),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    required this.isDark,
  });

  final T? value;
  final List<T> items;
  final String hint;
  final ValueChanged<T?> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(contentPadding: EdgeInsets.zero),
      child: DropdownButton<T>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e.toString()),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _HintField extends StatelessWidget {
  const _HintField(
      {required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hint),
      maxLines: 2,
      minLines: 1,
    );
  }
}
