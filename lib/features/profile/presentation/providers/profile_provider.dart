import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/health_profile.dart';

const _kProfileKey = 'health_profile_extra';

final healthProfileProvider =
    StateNotifierProvider<HealthProfileNotifier, HealthProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  return HealthProfileNotifier(
    userId: user?.id,
    fullName: user?.fullName ?? '',
    email: user?.email ?? '',
    age: user?.age,
    gender: user?.gender,
    avatarUrl: user?.avatarUrl,
  );
});

final healthScoreProvider = Provider<int>((ref) {
  final profile = ref.watch(healthProfileProvider);
  if (profile == null) return 60;
  return (50 + (profile.completenessPercent * 0.3).round()).clamp(0, 100);
});

class HealthProfileNotifier extends StateNotifier<HealthProfile?> {
  final String? userId;
  final String fullName;
  final String email;
  final int? age;
  final String? gender;
  final String? avatarUrl;

  HealthProfileNotifier({
    required this.userId,
    required this.fullName,
    required this.email,
    this.age,
    this.gender,
    this.avatarUrl,
  }) : super(null) {
    if (userId != null) _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('${_kProfileKey}_$userId');
    Map<String, dynamic> extra = {};
    if (json != null) {
      try {
        extra = jsonDecode(json) as Map<String, dynamic>;
      } catch (_) {}
    }
    state = HealthProfile(
      id: userId!,
      fullName: fullName,
      email: email,
      age: age,
      gender: gender,
      avatarUrl: avatarUrl,
      phone: extra['phone'] as String?,
      heightCm: (extra['height_cm'] as num?)?.toDouble(),
      weightKg: (extra['weight_kg'] as num?)?.toDouble(),
      bloodGroup: extra['blood_group'] as String?,
      allergies: (extra['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      chronicConditions: (extra['chronic_conditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      currentMedications: (extra['current_medications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Future<void> updateProfile(HealthProfile updated) async {
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_kProfileKey}_$userId',
      jsonEncode({
        'phone': updated.phone,
        'height_cm': updated.heightCm,
        'weight_kg': updated.weightKg,
        'blood_group': updated.bloodGroup,
        'allergies': updated.allergies,
        'chronic_conditions': updated.chronicConditions,
        'current_medications': updated.currentMedications,
      }),
    );

    try {
      await Supabase.instance.client.from('users').upsert(
        {
          'id': userId,
          'email': updated.email,
          'full_name': updated.fullName,
          if (updated.age != null) 'age': updated.age,
          if (updated.gender != null) 'gender': updated.gender,
        },
        onConflict: 'id',
      );
    } catch (_) {}

    state = updated;
  }
}
