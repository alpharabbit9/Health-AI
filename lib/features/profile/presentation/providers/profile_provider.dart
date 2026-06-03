import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/health_profile.dart';

const _kProfileKey = 'health_profile_cache';

final healthProfileProvider =
    StateNotifierProvider<HealthProfileNotifier, HealthProfile?>((ref) {
  final user = ref.watch(currentUserProvider);
  return HealthProfileNotifier(
    userId: user?.id,
    email: user?.email ?? '',
    seedFullName: user?.fullName ?? '',
    seedAge: user?.age,
    seedGender: user?.gender,
    seedAvatarUrl: user?.avatarUrl,
  );
});

final healthScoreProvider = Provider<int>((ref) {
  final profile = ref.watch(healthProfileProvider);
  if (profile == null) return 60;
  return (50 + (profile.completenessPercent * 0.3).round()).clamp(0, 100);
});

class HealthProfileNotifier extends StateNotifier<HealthProfile?> {
  HealthProfileNotifier({
    required this.userId,
    required this.email,
    required this.seedFullName,
    this.seedAge,
    this.seedGender,
    this.seedAvatarUrl,
  }) : super(null) {
    if (userId != null) _load();
  }

  final String? userId;
  final String email;
  final String seedFullName;
  final int? seedAge;
  final String? seedGender;
  final String? seedAvatarUrl;

  // ─── Load: Supabase first, SharedPreferences fallback ────

  Future<void> _load() async {
    _applyCache(); // render something immediately while DB loads

    try {
      final row = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', userId!)
          .maybeSingle();

      if (row != null && mounted) {
        state = _rowToProfile(row);
        _writeCache(state!);
      }
    } catch (e) {
      debugPrint('[HealthAI] Profile DB load failed (using cache): $e');
    }
  }

  void _applyCache() {
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      final raw = prefs.getString('${_kProfileKey}_$userId');
      Map<String, dynamic> c = {};
      if (raw != null) {
        try {
          c = jsonDecode(raw) as Map<String, dynamic>;
        } catch (_) {}
      }
      // Only replace if Supabase hasn't populated state yet.
      if (state == null) {
        state = HealthProfile(
          id: userId!,
          fullName: c['full_name'] as String? ?? seedFullName,
          email: c['email'] as String? ?? email,
          age: (c['age'] as num?)?.toInt() ?? seedAge,
          gender: c['gender'] as String? ?? seedGender,
          avatarUrl: c['avatar_url'] as String? ?? seedAvatarUrl,
          phone: c['phone'] as String?,
          heightCm: (c['height_cm'] as num?)?.toDouble(),
          weightKg: (c['weight_kg'] as num?)?.toDouble(),
          bloodGroup: c['blood_group'] as String?,
          allergies: _toStringList(c['allergies']),
          chronicConditions: _toStringList(c['chronic_conditions']),
          currentMedications: _toStringList(c['current_medications']),
        );
      }
    });
  }

  // ─── Save: split into two upserts so core fields always land ─

  Future<void> updateProfile(HealthProfile updated) async {
    if (userId == null) return;

    // Optimistic local update first so UI is instant.
    state = updated;

    final client = Supabase.instance.client;

    // Step 1 — Core columns that exist since the original schema.sql.
    // This ALWAYS runs and must succeed.
    await client.from('users').upsert(
      {
        'id': userId,
        'email': updated.email,
        'full_name': updated.fullName,
        if (updated.age != null) 'age': updated.age,
        if (updated.gender != null) 'gender': updated.gender,
        if (updated.avatarUrl != null) 'avatar_url': updated.avatarUrl,
      },
      onConflict: 'id',
    );

    // Step 2 — Extended columns added by setup.sql (schema v3).
    // Silently skipped if the migration hasn't been run yet.
    try {
      await client.from('users').upsert(
        {
          'id': userId,
          'phone': updated.phone,
          'height_cm': updated.heightCm,
          'weight_kg': updated.weightKg,
          'blood_group': updated.bloodGroup,
          'allergies': updated.allergies,
          'chronic_conditions': updated.chronicConditions,
          'current_medications': updated.currentMedications,
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (e) {
      // Columns don't exist yet → the user hasn't run setup.sql.
      debugPrint(
        '[HealthAI] Extended profile columns missing. '
        'Run supabase/setup.sql in your Supabase dashboard. '
        'Error: ${e.message}',
      );
    }

    // Always sync offline cache so data is available when offline.
    _writeCache(updated);
  }

  // ─── Avatar upload ────────────────────────────────────────────

  Future<void> uploadAvatar(Uint8List bytes, String ext) async {
    if (userId == null) return;

    final safeExt = ['jpg', 'jpeg', 'png', 'webp'].contains(ext) ? ext : 'jpg';
    final contentType = safeExt == 'png' ? 'image/png' : 'image/jpeg';
    final path = '$userId/avatar.$safeExt';
    final client = Supabase.instance.client;

    // Upload binary to the avatars Storage bucket.
    try {
      await client.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(upsert: true, contentType: contentType),
      );
    } on StorageException catch (e) {
      debugPrint('[HealthAI] Storage upload failed: ${e.message} (status ${e.statusCode})');
      // Surface a human-readable message.
      if ((e.statusCode == '404') ||
          e.message.toLowerCase().contains('not found') ||
          e.message.toLowerCase().contains('bucket') ||
          e.message.toLowerCase().contains('does not exist')) {
        throw Exception(
          'Storage bucket not configured. '
          'Run supabase/setup.sql in your Supabase dashboard, then try again.',
        );
      }
      if (e.statusCode == '403' || e.message.toLowerCase().contains('policy')) {
        throw Exception(
          'Upload permission denied. '
          'Run supabase/setup.sql to apply the correct storage policies.',
        );
      }
      throw Exception('Upload failed: ${e.message}');
    }

    // Build a cache-busted public URL so Image.network reloads immediately.
    final publicUrl = client.storage.from('avatars').getPublicUrl(path);
    final url = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

    // Persist URL to the users table (best-effort — don't fail the upload).
    try {
      await client
          .from('users')
          .upsert({'id': userId, 'avatar_url': url}, onConflict: 'id');
    } catch (e) {
      debugPrint('[HealthAI] avatar_url DB persist failed (non-fatal): $e');
    }

    if (mounted) {
      state = state?.copyWith(avatarUrl: url);
      if (state != null) _writeCache(state!);
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────

  HealthProfile _rowToProfile(Map<String, dynamic> row) {
    return HealthProfile(
      id: userId!,
      fullName: row['full_name'] as String? ?? seedFullName,
      email: row['email'] as String? ?? email,
      age: (row['age'] as num?)?.toInt() ?? seedAge,
      gender: row['gender'] as String? ?? seedGender,
      avatarUrl: row['avatar_url'] as String? ?? seedAvatarUrl,
      phone: row['phone'] as String?,
      heightCm: (row['height_cm'] as num?)?.toDouble(),
      weightKg: (row['weight_kg'] as num?)?.toDouble(),
      bloodGroup: row['blood_group'] as String?,
      allergies: _toStringList(row['allergies']),
      chronicConditions: _toStringList(row['chronic_conditions']),
      currentMedications: _toStringList(row['current_medications']),
    );
  }

  List<String> _toStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  Future<void> _writeCache(HealthProfile p) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '${_kProfileKey}_$userId',
        jsonEncode({
          'full_name': p.fullName,
          'email': p.email,
          'age': p.age,
          'gender': p.gender,
          'avatar_url': p.avatarUrl,
          'phone': p.phone,
          'height_cm': p.heightCm,
          'weight_kg': p.weightKg,
          'blood_group': p.bloodGroup,
          'allergies': p.allergies,
          'chronic_conditions': p.chronicConditions,
          'current_medications': p.currentMedications,
        }),
      );
    } catch (e) {
      debugPrint('[HealthAI] Cache write failed (non-fatal): $e');
    }
  }
}
