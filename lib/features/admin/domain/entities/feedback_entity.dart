class FeedbackEntity {
  final String id;
  final String? userId;
  final String? userName;
  final String title;
  final String message;
  final String type;   // feedback | suggestion | bug
  final String status; // pending | resolved
  final DateTime createdAt;

  const FeedbackEntity({
    required this.id,
    this.userId,
    this.userName,
    required this.title,
    required this.message,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  bool get isResolved => status == 'resolved';

  factory FeedbackEntity.fromMap(Map<String, dynamic> m) => FeedbackEntity(
        id: m['id'] as String,
        userId: m['user_id'] as String?,
        userName: m['users']?['full_name'] as String? ??
            m['users']?['email'] as String?,
        title: m['title'] as String,
        message: m['message'] as String,
        type: m['type'] as String? ?? 'feedback',
        status: m['status'] as String? ?? 'pending',
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}
