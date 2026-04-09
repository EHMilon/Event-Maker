/// FAQ model representing a Frequently Asked Question item from the backend.
class FaqModel {
  final int id;
  final String question;
  final String answer;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isExpanded;

  FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.isExpanded = false,
  });

  /// Creates an FaqModel from JSON map
  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      isActive: json['is_active'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isExpanded: false,
    );
  }

  /// Creates a copy of this FaqModel with the given fields replaced
  FaqModel copyWith({
    int? id,
    String? question,
    String? answer,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isExpanded,
  }) {
    return FaqModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// FAQ API response wrapper
class FaqResponse {
  final bool success;
  final String message;
  final List<FaqModel> data;

  FaqResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  /// Creates an FaqResponse from JSON map
  factory FaqResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return FaqResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: dataList
          .map((item) => FaqModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
