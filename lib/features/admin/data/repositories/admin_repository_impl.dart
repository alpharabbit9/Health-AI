import '../../domain/entities/admin_stats_entity.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/entities/feedback_entity.dart';
import '../../domain/entities/health_tip_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminDatasource _ds;
  const AdminRepositoryImpl(this._ds);

  @override
  Future<AdminStatsEntity> fetchStats() async {
    final m = await _ds.fetchStats();
    return AdminStatsEntity(
      totalUsers: m['total_users'] as int? ?? 0,
      totalAnalyses: m['total_analyses'] as int? ?? 0,
      totalDoctors: m['total_doctors'] as int? ?? 0,
      totalHealthTips: m['total_health_tips'] as int? ?? 0,
      newUsersThisWeek: m['new_users_this_week'] as int? ?? 0,
      lowRiskCount: m['low_risk'] as int? ?? 0,
      moderateRiskCount: m['moderate_risk'] as int? ?? 0,
      highRiskCount: m['high_risk'] as int? ?? 0,
    );
  }

  @override
  Future<List<AdminUserEntity>> fetchUsers({String? search}) async {
    final rows = await _ds.fetchUsers(search: search);
    return rows.map(AdminUserEntity.fromMap).toList();
  }

  @override
  Future<void> updateUserRole(String userId, String role) =>
      _ds.updateUserRole(userId, role);

  @override
  Future<void> updateUserStatus(String userId, String status) =>
      _ds.updateUserStatus(userId, status);

  @override
  Future<void> deleteUser(String userId) => _ds.deleteUser(userId);

  @override
  Future<List<Map<String, dynamic>>> fetchAnalyses({String? filter}) =>
      _ds.fetchAnalyses(filter: filter);

  @override
  Future<List<DoctorEntity>> fetchDoctors() async {
    final rows = await _ds.fetchDoctors();
    return rows.map(DoctorEntity.fromMap).toList();
  }

  @override
  Future<void> createDoctor(DoctorEntity doctor) =>
      _ds.createDoctor(doctor.toMap());

  @override
  Future<void> updateDoctor(DoctorEntity doctor) =>
      _ds.updateDoctor(doctor.id, doctor.toMap());

  @override
  Future<void> deleteDoctor(String doctorId) => _ds.deleteDoctor(doctorId);

  @override
  Future<List<HealthTipEntity>> fetchHealthTips() async {
    final rows = await _ds.fetchHealthTips();
    return rows.map(HealthTipEntity.fromMap).toList();
  }

  @override
  Future<void> createHealthTip(HealthTipEntity tip) =>
      _ds.createHealthTip(tip.toMap());

  @override
  Future<void> updateHealthTip(HealthTipEntity tip) =>
      _ds.updateHealthTip(tip.id, tip.toMap());

  @override
  Future<void> deleteHealthTip(String tipId) => _ds.deleteHealthTip(tipId);

  @override
  Future<List<FeedbackEntity>> fetchFeedback() async {
    final rows = await _ds.fetchFeedback();
    return rows.map(FeedbackEntity.fromMap).toList();
  }

  @override
  Future<void> markFeedbackResolved(String feedbackId) =>
      _ds.markFeedbackResolved(feedbackId);

  @override
  Future<void> deleteFeedback(String feedbackId) =>
      _ds.deleteFeedback(feedbackId);

  @override
  Future<void> submitFeedback({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) =>
      _ds.submitFeedback({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'status': 'pending',
      });
}
