import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import 'user_profile_datasource.dart';

abstract class AuthRemoteDatasource {
  Future<UserEntity> signInWithEmail(
      {required String email, required String password});

  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required int age,
    required String gender,
  });

  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserEntity?> getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient _client;
  final UserProfileDatasource _profile;

  const AuthRemoteDatasourceImpl(this._client, this._profile);

  // ─── Sign In ────────────────────────────────────────────
  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception('Sign in failed: no user returned');

    // Profile fetch is best-effort — login succeeds even if the users table
    // doesn't exist yet or the fetch fails for any other reason.
    Map<String, dynamic>? profileRow;
    try {
      profileRow = await _profile.fetchProfile(user.id);
      if (profileRow == null) {
        await _profile.upsertProfile(
          id: user.id,
          email: user.email ?? email,
          fullName: user.userMetadata?['full_name'] as String?,
          age: user.userMetadata?['age'] as int?,
          gender: user.userMetadata?['gender'] as String?,
        );
        profileRow = await _profile.fetchProfile(user.id);
      }
    } catch (e) {
      debugPrint('[HealthAI] Profile fetch skipped (table may not exist): $e');
    }

    return _toEntity(user, profileRow);
  }

  // ─── Sign Up ────────────────────────────────────────────
  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required int age,
    required String gender,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'age': age, 'gender': gender},
    );

    final user = response.user;
    if (user == null) throw Exception('Sign up failed: no user returned');

    // Best-effort profile insert — never roll back the auth user.
    // The DB trigger may already have created the row.
    try {
      await _profile.createProfile(
        id: user.id,
        email: email,
        fullName: fullName,
        age: age,
        gender: gender,
      );
    } on PostgrestException catch (e) {
      // 23505 = duplicate key — DB trigger already created the row, fine.
      if (e.code != '23505') {
        debugPrint('[HealthAI] Profile insert failed (non-fatal): ${e.message}');
      }
    } catch (e) {
      debugPrint('[HealthAI] Profile insert skipped: $e');
    }

    return UserEntity(
      id: user.id,
      email: email,
      fullName: fullName,
      age: age,
      gender: gender,
      createdAt: DateTime.now(),
    );
  }

  // ─── Sign Out ───────────────────────────────────────────
  @override
  Future<void> signOut() => _client.auth.signOut();

  // ─── Password Reset ─────────────────────────────────────
  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _client.auth.resetPasswordForEmail(email);

  // ─── Current User ───────────────────────────────────────
  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    Map<String, dynamic>? profileRow;
    try {
      profileRow = await _profile.fetchProfile(user.id);
    } catch (e) {
      debugPrint('[HealthAI] getCurrentUser profile fetch failed: $e');
    }
    return _toEntity(user, profileRow);
  }

  // ─── Auth state stream ──────────────────────────────────
  @override
  Stream<UserEntity?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      Map<String, dynamic>? profileRow;
      try {
        profileRow = await _profile.fetchProfile(user.id);
      } catch (_) {}
      return _toEntity(user, profileRow);
    });
  }

  // ─── Mapper ─────────────────────────────────────────────
  UserEntity _toEntity(User authUser, Map<String, dynamic>? profile) {
    final meta = authUser.userMetadata ?? {};
    return UserEntity(
      id: authUser.id,
      email: authUser.email ?? profile?['email'] as String? ?? '',
      // Profile table is the source of truth; fall back to auth metadata
      fullName:
          profile?['full_name'] as String? ?? meta['full_name'] as String?,
      age: (profile?['age'] as num?)?.toInt() ?? (meta['age'] as num?)?.toInt(),
      gender: profile?['gender'] as String? ?? meta['gender'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      createdAt: (profile != null && profile['created_at'] != null)
          ? DateTime.tryParse(profile['created_at'] as String) ?? DateTime.now()
          : (DateTime.tryParse(authUser.createdAt!) ?? DateTime.now()),
    );
  }
}
