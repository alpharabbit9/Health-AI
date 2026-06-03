import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../symptoms/data/repositories/symptom_repository_impl.dart';
import '../../../symptoms/domain/entities/symptom_analysis.dart' as sa;
import '../../domain/entities/health_record.dart';

final healthRecordsProvider =
    StateNotifierProvider<HealthRecordsNotifier, List<HealthRecord>>(
  (ref) {
    final notifier = HealthRecordsNotifier();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      Future.microtask(() => notifier.loadFromSupabase(user.id));
    }
    return notifier;
  },
);

class HealthRecordsNotifier extends StateNotifier<List<HealthRecord>> {
  HealthRecordsNotifier() : super(const []);

  Future<void> loadFromSupabase(String userId) async {
    try {
      final repo = SymptomRepositoryImpl(Supabase.instance.client);
      final analyses = await repo.getHistory(userId);
      if (mounted) {
        state = analyses.map(_fromAnalysis).toList();
      }
    } catch (e) {
      debugPrint('[HealthAI] History load failed: $e');
    }
  }

  void addFromAnalysis(sa.SymptomAnalysis analysis) {
    addRecord(_fromAnalysis(analysis));
  }

  void addRecord(HealthRecord record) => state = [record, ...state];

  void deleteRecord(String id) =>
      state = state.where((r) => r.id != id).toList();
}

HealthRecord _fromAnalysis(sa.SymptomAnalysis a) {
  final RiskLevel risk;
  switch (a.riskLevel) {
    case sa.RiskLevel.low:
      risk = RiskLevel.low;
    case sa.RiskLevel.moderate:
      risk = RiskLevel.medium;
    case sa.RiskLevel.high:
      risk = RiskLevel.high;
  }
  return HealthRecord(
    id: a.id ?? '${a.userId}_${a.createdAt.millisecondsSinceEpoch}',
    date: a.createdAt,
    symptoms: a.symptoms,
    riskLevel: risk,
    possibleConditions: a.possibleConditions.isNotEmpty
        ? a.possibleConditions.map((c) => c.name).join(', ')
        : null,
    aiRecommendations: a.selfCareAdvice.isNotEmpty
        ? a.selfCareAdvice
        : a.recommendations.isNotEmpty
            ? a.recommendations.map((r) => r.description).join(' ')
            : null,
  );
}
