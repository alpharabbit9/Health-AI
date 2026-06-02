import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;

  const AuthRepositoryImpl(this._remote);

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _remote.signInWithEmail(email: email, password: password);

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required int age,
    required String gender,
  }) =>
      _remote.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        age: age,
        gender: gender,
      );

  @override
  Future<void> signOut() => _remote.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _remote.sendPasswordResetEmail(email);

  @override
  Future<UserEntity?> getCurrentUser() => _remote.getCurrentUser();

  @override
  Stream<UserEntity?> get authStateChanges => _remote.authStateChanges;
}
