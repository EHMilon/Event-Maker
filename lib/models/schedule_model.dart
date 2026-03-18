// No imports needed - model uses only Dart core types

/// Model class representing a scheduled service/event for a provider.
///
/// Backend API contract:
/// ```
/// GET /api/v1/provider/schedule?date=2024-01-15
/// Response: {
///   "schedules": [ScheduleModel.toJson()],
///   "has_more": false,
///   "next_cursor": "xxx"
/// }
/// ```
class ScheduleModel {
  final String id;
  final String title;
  final String? imageUrl;
  final DateTime startTime;
  final DateTime endTime;

  const ScheduleModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.startTime,
    required this.endTime,
  });

  /// Factory constructor for creating a ScheduleModel from backend JSON response.
  ///
  /// Backend developer: Ensure the API returns fields matching these keys.
  /// All datetime fields should be in ISO 8601 format.
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      imageUrl: json['image_url'],
      startTime: _parseDateTime(json['start_time']),
      endTime: _parseDateTime(json['end_time']),
    );
  }

  /// Converts the model to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  ScheduleModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  /// Returns the duration of the scheduled service.
  Duration get duration => endTime.difference(startTime);

  /// Returns true if the schedule is for today.
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  /// Returns true if the schedule is in the past.
  bool get isPast => endTime.isBefore(DateTime.now());

  /// Returns true if the schedule is currently active (in progress).
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Returns a display-friendly time range string.
  String get timeRangeString {
    final startStr = _formatTime(startTime);
    final endStr = _formatTime(endTime);
    return '$startStr - $endStr';
  }

  /// Helper method to parse datetime from various formats.
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  /// Helper to format time in 12-hour format.
  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  @override
  String toString() {
    return 'ScheduleModel(id: $id, title: $title, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Response wrapper for schedule list.
///
/// Backend API contract:
/// ```
/// GET /api/v1/provider/schedule?date=2024-01-15
/// Response: { "schedules": [...] }
/// ```
class ScheduleResponse {
  final List<ScheduleModel> schedules;

  const ScheduleResponse({required this.schedules});

  /// Factory constructor for parsing backend response.
  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    final schedulesList = json['schedules'] as List<dynamic>? ?? [];
    return ScheduleResponse(
      schedules: schedulesList
          .map((item) => ScheduleModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Factory for creating mock responses during development.
  factory ScheduleResponse.mock(List<ScheduleModel> schedules) {
    return ScheduleResponse(schedules: schedules);
  }

  /// Returns true if the response has no schedules.
  bool get isEmpty => schedules.isEmpty;

  /// Returns true if the response has schedules.
  bool get isNotEmpty => schedules.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'schedules': schedules.map((s) => s.toJson()).toList(),
    };
  }
}
