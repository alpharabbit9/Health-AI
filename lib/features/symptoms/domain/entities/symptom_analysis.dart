import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum RiskLevel { low, moderate, high }

extension RiskLevelX on RiskLevel {
  String get label => switch (this) {
        RiskLevel.low => 'Low Risk',
        RiskLevel.moderate => 'Moderate Risk',
        RiskLevel.high => 'High Risk',
      };

  Color get color => switch (this) {
        RiskLevel.low => const Color(0xFF10B981),
        RiskLevel.moderate => const Color(0xFFF59E0B),
        RiskLevel.high => const Color(0xFFEF4444),
      };

  Color get bgColor => switch (this) {
        RiskLevel.low => const Color(0xFFD1FAE5),
        RiskLevel.moderate => const Color(0xFFFEF3C7),
        RiskLevel.high => const Color(0xFFFEE2E2),
      };

  static RiskLevel fromString(String s) {
    switch (s.toLowerCase()) {
      case 'high':
        return RiskLevel.high;
      case 'moderate':
      case 'medium':
        return RiskLevel.moderate;
      default:
        return RiskLevel.low;
    }
  }
}

class PossibleCondition extends Equatable {
  final String name;
  final int confidence;
  final String description;

  const PossibleCondition({
    required this.name,
    required this.confidence,
    required this.description,
  });

  factory PossibleCondition.fromJson(Map<String, dynamic> j) =>
      PossibleCondition(
        name: j['name'] as String? ?? 'Unknown',
        confidence: (j['confidence'] as num?)?.toInt() ?? 0,
        description: j['description'] as String? ?? '',
      );

  @override
  List<Object?> get props => [name, confidence, description];
}

class AiRecommendation extends Equatable {
  final String title;
  final String description;
  final String type; // rest, water, thermometer, hospital, pill, etc.

  const AiRecommendation({
    required this.title,
    required this.description,
    required this.type,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> j) =>
      AiRecommendation(
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        type: j['type'] as String? ?? 'general',
      );

  IconData get icon => switch (type) {
        'rest' || 'sleep' => Icons.bed_outlined,
        'water' || 'hydration' => Icons.water_drop_outlined,
        'hospital' || 'doctor' => Icons.local_hospital_outlined,
        'pill' || 'medicine' || 'medication' => Icons.medication_outlined,
        'exercise' || 'activity' => Icons.directions_run_outlined,
        'food' || 'diet' || 'nutrition' => Icons.restaurant_outlined,
        'monitor' || 'thermometer' || 'temperature' =>
          Icons.thermostat_outlined,
        _ => Icons.health_and_safety_outlined,
      };

  @override
  List<Object?> get props => [title, description, type];
}

class SymptomAnalysis extends Equatable {
  final String? id;
  final String userId;
  final List<String> symptoms;
  final String? duration;
  final int? severity;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final RiskLevel riskLevel;
  final String summary;
  final List<PossibleCondition> possibleConditions;
  final List<AiRecommendation> recommendations;
  final String selfCareAdvice;
  final List<String> emergencyWarnings;
  final String whenToSeeDoctor;
  final String? recommendedSpecialty;
  final String disclaimer;
  final DateTime createdAt;

  const SymptomAnalysis({
    this.id,
    required this.userId,
    required this.symptoms,
    this.duration,
    this.severity,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    required this.riskLevel,
    required this.summary,
    required this.possibleConditions,
    required this.recommendations,
    required this.selfCareAdvice,
    required this.emergencyWarnings,
    required this.whenToSeeDoctor,
    this.recommendedSpecialty,
    required this.disclaimer,
    required this.createdAt,
  });

  factory SymptomAnalysis.fromAiJson({
    required String userId,
    required List<String> symptoms,
    String? duration,
    int? severity,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    required Map<String, dynamic> json,
  }) {
    final conditionsJson =
        (json['possible_conditions'] as List<dynamic>?) ?? [];
    final recommendationsJson =
        (json['recommendations'] as List<dynamic>?) ?? [];
    final warningsJson = (json['emergency_warnings'] as List<dynamic>?) ?? [];

    return SymptomAnalysis(
      userId: userId,
      symptoms: symptoms,
      duration: duration,
      severity: severity,
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      riskLevel: RiskLevelX.fromString(json['risk_level'] as String? ?? 'low'),
      summary: json['summary'] as String? ?? '',
      possibleConditions: conditionsJson
          .map((e) => PossibleCondition.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: recommendationsJson
          .map((e) => AiRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      selfCareAdvice: json['self_care_advice'] as String? ?? '',
      emergencyWarnings:
          warningsJson.map((e) => e as String).toList(),
      whenToSeeDoctor: json['when_to_see_doctor'] as String? ?? '',
      recommendedSpecialty: json['recommended_specialty'] as String?,
      disclaimer: json['disclaimer'] as String? ??
          'This analysis is for informational purposes only and does not '
              'constitute medical advice. Always consult a qualified healthcare professional.',
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, userId, symptoms, riskLevel, createdAt];
}
