class AdminStatsEntity {
  final int totalUsers;
  final int totalAnalyses;
  final int totalDoctors;
  final int totalHealthTips;
  final int newUsersThisWeek;
  final int lowRiskCount;
  final int moderateRiskCount;
  final int highRiskCount;

  const AdminStatsEntity({
    required this.totalUsers,
    required this.totalAnalyses,
    required this.totalDoctors,
    required this.totalHealthTips,
    required this.newUsersThisWeek,
    required this.lowRiskCount,
    required this.moderateRiskCount,
    required this.highRiskCount,
  });

  static const empty = AdminStatsEntity(
    totalUsers: 0,
    totalAnalyses: 0,
    totalDoctors: 0,
    totalHealthTips: 0,
    newUsersThisWeek: 0,
    lowRiskCount: 0,
    moderateRiskCount: 0,
    highRiskCount: 0,
  );
}
