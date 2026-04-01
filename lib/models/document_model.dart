/// Document model for provider documents.
/// Matches API response from: api/providers/documents
class DocumentModel {
  final int id;
  final int providerId;
  final String title;
  final String file;
  final String? documentType;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentModel({
    required this.id,
    required this.providerId,
    required this.title,
    required this.file,
    this.documentType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor from API response
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      providerId: json['provider_id'] is int
          ? json['provider_id'] as int
          : int.tryParse(json['provider_id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
      documentType: json['document_type']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'title': title,
      'file': file,
      'document_type': documentType,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get file extension from file path
  String get fileExtension {
    if (file.isEmpty) return '';
    final parts = file.split('.');
    return parts.isNotEmpty ? parts.last.toUpperCase() : '';
  }

  /// Get file name from file path
  String get fileName {
    if (file.isEmpty) return '';
    final parts = file.split('/');
    return parts.isNotEmpty ? parts.last : file;
  }

  /// Check if document is approved
  bool get isApproved => status.toLowerCase() == 'approved';

  /// Check if document is pending
  bool get isPending => status.toLowerCase() == 'pending';

  /// Check if document is rejected
  bool get isRejected => status.toLowerCase() == 'rejected';

  /// Check if file is a PDF
  bool get isPdf => fileExtension == 'PDF';

  /// Check if file is an image
  bool get isImage {
    final ext = fileExtension.toLowerCase();
    return ext == 'png' || ext == 'jpg' || ext == 'jpeg' || ext == 'gif' || ext == 'webp';
  }

  DocumentModel copyWith({
    int? id,
    int? providerId,
    String? title,
    String? file,
    String? documentType,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      file: file ?? this.file,
      documentType: documentType ?? this.documentType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DocumentModel(id: $id, title: $title, status: $status)';
  }
}

/// Response model for list of documents
class DocumentListResponse {
  final bool success;
  final String message;
  final int total;
  final List<DocumentModel> data;

  const DocumentListResponse({
    required this.success,
    required this.message,
    required this.total,
    required this.data,
  });

  factory DocumentListResponse.fromJson(Map<String, dynamic> json) {
    return DocumentListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Request model for creating/updating documents
class DocumentRequest {
  final String title;
  final String? filePath;

  const DocumentRequest({
    required this.title,
    this.filePath,
  });

  Map<String, String> toFields() {
    return {
      'title': title,
    };
  }
}
