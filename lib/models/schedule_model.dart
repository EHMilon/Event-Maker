import 'package:event_maker/constants/api_constant.dart';

/// Model class representing a scheduled service/event for a provider.
///
/// Backend API contract:
/// ```
/// GET api/bookings/provider/schedule?date=2026-04-10
/// Response: {
///   "success": true,
///   "message": "Provider schedule retrieved successfully.",
///   "date": "2026-04-10",
///   "total": 3,
///   "data": [
///     {
///       "id": 6,
///       "service_title": "Homemade Food Service",
///       "service_image": "/media/services/covers/g17922.png",
///       "booking_date": "10th Apr - Fri",
///       "start_time": "10:00 AM",
///       "end_time": "3:00 PM",
///       "time_range": "10:00 am - 3:00 pm",
///     }
///   ]
/// }
/// ```
class ScheduleModel {
  final int id;
  final String serviceTitle;
  final String? serviceImage;
  final String? bookingDate;
  final String startTime;
  final String endTime;
  final String timeRange;

  const ScheduleModel({
    required this.id,
    required this.serviceTitle,
    this.serviceImage,
    this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.timeRange,
  });

  /// Factory constructor for creating a ScheduleModel from backend JSON response.
  /// API returns time as string (e.g., "10:00 AM") instead of ISO datetime.
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as int? ?? 0,
      serviceTitle: json['service_title'] as String? ?? json['title'] as String? ?? '',
      serviceImage: json['service_image'] as String?,
      bookingDate: json['booking_date'] as String?,
      startTime: json['start_time'] as String? ?? json['startTime'] as String? ?? '',
      endTime: json['end_time'] as String? ?? json['endTime'] as String? ?? '',
      timeRange: json['time_range'] as String? ?? json['timeRange'] as String? ?? '',
    );
  }

  /// Converts the model to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_title': serviceTitle,
      'service_image': serviceImage,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'time_range': timeRange,
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  ScheduleModel copyWith({
    int? id,
    String? serviceTitle,
    String? serviceImage,
    String? bookingDate,
    String? startTime,
    String? endTime,
    String? timeRange,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      serviceImage: serviceImage ?? this.serviceImage,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeRange: timeRange ?? this.timeRange,
    );
  }

  /// Returns the full image URL by prepending media base URL if needed.
  String? get fullImageUrl {
    if (serviceImage == null || serviceImage!.isEmpty) return null;
    return ApiConstant.getFullMediaUrl(serviceImage!);
  }

  /// Legacy getter for backward compatibility with UI
  /// Returns serviceTitle for title display
  String get title => serviceTitle;

  /// Legacy getter for backward compatibility with UI
  /// Returns fullImageUrl for image display
  String? get imageUrl => fullImageUrl;

  /// Legacy getter - returns startTime string
  /// Used in UI as _formatTime(schedule.startTime) expects DateTime
  /// We store as string but UI needs conversion
  String get startTimeString => startTime;

  /// Legacy getter - returns endTime string
  String get endTimeString => endTime;

  /// Legacy getter - returns timeRange for display
  String get timeRangeString => timeRange;

  /// Returns a display-friendly time range string (same as timeRange).
  String get displayTimeRange => timeRange;

  @override
  String toString() {
    return 'ScheduleModel(id: $id, serviceTitle: $serviceTitle, startTime: $startTime, endTime: $endTime)';
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
/// GET api/bookings/provider/schedule?date=2026-04-10
/// Response: {
///   "success": true,
///   "message": "Provider schedule retrieved successfully.",
///   "date": "2026-04-10",
///   "total": 3,
///   "data": [...]
/// }
/// ```
class ScheduleResponse {
  final bool success;
  final String message;
  final String? date;
  final int total;
  final List<ScheduleModel> schedules;

  const ScheduleResponse({
    required this.success,
    required this.message,
    this.date,
    required this.total,
    required this.schedules,
  });

  /// Factory constructor for parsing backend response.
  /// API response structure: { "success": true, "data": [...], "total": 3, ... }
  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    // Handle both "data" and "schedules" keys for backward compatibility
    List<dynamic> schedulesList = [];
    if (json['data'] != null) {
      schedulesList = json['data'] as List<dynamic>? ?? [];
    } else if (json['schedules'] != null) {
      schedulesList = json['schedules'] as List<dynamic>? ?? [];
    }

    return ScheduleResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      date: json['date'] as String?,
      total: json['total'] as int? ?? schedulesList.length,
      schedules: schedulesList
          .map((item) => ScheduleModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Factory for creating mock responses during development.
  factory ScheduleResponse.mock(List<ScheduleModel> schedules) {
    return ScheduleResponse(
      success: true,
      message: 'Mock response',
      total: schedules.length,
      schedules: schedules,
    );
  }

  /// Returns true if the response has no schedules.
  bool get isEmpty => schedules.isEmpty;

  /// Returns true if the response has schedules.
  bool get isNotEmpty => schedules.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'date': date,
      'total': total,
      'data': schedules.map((s) => s.toJson()).toList(),
    };
  }
}
