import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum RiskLevel { low, medium, high }

extension RiskLevelX on RiskLevel {
  String get label => switch (this) {
        RiskLevel.low => 'Low Risk',
        RiskLevel.medium => 'Medium Risk',
        RiskLevel.high => 'High Risk',
      };

  Color get color => switch (this) {
        RiskLevel.low => const Color(0xFF10B981),
        RiskLevel.medium => const Color(0xFFF59E0B),
        RiskLevel.high => const Color(0xFFEF4444),
      };

  Color get bgColor => switch (this) {
        RiskLevel.low => const Color(0xFFD1FAE5),
        RiskLevel.medium => const Color(0xFFFEF3C7),
        RiskLevel.high => const Color(0xFFFEE2E2),
      };

  IconData get icon => switch (this) {
        RiskLevel.low => Icons.check_circle_outline_rounded,
        RiskLevel.medium => Icons.warning_amber_rounded,
        RiskLevel.high => Icons.error_outline_rounded,
      };
}

class HealthRecord extends Equatable {
  final String id;
  final DateTime date;
  final List<String> symptoms;
  final RiskLevel riskLevel;
  final String? possibleConditions;
  final String? aiRecommendations;
  final String? notes;

  const HealthRecord({
    required this.id,
    required this.date,
    required this.symptoms,
    required this.riskLevel,
    this.possibleConditions,
    this.aiRecommendations,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        symptoms,
        riskLevel,
        possibleConditions,
        aiRecommendations,
        notes,
      ];
}
