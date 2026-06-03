import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/symptom_provider.dart';
import 'ai_result_screen.dart';

class SymptomCheckerScreen extends ConsumerStatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  ConsumerState<SymptomCheckerScreen> createState() =>
      _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState
    extends ConsumerState<SymptomCheckerScreen> {
  final _pageCtrl = PageController();
  static const _totalSteps = 5;

  // Step 1 controllers
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _customSymptomCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final form = ref.read(checkerFormProvider);
    if (form.age != null) _ageCtrl.text = '${form.age}';
    if (form.heightCm != null)
      _heightCtrl.text = form.heightCm!.toStringAsFixed(0);
    if (form.weightKg != null)
      _weightCtrl.text = form.weightKg!.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _customSymptomCtrl.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    _pageCtrl.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
    ref.read(checkerFormProvider.notifier).setStep(step);
  }

  void _next() {
    final current = ref.read(checkerFormProvider).currentStep;
    if (current < _totalSteps - 1) {
      _saveStep1Data();
      _goTo(current + 1);
    }
  }

  void _back() {
    final current = ref.read(checkerFormProvider).currentStep;
    if (current > 0) _goTo(current - 1);
  }

  void _saveStep1Data() {
    ref.read(checkerFormProvider.notifier).setPersonalData(
          age: int.tryParse(_ageCtrl.text),
          heightCm: double.tryParse(_heightCtrl.text),
          weightKg: double.tryParse(_weightCtrl.text),
        );
  }

  Future<void> _submit() async {
    _saveStep1Data();
    await ref.read(analysisProvider.notifier).analyze();
    final state = ref.read(analysisProvider);
    if (state is AnalysisSuccess && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AiResultScreen(analysis: state.result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(checkerFormProvider);
    final analysisState = ref.watch(analysisProvider);
    final isDark = context.isDark;
    final isLoading = analysisState is AnalysisLoading;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────
          _Header(
            step: form.currentStep,
            total: _totalSteps,
            isDark: isDark,
            topPadding: top,
            onBack: form.currentStep == 0
                ? () => Navigator.of(context).pop()
                : _back,
          ),

          // ── Steps ────────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1Personal(
                  ageCtrl: _ageCtrl,
                  heightCtrl: _heightCtrl,
                  weightCtrl: _weightCtrl,
                  selectedGender:
                      ref.watch(checkerFormProvider).gender,
                  onGenderChanged: (g) => ref
                      .read(checkerFormProvider.notifier)
                      .setPersonalData(gender: g),
                  isDark: isDark,
                ),
                _Step2Symptoms(
                  selected: form.symptoms,
                  customCtrl: _customSymptomCtrl,
                  onToggle: ref
                      .read(checkerFormProvider.notifier)
                      .toggleSymptom,
                  onAdd: (s) {
                    ref
                        .read(checkerFormProvider.notifier)
                        .addCustomSymptom(s);
                    _customSymptomCtrl.clear();
                  },
                  onRemove: ref
                      .read(checkerFormProvider.notifier)
                      .removeSymptom,
                  isDark: isDark,
                ),
                _Step3Duration(
                  selected: form.duration,
                  onChanged: ref
                      .read(checkerFormProvider.notifier)
                      .setDuration,
                  isDark: isDark,
                ),
                _Step4Severity(
                  value: form.severity,
                  onChanged: ref
                      .read(checkerFormProvider.notifier)
                      .setSeverity,
                  isDark: isDark,
                ),
                _Step5Review(form: form, isDark: isDark),
              ],
            ),
          ),

          // ── Navigation buttons ───────────────────────────
          _BottomNav(
            step: form.currentStep,
            total: _totalSteps,
            isLoading: isLoading,
            canProceed: form.currentStep != 1 || form.symptoms.isNotEmpty,
            onNext: _next,
            onSubmit: _submit,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ─── Header with progress bar ─────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.step,
    required this.total,
    required this.isDark,
    required this.topPadding,
    required this.onBack,
  });

  final int step;
  final int total;
  final bool isDark;
  final double topPadding;
  final VoidCallback onBack;

  static const _titles = [
    'Personal Info',
    'Your Symptoms',
    'Duration',
    'Severity',
    'Review',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, topPadding + 8, 20, 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(bottom: BorderSide(color: context.dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: context.textPrimary),
                onPressed: onBack,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${step + 1} of $total',
                      style: AppTextStyles.labelSmall(dark: isDark),
                    ),
                    Text(
                      _titles[step],
                      style: AppTextStyles.titleLarge(dark: isDark),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'AI Checker',
                  style: AppTextStyles.labelSmall(
                      color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (step + 1) / total,
              backgroundColor: context.dividerColor,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: Personal info ────────────────────────────────────

class _Step1Personal extends StatelessWidget {
  const _Step1Personal({
    required this.ageCtrl,
    required this.heightCtrl,
    required this.weightCtrl,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.isDark,
  });

  final TextEditingController ageCtrl;
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about yourself',
            style: AppTextStyles.headlineMedium(dark: isDark),
          ),
          const SizedBox(height: 4),
          Text(
            'This helps the AI provide more accurate analysis',
            style: AppTextStyles.bodyMedium(dark: isDark),
          ),
          const SizedBox(height: 28),
          _FormField(
            label: 'Age',
            controller: ageCtrl,
            hint: 'e.g. 28',
            keyboard: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          Text('Gender', style: AppTextStyles.labelMedium(dark: isDark)),
          const SizedBox(height: 10),
          Row(
            children: ['Male', 'Female', 'Other']
                .map(
                  (g) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: g != 'Other' ? 10 : 0),
                      child: _GenderChip(
                        label: g,
                        selected: selectedGender == g,
                        isDark: isDark,
                        onTap: () => onGenderChanged(g),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  label: 'Height (cm)',
                  controller: heightCtrl,
                  hint: '170',
                  keyboard: const TextInputType.numberWithOptions(
                      decimal: true),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _FormField(
                  label: 'Weight (kg)',
                  controller: weightCtrl,
                  hint: '70',
                  keyboard: const TextInputType.numberWithOptions(
                      decimal: true),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'All fields are optional but improve accuracy.',
            style: AppTextStyles.bodySmall(dark: isDark),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Symptoms ─────────────────────────────────────────

const _suggestedSymptoms = [
  'Fever', 'Cough', 'Headache', 'Fatigue',
  'Dizziness', 'Stomach Pain', 'Sore Throat', 'Chest Pain',
  'Shortness of Breath', 'Nausea', 'Body Aches', 'Runny Nose',
  'Vomiting', 'Diarrhoea', 'Loss of Appetite', 'Chills',
];

class _Step2Symptoms extends StatelessWidget {
  const _Step2Symptoms({
    required this.selected,
    required this.customCtrl,
    required this.onToggle,
    required this.onAdd,
    required this.onRemove,
    required this.isDark,
  });

  final List<String> selected;
  final TextEditingController customCtrl;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you experiencing?',
            style: AppTextStyles.headlineMedium(dark: isDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Select all that apply or type your own',
            style: AppTextStyles.bodyMedium(dark: isDark),
          ),
          const SizedBox(height: 20),

          // Custom input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: customCtrl,
                  decoration: InputDecoration(
                    hintText: 'Add a symptom…',
                    prefixIcon: const Icon(Icons.add_circle_outline,
                        color: AppColors.primary),
                  ),
                  onSubmitted: onAdd,
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () => onAdd(customCtrl.text),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(52, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Selected chips
          if (selected.isNotEmpty) ...[
            Text('Selected (${selected.length})',
                style: AppTextStyles.labelMedium(dark: isDark)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selected
                  .map((s) => _SymptomChip(
                        label: s,
                        selected: true,
                        isDark: isDark,
                        onTap: () => onRemove(s),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],

          Text('Common symptoms',
              style: AppTextStyles.labelMedium(dark: isDark)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedSymptoms
                .where((s) => !selected.contains(s))
                .map((s) => _SymptomChip(
                      label: s,
                      selected: false,
                      isDark: isDark,
                      onTap: () => onToggle(s),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Duration ─────────────────────────────────────────

const _durations = [
  ('Today', Icons.wb_sunny_outlined),
  ('1–3 Days', Icons.calendar_today_outlined),
  ('1 Week', Icons.calendar_view_week_outlined),
  ('2 Weeks+', Icons.date_range_outlined),
  ('1 Month+', Icons.event_outlined),
];

class _Step3Duration extends StatelessWidget {
  const _Step3Duration({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  final String selected;
  final ValueChanged<String> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How long have you had these symptoms?',
              style: AppTextStyles.headlineMedium(dark: isDark)),
          const SizedBox(height: 4),
          Text('Select the closest duration',
              style: AppTextStyles.bodyMedium(dark: isDark)),
          const SizedBox(height: 28),
          ..._durations.map(
            (d) => _DurationCard(
              label: d.$1,
              icon: d.$2,
              selected: selected == d.$1,
              isDark: isDark,
              onTap: () => onChanged(d.$1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 4: Severity ─────────────────────────────────────────

class _Step4Severity extends StatelessWidget {
  const _Step4Severity({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final bool isDark;

  String get _label {
    if (value <= 2) return 'Very Mild';
    if (value <= 4) return 'Mild';
    if (value <= 6) return 'Moderate';
    if (value <= 8) return 'Severe';
    return 'Very Severe';
  }

  Color get _color {
    if (value <= 3) return AppColors.success;
    if (value <= 6) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How severe are your symptoms?',
              style: AppTextStyles.headlineMedium(dark: isDark)),
          const SizedBox(height: 4),
          Text('Move the slider to rate your severity',
              style: AppTextStyles.bodyMedium(dark: isDark)),
          const SizedBox(height: 48),

          // Big number display
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _color, width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: _color,
                      height: 1,
                    ),
                  ),
                  Text(
                    '/ 10',
                    style: TextStyle(
                        fontSize: 14,
                        color: _color.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _label,
              style: AppTextStyles.titleLarge(color: _color),
            ),
          ),
          const SizedBox(height: 40),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _color,
              thumbColor: _color,
              inactiveTrackColor: _color.withValues(alpha: 0.2),
              overlayColor: _color.withValues(alpha: 0.1),
              trackHeight: 8,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 — Very Mild',
                  style: AppTextStyles.bodySmall(dark: isDark)),
              Text('10 — Severe',
                  style: AppTextStyles.bodySmall(dark: isDark)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step 5: Review ───────────────────────────────────────────

class _Step5Review extends StatelessWidget {
  const _Step5Review({required this.form, required this.isDark});
  final CheckerForm form;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review & Submit',
              style: AppTextStyles.headlineMedium(dark: isDark)),
          const SizedBox(height: 4),
          Text('Confirm your information before AI analysis',
              style: AppTextStyles.bodyMedium(dark: isDark)),
          const SizedBox(height: 24),

          _ReviewCard(
            title: 'Personal Info',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
            children: [
              if (form.age != null) _ReviewRow('Age', '${form.age} years'),
              if (form.gender != null) _ReviewRow('Gender', form.gender!),
              if (form.heightCm != null)
                _ReviewRow('Height',
                    '${form.heightCm!.toStringAsFixed(0)} cm'),
              if (form.weightKg != null)
                _ReviewRow('Weight',
                    '${form.weightKg!.toStringAsFixed(1)} kg'),
              if (form.age == null && form.gender == null)
                const _ReviewRow('Note', 'No personal data provided'),
            ],
          ),
          const SizedBox(height: 16),

          _ReviewCard(
            title: 'Symptoms (${form.symptoms.length})',
            icon: Icons.sick_outlined,
            isDark: isDark,
            children: form.symptoms.isEmpty
                ? [const _ReviewRow('Note', 'No symptoms added')]
                : form.symptoms
                    .map((s) => _ReviewRow('•', s))
                    .toList(),
          ),
          const SizedBox(height: 16),

          _ReviewCard(
            title: 'Duration & Severity',
            icon: Icons.schedule_outlined,
            isDark: isDark,
            children: [
              _ReviewRow('Duration', form.duration),
              _ReviewRow('Severity', '${form.severity}/10'),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'The AI will analyse your symptoms and provide '
                    'possible conditions and recommendations. '
                    'This is not a medical diagnosis.',
                    style: AppTextStyles.bodySmall(
                        color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom navigation ────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.step,
    required this.total,
    required this.isLoading,
    required this.canProceed,
    required this.onNext,
    required this.onSubmit,
    required this.isDark,
  });

  final int step;
  final int total;
  final bool isLoading;
  final bool canProceed;
  final VoidCallback onNext;
  final VoidCallback onSubmit;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isLast = step == total - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.dividerColor)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton(
          onPressed: (!canProceed || isLoading)
              ? null
              : (isLast ? onSubmit : onNext),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor:
                AppColors.primary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? 'Analyse with AI' : 'Continue',
                      style: AppTextStyles.button(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isLast
                          ? Icons.auto_awesome_rounded
                          : Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Reusable sub-widgets ─────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.isDark,
    this.keyboard = TextInputType.text,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboard;
  final List<TextInputFormatter>? inputFormatters;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium(dark: isDark)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : context.borderColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium(
              color: selected ? Colors.white : null,
              dark: !selected && isDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _SymptomChip extends StatelessWidget {
  const _SymptomChip({
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
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : context.borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.check_rounded,
                    size: 14, color: Colors.white),
              ),
            Text(
              label,
              style: AppTextStyles.labelMedium(
                color: selected ? Colors.white : null,
                dark: !selected && isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  const _DurationCard({
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                selected ? AppColors.primary : context.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: selected
                    ? AppColors.primary
                    : context.textSecondary),
            const SizedBox(width: 14),
            Text(label,
                style: AppTextStyles.titleSmall(
                  color: selected ? AppColors.primary : null,
                  dark: !selected && isDark,
                )),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.children,
  });

  final String title;
  final IconData icon;
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTextStyles.titleSmall(dark: isDark)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: AppTextStyles.bodySmall(dark: isDark)),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.labelMedium(dark: isDark)),
          ),
        ],
      ),
    );
  }
}
