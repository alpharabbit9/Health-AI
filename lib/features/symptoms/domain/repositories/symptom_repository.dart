import '../entities/symptom_analysis.dart';

abstract class SymptomRepository {
  Future<SymptomAnalysis> analyze({
    required String userId,
    required List<String> symptoms,
    required String duration,
    required int severity,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
  });

  Future<List<SymptomAnalysis>> getHistory(String userId);
  Future<void> saveAnalysis(SymptomAnalysis analysis);
  Future<void> deleteAnalysis(String id);
}
