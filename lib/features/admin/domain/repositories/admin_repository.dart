import '../entities/admin_stats_entity.dart';
import '../entities/admin_user_entity.dart';
import '../entities/doctor_entity.dart';
import '../entities/feedback_entity.dart';
import '../entities/health_tip_entity.dart';

abstract class AdminRepository {
  // Stats
  Future<AdminStatsEntity> fetchStats();

  // Users
  Future<List<AdminUserEntity>> fetchUsers({String? search});
  Future<void> updateUserRole(String userId, String role);
  Future<void> updateUserStatus(String userId, String status);
  Future<void> deleteUser(String userId);

  // Analyses (read-only for admin)
  Future<List<Map<String, dynamic>>> fetchAnalyses({String? filter});

  // Doctors
  Future<List<DoctorEntity>> fetchDoctors();
  Future<void> createDoctor(DoctorEntity doctor);
  Future<void> updateDoctor(DoctorEntity doctor);
  Future<void> deleteDoctor(String doctorId);

  // Health Tips
  Future<List<HealthTipEntity>> fetchHealthTips();
  Future<void> createHealthTip(HealthTipEntity tip);
  Future<void> updateHealthTip(HealthTipEntity tip);
  Future<void> deleteHealthTip(String tipId);

  // Feedback
  Future<List<FeedbackEntity>> fetchFeedback();
  Future<void> markFeedbackResolved(String feedbackId);
  Future<void> deleteFeedback(String feedbackId);
  Future<void> submitFeedback({
    required String userId,
    required String title,
    required String message,
    required String type,
  });
}
