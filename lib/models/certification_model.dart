/// Certification model for provider certificates.
/// Matches API response from: api/providers/certificates
class CertificationModel {
  final int id;
  final int providerId;
  final String title;
  final String institute;
  final String issueDate;
  final String file;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CertificationModel({
    required this.id,
    required this.providerId,
    required this.title,
    required this.institute,
    required this.issueDate,
    required this.file,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor from API response
  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      providerId: json['provider_id'] is int ? json['provider_id'] as int : int.tryParse(json['provider_id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      institute: json['institute']?.toString() ?? '',
      issueDate: json['issue_date']?.toString() ?? '',
      file: json['file']?.toString() ?? '',
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
      'institute': institute,
      'issue_date': issueDate,
      'file': file,
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

  /// Check if file is a PDF
  bool get isPdf => fileExtension == 'PDF';

  /// Check if file is an image
  bool get isImage {
    final ext = fileExtension.toLowerCase();
    return ext == 'png' || ext == 'jpg' || ext == 'jpeg' || ext == 'gif' || ext == 'webp';
  }

  /// Format issue date for display (from YYYY-MM-DD to readable format)
  String get formattedIssueDate {
    if (issueDate.isEmpty) return '';
    try {
      final date = DateTime.parse(issueDate);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[date.month - 1]}, ${date.year}';
    } catch (e) {
      return issueDate;
    }
  }

  /// Format issue date for form input (from YYYY-MM-DD to DD/MM/YYYY)
  String get issueDateForForm {
    if (issueDate.isEmpty) return '';
    try {
      final date = DateTime.parse(issueDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return issueDate;
    }
  }

  CertificationModel copyWith({
    int? id,
    int? providerId,
    String? title,
    String? institute,
    String? issueDate,
    String? file,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CertificationModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      institute: institute ?? this.institute,
      issueDate: issueDate ?? this.issueDate,
      file: file ?? this.file,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CertificationModel(id: $id, title: $title, institute: $institute)';
  }
}

/// Response model for list of certifications
class CertificationListResponse {
  final bool success;
  final String message;
  final List<CertificationModel> data;

  const CertificationListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CertificationListResponse.fromJson(Map<String, dynamic> json) {
    return CertificationListResponse(
      success: json['success'] is bool ? json['success'] as bool : false,
      message: json['message']?.toString() ?? '',
      data: json['data'] is List
          ? (json['data'] as List<dynamic>)
              .map((e) => CertificationModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

/// Request model for creating/updating certifications
class CertificationRequest {
  final String title;
  final String institute;
  final String issueDate;
  final String? filePath;

  const CertificationRequest({
    required this.title,
    required this.institute,
    required this.issueDate,
    this.filePath,
  });

  Map<String, String> toFields() {
    return {
      'title': title,
      'institute': institute,
      'issue_date': issueDate,
    };
  }
}
