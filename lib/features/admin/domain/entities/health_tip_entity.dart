class HealthTipEntity {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;

  const HealthTipEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
  });

  factory HealthTipEntity.fromMap(Map<String, dynamic> m) => HealthTipEntity(
        id: m['id'] as String,
        title: m['title'] as String,
        description: m['description'] as String,
        category: m['category'] as String? ?? 'General',
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
      };
}
