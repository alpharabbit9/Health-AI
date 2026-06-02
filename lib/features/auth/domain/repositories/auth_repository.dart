import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

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
