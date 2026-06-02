import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDatasource {
  Future<UserEntity> signInWithEmail({required String email, required String password});

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

  AuthRemoteDatasourceImpl(this._client);

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
    return _mapUser(user);
  }

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
      data: {
        'full_name': fullName,
        'age': age,
        'gender': gender,
      },
    );

    final user = response.user;
    if (user == null) throw Exception('Sign up failed: no user returned');
    return _mapUser(user);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _client.auth.resetPasswordForEmail(email);

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _mapUser(user);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;
      return _mapUser(user);
    });
  }

  UserEntity _mapUser(User user) {
    final meta = user.userMetadata ?? {};
    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      fullName: meta['full_name'] as String?,
      age: meta['age'] as int?,
      gender: meta['gender'] as String?,
      avatarUrl: meta['avatar_url'] as String?,
      createdAt: user.createdAt != null
          ? DateTime.tryParse(user.createdAt!) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
