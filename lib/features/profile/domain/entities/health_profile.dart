import 'package:equatable/equatable.dart';

class HealthProfile extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? bloodGroup;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<String> currentMedications;
  final String? avatarUrl;

  const HealthProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.bloodGroup,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.currentMedications = const [],
    this.avatarUrl,
  });

  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm! <= 0) return null;
    final h = heightCm! / 100;
    return weightKg! / (h * h);
  }

  String? get bmiCategory {
    final b = bmi;
    if (b == null) return null;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  int get completenessPercent {
    int filled = 0;
    const total = 11;
    if (fullName.isNotEmpty) filled++;
    if (email.isNotEmpty) filled++;
    if (phone != null && phone!.isNotEmpty) filled++;
    if (age != null) filled++;
    if (gender != null) filled++;
    if (heightCm != null) filled++;
    if (weightKg != null) filled++;
    if (bloodGroup != null) filled++;
    if (allergies.isNotEmpty) filled++;
    if (chronicConditions.isNotEmpty) filled++;
    if (currentMedications.isNotEmpty) filled++;
    return (filled / total * 100).round();
  }

  HealthProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? bloodGroup,
    List<String>? allergies,
    List<String>? chronicConditions,
    List<String>? currentMedications,
    String? avatarUrl,
  }) {
    return HealthProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [
        id, fullName, email, phone, age, gender, heightCm, weightKg,
        bloodGroup, allergies, chronicConditions, currentMedications, avatarUrl,
      ];
}
