class AdminUserEntity {
  final String id;
  final String email;
  final String? fullName;
  final String role;
  final String status;
  final DateTime createdAt;

  const AdminUserEntity({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isActive => status == 'active';

  AdminUserEntity copyWith({
    String? role,
    String? status,
  }) =>
      AdminUserEntity(
        id: id,
        email: email,
        fullName: fullName,
        role: role ?? this.role,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  factory AdminUserEntity.fromMap(Map<String, dynamic> m) => AdminUserEntity(
        id: m['id'] as String,
        email: m['email'] as String? ?? '',
        fullName: m['full_name'] as String?,
        role: m['role'] as String? ?? 'user',
        status: m['status'] as String? ?? 'active',
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}
