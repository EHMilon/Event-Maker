/// Booking Notification Model for Service Provider booking notifications.
/// Matches API response from: GET api/bookings/provider/booking-notification
class BookingNotificationModel {
  final int id;
  final String title;
  final String createdAt;
  final BookingNotificationCustomer customer;

  const BookingNotificationModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.customer,
  });

  factory BookingNotificationModel.fromJson(Map<String, dynamic> json) {
    return BookingNotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      customer: BookingNotificationCustomer.fromJson(
        json['customer'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt,
      'customer': customer.toJson(),
    };
  }
}

/// Customer info embedded in booking notification
class BookingNotificationCustomer {
  final int id;
  final String fullName;
  final String? avatar;

  const BookingNotificationCustomer({
    required this.id,
    required this.fullName,
    this.avatar,
  });

  factory BookingNotificationCustomer.fromJson(Map<String, dynamic> json) {
    return BookingNotificationCustomer(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar': avatar,
    };
  }
}

/// Response model for booking notification list
class BookingNotificationListResponse {
  final bool success;
  final String message;
  final int total;
  final List<BookingNotificationModel> data;

  const BookingNotificationListResponse({
    required this.success,
    required this.message,
    required this.total,
    required this.data,
  });

  factory BookingNotificationListResponse.fromJson(Map<String, dynamic> json) {
    return BookingNotificationListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => BookingNotificationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
