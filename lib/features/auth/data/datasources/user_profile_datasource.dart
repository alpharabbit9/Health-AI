import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_constants.dart';

abstract class UserProfileDatasource {
  /// Fetch the profile row for [userId]. Returns null if not found.
  Future<Map<String, dynamic>?> fetchProfile(String userId);

  /// Insert a new profile row. Throws on conflict or RLS violation.
  Future<void> createProfile({
    required String id,
    required String email,
    required String fullName,
    required int age,
    required String gender,
  });

  /// Insert or update a profile row (safe for re-runs / legacy users).
  Future<void> upsertProfile({
    required String id,
    required String email,
    String? fullName,
    int? age,
    String? gender,
  });
}

class UserProfileDatasourceImpl implements UserProfileDatasource {
  final SupabaseClient _client;

  const UserProfileDatasourceImpl(this._client);

  @override
  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    try {
      debugPrint('[PROFILE] Fetching profile for user: $userId');
      final row = await _client
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle();
      debugPrint(
          '[PROFILE] Profile fetched: ${row != null ? "found" : "not found"}');
      return row;
    } catch (e) {
      debugPrint('[PROFILE] Error fetching profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> createProfile({
    required String id,
    required String email,
    required String fullName,
    required int age,
    required String gender,
  }) async {
    try {
      debugPrint('[PROFILE] Creating profile for user: $id');
      await _client.from(SupabaseConstants.usersTable).insert({
        'id': id,
        'email': email,
        'full_name': fullName,
        'age': age,
        'gender': gender,
      });
      debugPrint('[PROFILE] Profile created successfully');
    } catch (e) {
      debugPrint('[PROFILE] Error creating profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> upsertProfile({
    required String id,
    required String email,
    String? fullName,
    int? age,
    String? gender,
  }) async {
    try {
      debugPrint('[PROFILE] Upserting profile for user: $id');
      await _client.from(SupabaseConstants.usersTable).upsert(
        {
          'id': id,
          'email': email,
          if (fullName != null) 'full_name': fullName,
          if (age != null) 'age': age,
          if (gender != null) 'gender': gender,
        },
        onConflict: 'id',
      );
      debugPrint('[PROFILE] Profile upserted successfully');
    } catch (e) {
      debugPrint('[PROFILE] Error upserting profile: $e');
      rethrow;
    }
  }
}
