import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/groq_service.dart';
import '../../domain/entities/symptom_analysis.dart';
import '../../domain/repositories/symptom_repository.dart';

class SymptomRepositoryImpl implements SymptomRepository {
  final SupabaseClient _client;

  const SymptomRepositoryImpl(this._client);

  @override
  Future<SymptomAnalysis> analyze({
    required String userId,
    required List<String> symptoms,
    required String duration,
    required int severity,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
  }) async {
    final json = await GroqService.instance.analyzeSymptoms(
      symptoms: symptoms,
      duration: duration,
      severity: severity,
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
    );

    final analysis = SymptomAnalysis.fromAiJson(
      userId: userId,
      symptoms: symptoms,
      duration: duration,
      severity: severity,
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      json: json,
    );

    // Persist to Supabase (best-effort)
    try {
      await saveAnalysis(analysis);
    } catch (e) {
      debugPrint('[HealthAI] Analysis save failed (non-fatal): $e');
    }

    return analysis;
  }

  @override
  Future<void> saveAnalysis(SymptomAnalysis analysis) async {
    await _client.from(SupabaseConstants.symptomAnalysesTable).insert({
      'user_id': analysis.userId,
      'symptoms': analysis.symptoms,
      'duration': analysis.duration,
      'severity': analysis.severity,
      'personal_data': {
        if (analysis.age != null) 'age': analysis.age,
        if (analysis.gender != null) 'gender': analysis.gender,
        if (analysis.heightCm != null) 'height_cm': analysis.heightCm,
        if (analysis.weightKg != null) 'weight_kg': analysis.weightKg,
      },
      'ai_response': {
        'summary': analysis.summary,
        'possible_conditions': analysis.possibleConditions
            .map((c) => {
                  'name': c.name,
                  'confidence': c.confidence,
                  'description': c.description,
                })
            .toList(),
        'recommendations': analysis.recommendations
            .map((r) => {
                  'title': r.title,
                  'description': r.description,
                  'type': r.type,
                })
            .toList(),
        'self_care_advice': analysis.selfCareAdvice,
        'emergency_warnings': analysis.emergencyWarnings,
        'when_to_see_doctor': analysis.whenToSeeDoctor,
        if (analysis.recommendedSpecialty != null)
          'recommended_specialty': analysis.recommendedSpecialty,
        'disclaimer': analysis.disclaimer,
      },
      'risk_level': analysis.riskLevel.name,
    });
  }

  @override
  Future<List<SymptomAnalysis>> getHistory(String userId) async {
    try {
      final rows = await _client
          .from(SupabaseConstants.symptomAnalysesTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return (rows as List<dynamic>)
          .map((r) => _rowToAnalysis(r as Map<String, dynamic>, userId))
          .toList();
    } catch (e) {
      debugPrint('[HealthAI] History fetch failed: $e');
      return [];
    }
  }

  @override
  Future<void> deleteAnalysis(String id) async {
    await _client
        .from(SupabaseConstants.symptomAnalysesTable)
        .delete()
        .eq('id', id);
  }

  SymptomAnalysis _rowToAnalysis(
      Map<String, dynamic> row, String userId) {
    final aiResponse = row['ai_response'] as Map<String, dynamic>? ?? {};
    final conditionsRaw =
        (aiResponse['possible_conditions'] as List<dynamic>?) ?? [];
    final recommendationsRaw =
        (aiResponse['recommendations'] as List<dynamic>?) ?? [];
    final warningsRaw =
        (aiResponse['emergency_warnings'] as List<dynamic>?) ?? [];
    final personalData =
        row['personal_data'] as Map<String, dynamic>? ?? {};
    final symptomsRaw = row['symptoms'] as List<dynamic>? ?? [];

    return SymptomAnalysis(
      id: row['id'] as String?,
      userId: userId,
      symptoms: symptomsRaw.map((s) => s as String).toList(),
      duration: row['duration'] as String?,
      severity: (row['severity'] as num?)?.toInt(),
      age: (personalData['age'] as num?)?.toInt(),
      gender: personalData['gender'] as String?,
      heightCm: (personalData['height_cm'] as num?)?.toDouble(),
      weightKg: (personalData['weight_kg'] as num?)?.toDouble(),
      riskLevel:
          RiskLevelX.fromString(row['risk_level'] as String? ?? 'low'),
      summary: aiResponse['summary'] as String? ?? '',
      possibleConditions: conditionsRaw
          .map((c) =>
              PossibleCondition.fromJson(c as Map<String, dynamic>))
          .toList(),
      recommendations: recommendationsRaw
          .map((r) =>
              AiRecommendation.fromJson(r as Map<String, dynamic>))
          .toList(),
      selfCareAdvice: aiResponse['self_care_advice'] as String? ?? '',
      emergencyWarnings:
          warningsRaw.map((w) => w as String).toList(),
      whenToSeeDoctor:
          aiResponse['when_to_see_doctor'] as String? ?? '',
      recommendedSpecialty:
          aiResponse['recommended_specialty'] as String?,
      disclaimer: aiResponse['disclaimer'] as String? ?? '',
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
