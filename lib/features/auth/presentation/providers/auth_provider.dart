import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/user_profile_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ─── Infrastructure providers ─────────────────────────────
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final userProfileDatasourceProvider = Provider<UserProfileDatasource>(
  (ref) => UserProfileDatasourceImpl(ref.watch(supabaseClientProvider)),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDatasource>(
  (ref) => AuthRemoteDatasourceImpl(
    ref.watch(supabaseClientProvider),
    ref.watch(userProfileDatasourceProvider),
  ),
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
    try {
      final user = await _repository.getCurrentUser();
      state =
          user != null ? AuthAuthenticated(user) : const AuthUnauthenticated();
    } catch (e) {
      state = const AuthUnauthenticated();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final user =
          await _repository.signInWithEmail(email: email, password: password);
      state = AuthAuthenticated(user);
      return true;
    } catch (e) {
      debugPrint('[AUTH ERROR] Sign in failed: $e');
      debugPrint('[AUTH ERROR] Error type: ${e.runtimeType}');
      debugPrint(
          '[AUTH ERROR] Full stacktrace: ${e is Exception ? e.toString() : 'N/A'}');
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
    final errorStr = e.toString().toLowerCase();
    debugPrint('[AUTH PARSER] Parsing error: $errorStr');

    // Auth-specific errors
    if (errorStr.contains('invalid login credentials') ||
        errorStr.contains('invalid_credentials') ||
        errorStr.contains('unauthorized')) {
      return 'Invalid email or password. Please try again.';
    }

    if (errorStr.contains('email not confirmed') ||
        errorStr.contains('email_not_confirmed')) {
      return 'Please verify your email before signing in.';
    }

    if (errorStr.contains('user already registered') ||
        errorStr.contains('user_already_exists')) {
      return 'An account with this email already exists.';
    }

    // RLS policy violations
    if (errorStr.contains('rls violation') ||
        errorStr.contains('row level security') ||
        errorStr.contains('permission denied')) {
      return 'Unable to access your profile. Please contact support.';
    }

    // Network errors
    if (errorStr.contains('network') ||
        errorStr.contains('socketexception') ||
        errorStr.contains('timeout') ||
        errorStr.contains('connection refused')) {
      return 'Network error. Please check your connection and try again.';
    }

    // Password errors
    if (errorStr.contains('password') && errorStr.contains('weak')) {
      return 'Password is too weak. Please choose a stronger password.';
    }

    if (errorStr.contains('password') && errorStr.contains('invalid')) {
      return 'Your password does not meet the requirements.';
    }

    // Email errors
    if (errorStr.contains('email') && errorStr.contains('invalid')) {
      return 'Please enter a valid email address.';
    }

    // Table/database errors
    if (errorStr.contains('does not exist') ||
        errorStr.contains('no row') ||
        errorStr.contains('table')) {
      return 'Database configuration error. Please try again later.';
    }

    // Default fallback with hint
    debugPrint('[AUTH PARSER] Unhandled error type: ${e.runtimeType}');
    return 'Something went wrong. Please try again. If the problem persists, check your internet connection.';
  }
}

// ─── Current user convenience provider ───────────────────
final currentUserProvider = Provider<UserEntity?>((ref) {
  final state = ref.watch(authProvider);
  return state is AuthAuthenticated ? state.user : null;
});
