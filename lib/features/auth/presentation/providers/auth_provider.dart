import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide UserEntity;

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ─── Infrastructure providers ─────────────────────────────
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasourceImpl(ref.watch(supabaseClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)),
);

// ─── Auth state ───────────────────────────────────────────
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

// ─── Auth notifier ────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthInitial()) {
    _init();
  }

  Future<void> _init() async {
    final user = await _repository.getCurrentUser();
    state = user != null ? AuthAuthenticated(user) : const AuthUnauthenticated();
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final user = await _repository.signInWithEmail(email: email, password: password);
      state = AuthAuthenticated(user);
      return true;
    } catch (e) {
      state = AuthError(_parseError(e));
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required int age,
    required String gender,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _repository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        age: age,
        gender: gender,
      );
      state = AuthAuthenticated(user);
      return true;
    } catch (e) {
      state = AuthError(_parseError(e));
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AuthLoading();
    try {
      await _repository.sendPasswordResetEmail(email);
      state = const AuthUnauthenticated();
      return true;
    } catch (e) {
      state = AuthError(_parseError(e));
      return false;
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      await _repository.signOut();
      state = const AuthUnauthenticated();
    } catch (e) {
      state = AuthError(_parseError(e));
    }
  }

  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }

  String _parseError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please verify your email before signing in.';
    }
    if (msg.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (msg.contains('network') || msg.contains('socketexception')) {
      return 'Network error. Please check your connection.';
    }
    if (msg.contains('password') && msg.contains('weak')) {
      return 'Password is too weak. Please choose a stronger password.';
    }
    return 'Something went wrong. Please try again.';
  }
}

// ─── Current user convenience provider ───────────────────
final currentUserProvider = Provider<UserEntity?>((ref) {
  final state = ref.watch(authProvider);
  return state is AuthAuthenticated ? state.user : null;
});
