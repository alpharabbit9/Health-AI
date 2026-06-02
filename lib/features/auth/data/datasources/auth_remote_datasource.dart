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
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('Sign in failed: no user returned');

      debugPrint('[DATASOURCE] Sign in successful for $email');

      // Fetch profile from users table; upsert if missing (handles legacy accounts)
      final profileRow = await _profile.fetchProfile(user.id);
      if (profileRow == null) {
        debugPrint(
            '[DATASOURCE] Profile not found, upserting for user ${user.id}');
        await _profile.upsertProfile(
          id: user.id,
          email: user.email ?? email,
          fullName: user.userMetadata?['full_name'] as String?,
          age: user.userMetadata?['age'] as int?,
          gender: user.userMetadata?['gender'] as String?,
        );
        return _toEntity(user, await _profile.fetchProfile(user.id));
      }

      return _toEntity(user, profileRow);
    } catch (e) {
      debugPrint('[DATASOURCE] Sign in error: $e');
      debugPrint('[DATASOURCE] Error type: ${e.runtimeType}');
      rethrow;
    }
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
    try {
      debugPrint('[DATASOURCE] Attempting signup for email: $email');

      // Step 1: Create the auth user (also writes metadata used by the DB trigger)
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'age': age, 'gender': gender},
      );

      final user = response.user;
      if (user == null) throw Exception('Sign up failed: no user returned');

      debugPrint('[DATASOURCE] Auth user created: ${user.id}');

      // Step 2: Insert profile row from the client side.
      // The DB trigger (handle_new_auth_user) may have already created it;
      // the insert uses ON CONFLICT DO NOTHING so it is idempotent.
      try {
        await _profile.createProfile(
          id: user.id,
          email: email,
          fullName: fullName,
          age: age,
          gender: gender,
        );
        debugPrint('[DATASOURCE] Profile created successfully');
      } on PostgrestException catch (e) {
        debugPrint('[DATASOURCE] PostgrestException: ${e.code} - ${e.message}');
        // Duplicate key means the trigger already created the row — that's fine.
        if (e.code != '23505') {
          // Any other DB error: sign out so the orphaned auth user cannot log in
          // without a profile, then surface a clear message.
          await _client.auth.signOut();
          throw Exception(
            'Account created but profile setup failed. Please try again. (${e.message})',
          );
        }
      } catch (e) {
        debugPrint('[DATASOURCE] Signup error during profile creation: $e');
        await _client.auth.signOut();
        throw Exception(
          'Account created but profile setup failed. Please try again.',
        );
      }

      return UserEntity(
        id: user.id,
        email: email,
        fullName: fullName,
        age: age,
        gender: gender,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[DATASOURCE] Sign up error: $e');
      rethrow;
    }
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

    final profileRow = await _profile.fetchProfile(user.id);
    return _toEntity(user, profileRow);
  }

  // ─── Auth state stream ──────────────────────────────────
  @override
  Stream<UserEntity?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;
      final profileRow = await _profile.fetchProfile(user.id);
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
          : (authUser.createdAt != null
              ? DateTime.tryParse(authUser.createdAt!) ?? DateTime.now()
              : DateTime.now()),
    );
  }
}
