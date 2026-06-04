import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/admin_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/admin_stats_entity.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/entities/feedback_entity.dart';
import '../../domain/entities/health_tip_entity.dart';
import '../../domain/repositories/admin_repository.dart';

// ─── Infrastructure ──────────────────────────────────────────
final adminDatasourceProvider = Provider<AdminDatasource>(
  (ref) => AdminDatasourceImpl(ref.watch(supabaseClientProvider)),
);

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepositoryImpl(ref.watch(adminDatasourceProvider)),
);

// ─── Stats ────────────────────────────────────────────────────
final adminStatsProvider =
    AsyncNotifierProvider<AdminStatsNotifier, AdminStatsEntity>(
  AdminStatsNotifier.new,
);

class AdminStatsNotifier extends AsyncNotifier<AdminStatsEntity> {
  @override
  Future<AdminStatsEntity> build() =>
      ref.watch(adminRepositoryProvider).fetchStats();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(adminRepositoryProvider).fetchStats());
  }
}

// ─── Users ────────────────────────────────────────────────────
final adminUsersSearchProvider = StateProvider<String>((ref) => '');

final adminUsersProvider =
    AsyncNotifierProvider<AdminUsersNotifier, List<AdminUserEntity>>(
  AdminUsersNotifier.new,
);

class AdminUsersNotifier extends AsyncNotifier<List<AdminUserEntity>> {
  @override
  Future<List<AdminUserEntity>> build() {
    final search = ref.watch(adminUsersSearchProvider);
    return ref.watch(adminRepositoryProvider).fetchUsers(search: search);
  }

  Future<void> updateRole(String userId, String role) async {
    await ref.read(adminRepositoryProvider).updateUserRole(userId, role);
    ref.invalidateSelf();
  }

  Future<void> toggleStatus(String userId, String currentStatus) async {
    final next = currentStatus == 'active' ? 'disabled' : 'active';
    await ref.read(adminRepositoryProvider).updateUserStatus(userId, next);
    ref.invalidateSelf();
  }

  Future<void> deleteUser(String userId) async {
    await ref.read(adminRepositoryProvider).deleteUser(userId);
    ref.invalidateSelf();
  }
}

// ─── Analyses ─────────────────────────────────────────────────
final adminAnalysesFilterProvider = StateProvider<String?>((ref) => null);

final adminAnalysesProvider =
    AsyncNotifierProvider<AdminAnalysesNotifier, List<Map<String, dynamic>>>(
  AdminAnalysesNotifier.new,
);

class AdminAnalysesNotifier
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() {
    final filter = ref.watch(adminAnalysesFilterProvider);
    return ref.watch(adminRepositoryProvider).fetchAnalyses(filter: filter);
  }

  void setFilter(String? filter) {
    ref.read(adminAnalysesFilterProvider.notifier).state = filter;
  }
}

// ─── Doctors ─────────────────────────────────────────────────
final adminDoctorsProvider =
    AsyncNotifierProvider<AdminDoctorsNotifier, List<DoctorEntity>>(
  AdminDoctorsNotifier.new,
);

class AdminDoctorsNotifier extends AsyncNotifier<List<DoctorEntity>> {
  @override
  Future<List<DoctorEntity>> build() =>
      ref.watch(adminRepositoryProvider).fetchDoctors();

  Future<void> create(DoctorEntity doctor) async {
    await ref.read(adminRepositoryProvider).createDoctor(doctor);
    ref.invalidateSelf();
  }

  Future<void> edit(DoctorEntity doctor) async {
    await ref.read(adminRepositoryProvider).updateDoctor(doctor);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(adminRepositoryProvider).deleteDoctor(id);
    ref.invalidateSelf();
  }
}

// ─── Health Tips ─────────────────────────────────────────────
final adminHealthTipsProvider =
    AsyncNotifierProvider<AdminHealthTipsNotifier, List<HealthTipEntity>>(
  AdminHealthTipsNotifier.new,
);

class AdminHealthTipsNotifier extends AsyncNotifier<List<HealthTipEntity>> {
  @override
  Future<List<HealthTipEntity>> build() =>
      ref.watch(adminRepositoryProvider).fetchHealthTips();

  Future<void> create(HealthTipEntity tip) async {
    await ref.read(adminRepositoryProvider).createHealthTip(tip);
    ref.invalidateSelf();
  }

  Future<void> edit(HealthTipEntity tip) async {
    await ref.read(adminRepositoryProvider).updateHealthTip(tip);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(adminRepositoryProvider).deleteHealthTip(id);
    ref.invalidateSelf();
  }
}

// ─── Feedback ─────────────────────────────────────────────────
final adminFeedbackProvider =
    AsyncNotifierProvider<AdminFeedbackNotifier, List<FeedbackEntity>>(
  AdminFeedbackNotifier.new,
);

class AdminFeedbackNotifier extends AsyncNotifier<List<FeedbackEntity>> {
  @override
  Future<List<FeedbackEntity>> build() =>
      ref.watch(adminRepositoryProvider).fetchFeedback();

  Future<void> markResolved(String id) async {
    await ref.read(adminRepositoryProvider).markFeedbackResolved(id);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(adminRepositoryProvider).deleteFeedback(id);
    ref.invalidateSelf();
  }
}

// ─── User feedback submit ────────────────────────────────────
final submitFeedbackProvider =
    AsyncNotifierProvider<SubmitFeedbackNotifier, void>(
  SubmitFeedbackNotifier.new,
);

class SubmitFeedbackNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> submit({
    required String title,
    required String message,
    required String type,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;
    state = const AsyncLoading();
    try {
      await ref.read(adminRepositoryProvider).submitFeedback(
            userId: user.id,
            title: title,
            message: message,
            type: type,
          );
      state = const AsyncData(null);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}
