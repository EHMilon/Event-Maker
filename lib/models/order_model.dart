class OrderModel {
  final String id;
  final String title;
  final String imageUrl;
  final int badgeCount;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.badgeCount,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      badgeCount: json['badge_count'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
