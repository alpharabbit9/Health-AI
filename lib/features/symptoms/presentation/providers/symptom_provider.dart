import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../data/repositories/symptom_repository_impl.dart';
import '../../domain/entities/symptom_analysis.dart';
import '../../domain/repositories/symptom_repository.dart';

// ─── Repository provider ──────────────────────────────────────
final symptomRepositoryProvider = Provider<SymptomRepository>(
  (ref) => SymptomRepositoryImpl(Supabase.instance.client),
);

// ─── Checker form state ───────────────────────────────────────
class CheckerForm {
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final List<String> symptoms;
  final String duration;
  final int severity;
  final int currentStep;

  const CheckerForm({
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.symptoms = const [],
    this.duration = 'Today',
    this.severity = 5,
    this.currentStep = 0,
  });

  CheckerForm copyWith({
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    List<String>? symptoms,
    String? duration,
    int? severity,
    int? currentStep,
  }) =>
      CheckerForm(
        age: age ?? this.age,
        gender: gender ?? this.gender,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        symptoms: symptoms ?? this.symptoms,
        duration: duration ?? this.duration,
        severity: severity ?? this.severity,
        currentStep: currentStep ?? this.currentStep,
      );
}

final checkerFormProvider =
    StateNotifierProvider<CheckerFormNotifier, CheckerForm>((ref) {
  final user = ref.watch(currentUserProvider);
  return CheckerFormNotifier(
    age: user?.age,
    gender: user?.gender,
  );
});

class CheckerFormNotifier extends StateNotifier<CheckerForm> {
  CheckerFormNotifier({int? age, String? gender})
      : super(CheckerForm(age: age, gender: gender));

  void setPersonalData({
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
  }) =>
      state = state.copyWith(
        age: age,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
      );

  void toggleSymptom(String s) {
    final list = List<String>.from(state.symptoms);
    list.contains(s) ? list.remove(s) : list.add(s);
    state = state.copyWith(symptoms: list);
  }

  void addCustomSymptom(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return;
    if (state.symptoms.contains(trimmed)) return;
    state = state.copyWith(symptoms: [...state.symptoms, trimmed]);
  }

  void removeSymptom(String s) {
    state = state.copyWith(
        symptoms: state.symptoms.where((x) => x != s).toList());
  }

  void setDuration(String d) => state = state.copyWith(duration: d);
  void setSeverity(int s) => state = state.copyWith(severity: s);
  void setStep(int s) => state = state.copyWith(currentStep: s);

  // Full reset (clears everything including personal data).
  void reset() => state = const CheckerForm();

  // Fresh-check reset: clears symptoms/duration/severity/step but keeps
  // personal data the user already typed so they don't re-enter it.
  void resetForNewCheck() {
    state = CheckerForm(
      age: state.age,
      gender: state.gender,
      heightCm: state.heightCm,
      weightKg: state.weightKg,
      // ↓ always start fresh
      symptoms: const [],
      duration: 'Today',
      severity: 5,
      currentStep: 0,
    );
  }
}

// ─── Analysis state ───────────────────────────────────────────
sealed class AnalysisState {
  const AnalysisState();
}

class AnalysisIdle extends AnalysisState {
  const AnalysisIdle();
}

class AnalysisLoading extends AnalysisState {
  const AnalysisLoading();
}

class AnalysisSuccess extends AnalysisState {
  final SymptomAnalysis result;
  const AnalysisSuccess(this.result);
}

class AnalysisError extends AnalysisState {
  final String message;
  const AnalysisError(this.message);
}

final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>(
  (ref) => AnalysisNotifier(ref),
);

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final Ref _ref;

  AnalysisNotifier(this._ref) : super(const AnalysisIdle());

  Future<void> analyze() async {
    final form = _ref.read(checkerFormProvider);
    final user = _ref.read(currentUserProvider);

    if (form.symptoms.isEmpty) {
      state = const AnalysisError('Please add at least one symptom.');
      return;
    }

    state = const AnalysisLoading();
    try {
      final result = await _ref.read(symptomRepositoryProvider).analyze(
            userId: user?.id ?? 'anonymous',
            symptoms: form.symptoms,
            duration: form.duration,
            severity: form.severity,
            age: form.age,
            gender: form.gender,
            heightCm: form.heightCm,
            weightKg: form.weightKg,
          );
      state = AnalysisSuccess(result);
      _ref.read(healthRecordsProvider.notifier).addFromAnalysis(result);
    } catch (e) {
      state = AnalysisError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const AnalysisIdle();
}

// ─── History provider ─────────────────────────────────────────
final analysisHistoryProvider =
    FutureProvider<List<SymptomAnalysis>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.read(symptomRepositoryProvider).getHistory(user.id);
});
