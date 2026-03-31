/// Lightweight model for My Services list (service provider's services)
/// Contains only essential fields needed for the list view
class MyServiceModel {
  final int id;
  final int providerId;
  final String title;
  final String coverImage;
  final String createdAt;

  const MyServiceModel({
    required this.id,
    required this.providerId,
    required this.title,
    required this.coverImage,
    required this.createdAt,
  });

  /// Factory constructor from API response
  factory MyServiceModel.fromJson(Map<String, dynamic> json) {
    return MyServiceModel(
      id: json['id'] as int? ?? 0,
      providerId: json['provider_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'title': title,
      'cover_image': coverImage,
      'created_at': createdAt,
    };
  }

  /// Create a copy with updated fields
  MyServiceModel copyWith({
    int? id,
    int? providerId,
    String? title,
    String? coverImage,
    String? createdAt,
  }) {
    return MyServiceModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MyServiceModel(id: $id, providerId: $providerId, title: $title, coverImage: $coverImage, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyServiceModel &&
        other.id == id &&
        other.providerId == providerId &&
        other.title == title &&
        other.coverImage == coverImage &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        providerId.hashCode ^
        title.hashCode ^
        coverImage.hashCode ^
        createdAt.hashCode;
  }
}

/// Response wrapper for list of services
class MyServiceListResponse {
  final List<MyServiceModel> services;
  final int? totalCount;
  final int? currentPage;
  final int? totalPages;

  const MyServiceListResponse({
    required this.services,
    this.totalCount,
    this.currentPage,
    this.totalPages,
  });

  factory MyServiceListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? json['results'] as List<dynamic>? ?? [];
    
    return MyServiceListResponse(
      services: dataList
          .map((e) => MyServiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['count'] as int? ?? json['total'] as int?,
      currentPage: json['page'] as int?,
      totalPages: json['total_pages'] as int?,
    );
  }

  bool get isEmpty => services.isEmpty;
  bool get isNotEmpty => services.isNotEmpty;
}
