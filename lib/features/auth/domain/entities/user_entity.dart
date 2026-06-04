import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final int? age;
  final String? gender;
  final String? avatarUrl;
  final DateTime createdAt;
  final String role;   // 'user' | 'admin'
  final String status; // 'active' | 'disabled'

  const UserEntity({
    required this.id,
    required this.email,
    this.fullName,
    this.age,
    this.gender,
    this.avatarUrl,
    required this.createdAt,
    this.role = 'user',
    this.status = 'active',
  });

  bool get isAdmin => role == 'admin';

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    int? age,
    String? gender,
    String? avatarUrl,
    DateTime? createdAt,
    String? role,
    String? status,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, fullName, age, gender, avatarUrl, createdAt, role, status];
}
