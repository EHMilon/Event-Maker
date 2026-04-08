/// Customer Booking Models
/// Matches API responses from customer booking endpoints
library;

/// Customer Booking item in list
class CustomerBookingItem {
  final int id;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String servicesDuration;
  final String title;
  final String location;
  final String subtotal;
  final String serviceFee;
  final String totalAmount;
  final String currency;
  final String status;
  final String paymentStatus;
  final CustomerBookingServiceInfo service;
  final CustomerBookingPackageInfo? selectedPackage;
  final String createdAt;
  final String updatedAt;

  const CustomerBookingItem({
    required this.id,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.servicesDuration,
    required this.title,
    required this.location,
    required this.subtotal,
    required this.serviceFee,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    required this.service,
    this.selectedPackage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerBookingItem.fromJson(Map<String, dynamic> json) {
    return CustomerBookingItem(
      id: json['id'] as int? ?? 0,
      bookingDate: json['booking_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      servicesDuration: json['services_duration'] as String? ?? '',
      title: json['title'] as String? ?? '',
      location: json['location'] as String? ?? '',
      subtotal: json['subtotal'] as String? ?? '0.00',
      serviceFee: json['service_fee'] as String? ?? '0.00',
      totalAmount: json['total_amount'] as String? ?? '0.00',
      currency: json['currency'] as String? ?? 'AED',
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      service: CustomerBookingServiceInfo.fromJson(
        json['service'] as Map<String, dynamic>? ?? {},
      ),
      selectedPackage: json['selected_package'] != null
          ? CustomerBookingPackageInfo.fromJson(
              json['selected_package'] as Map<String, dynamic>,
            )
          : null,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'services_duration': servicesDuration,
      'title': title,
      'location': location,
      'subtotal': subtotal,
      'service_fee': serviceFee,
      'total_amount': totalAmount,
      'currency': currency,
      'status': status,
      'payment_status': paymentStatus,
      'service': service.toJson(),
      'selected_package': selectedPackage?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Check if booking is pending
  bool get isPending => status == 'pending';

  /// Check if booking is accepted
  bool get isAccepted => status == 'accepted';

  /// Check if booking is completed
  bool get isCompleted => status == 'completed';

  /// Get formatted date time
  String get displayDateTime => '$bookingDate - $startTime';

  /// Get total amount with currency
  String get displayTotal => '$totalAmount $currency';
}

/// Customer Booking Detail (full response from send-booking-request or detail endpoint)
class CustomerBookingDetail {
  final int id;
  final String bookingCode;
  final int customerId;
  final int providerId;
  final int serviceId;
  final int? selectedPackageId;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String servicesDuration;
  final String? specialRequest;
  final String title;
  final int? guestCount;
  final String location;
  final String? latitude;
  final String? longitude;
  final String subtotal;
  final String serviceFee;
  final String totalAmount;
  final String currency;
  final String status;
  final String paymentStatus;
  final bool requiresConfirmation;
  final bool canPayNow;
  final String? acceptedAt;
  final String? rejectedAt;
  final String? completedAt;
  final String? cancelledAt;
  final String? cancelReason;
  final CustomerBookingProviderInfo provider;
  final CustomerBookingServiceInfo service;
  final CustomerBookingPackageInfo? selectedPackage;
  final String createdAt;
  final String updatedAt;

  const CustomerBookingDetail({
    required this.id,
    required this.bookingCode,
    required this.customerId,
    required this.providerId,
    required this.serviceId,
    this.selectedPackageId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.servicesDuration,
    this.specialRequest,
    required this.title,
    this.guestCount,
    required this.location,
    this.latitude,
    this.longitude,
    required this.subtotal,
    required this.serviceFee,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    required this.requiresConfirmation,
    required this.canPayNow,
    this.acceptedAt,
    this.rejectedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelReason,
    required this.provider,
    required this.service,
    this.selectedPackage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerBookingDetail.fromJson(Map<String, dynamic> json) {
    return CustomerBookingDetail(
      id: json['id'] as int? ?? 0,
      bookingCode: json['booking_code'] as String? ?? '',
      customerId: json['customer_id'] as int? ?? 0,
      providerId: json['provider_id'] as int? ?? 0,
      serviceId: json['service_id'] as int? ?? 0,
      selectedPackageId: json['selected_package_id'] as int?,
      bookingDate: json['booking_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      servicesDuration: json['services_duration'] as String? ?? '',
      specialRequest: json['special_request'] as String?,
      title: json['title'] as String? ?? '',
      guestCount: json['guest_count'] as int?,
      location: json['location'] as String? ?? '',
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      subtotal: json['subtotal'] as String? ?? '0.00',
      serviceFee: json['service_fee'] as String? ?? '0.00',
      totalAmount: json['total_amount'] as String? ?? '0.00',
      currency: json['currency'] as String? ?? 'AED',
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      requiresConfirmation: json['requires_confirmation'] as bool? ?? false,
      canPayNow: json['can_pay_now'] as bool? ?? false,
      acceptedAt: json['accepted_at'] as String?,
      rejectedAt: json['rejected_at'] as String?,
      completedAt: json['completed_at'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      cancelReason: json['cancel_reason'] as String?,
      provider: CustomerBookingProviderInfo.fromJson(
        json['provider'] as Map<String, dynamic>? ?? {},
      ),
      service: CustomerBookingServiceInfo.fromJson(
        json['service'] as Map<String, dynamic>? ?? {},
      ),
      selectedPackage: json['selected_package'] != null
          ? CustomerBookingPackageInfo.fromJson(
              json['selected_package'] as Map<String, dynamic>,
            )
          : null,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_code': bookingCode,
      'customer_id': customerId,
      'provider_id': providerId,
      'service_id': serviceId,
      'selected_package_id': selectedPackageId,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'services_duration': servicesDuration,
      'special_request': specialRequest,
      'title': title,
      'guest_count': guestCount,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'subtotal': subtotal,
      'service_fee': serviceFee,
      'total_amount': totalAmount,
      'currency': currency,
      'status': status,
      'payment_status': paymentStatus,
      'requires_confirmation': requiresConfirmation,
      'can_pay_now': canPayNow,
      'accepted_at': acceptedAt,
      'rejected_at': rejectedAt,
      'completed_at': completedAt,
      'cancelled_at': cancelledAt,
      'cancel_reason': cancelReason,
      'provider': provider.toJson(),
      'service': service.toJson(),
      'selected_package': selectedPackage?.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Check if booking is pending
  bool get isPending => status == 'pending';

  /// Check if booking is accepted
  bool get isAccepted => status == 'accepted';

  /// Check if booking is rejected
  bool get isRejected => status == 'rejected';

  /// Check if booking is completed
  bool get isCompleted => status == 'completed';

  /// Get formatted date time
  String get displayDateTime => '$bookingDate - $startTime - $endTime';

  /// Get total amount with currency
  String get displayTotal => '$totalAmount $currency';
}

/// Booking Notification Model
class CustomerBookingNotification {
  final int id;
  final String bookingCode;
  final int customerId;
  final int providerId;
  final int serviceId;
  final String title;
  final String? acceptedAt;
  final String? rejectedAt;
  final CustomerBookingCustomer customer;
  final CustomerBookingProviderInfo provider;
  final CustomerBookingServiceInfo service;

  const CustomerBookingNotification({
    required this.id,
    required this.bookingCode,
    required this.customerId,
    required this.providerId,
    required this.serviceId,
    required this.title,
    this.acceptedAt,
    this.rejectedAt,
    required this.customer,
    required this.provider,
    required this.service,
  });

  factory CustomerBookingNotification.fromJson(Map<String, dynamic> json) {
    return CustomerBookingNotification(
      id: json['id'] as int? ?? 0,
      bookingCode: json['booking_code'] as String? ?? '',
      customerId: json['customer_id'] as int? ?? 0,
      providerId: json['provider_id'] as int? ?? 0,
      serviceId: json['service_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      acceptedAt: json['accepted_at'] as String?,
      rejectedAt: json['rejected_at'] as String?,
      customer: CustomerBookingCustomer.fromJson(
        json['customer'] as Map<String, dynamic>? ?? {},
      ),
      provider: CustomerBookingProviderInfo.fromJson(
        json['provider'] as Map<String, dynamic>? ?? {},
      ),
      service: CustomerBookingServiceInfo.fromJson(
        json['service'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_code': bookingCode,
      'customer_id': customerId,
      'provider_id': providerId,
      'service_id': serviceId,
      'title': title,
      'accepted_at': acceptedAt,
      'rejected_at': rejectedAt,
      'customer': customer.toJson(),
      'provider': provider.toJson(),
      'service': service.toJson(),
    };
  }

  /// Check if booking was accepted
  bool get isAccepted => acceptedAt != null;

  /// Check if booking was rejected
  bool get isRejected => rejectedAt != null;
}

/// Service info embedded in customer booking
class CustomerBookingServiceInfo {
  final int id;
  final String title;
  final String coverImage;

  const CustomerBookingServiceInfo({
    required this.id,
    required this.title,
    required this.coverImage,
  });

  factory CustomerBookingServiceInfo.fromJson(Map<String, dynamic> json) {
    return CustomerBookingServiceInfo(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'cover_image': coverImage};
  }
}

/// Provider info embedded in customer booking
class CustomerBookingProviderInfo {
  final int id;
  final String fullName;
  final String email;
  final String? avatar;
  final String ratingAvg;
  final int totalReviews;

  const CustomerBookingProviderInfo({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
    this.ratingAvg = '0.00',
    this.totalReviews = 0,
  });

  factory CustomerBookingProviderInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomerBookingProviderInfo(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String?,
      ratingAvg: json['rating_avg'] as String? ?? '0.00',
      totalReviews: json['total_reviews'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'avatar': avatar,
      'rating_avg': ratingAvg,
      'total_reviews': totalReviews,
    };
  }

  /// Get rating as double
  double get ratingValue => double.tryParse(ratingAvg) ?? 0.0;
}

/// Customer info (for notifications)
class CustomerBookingCustomer {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatar;

  const CustomerBookingCustomer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatar,
  });

  factory CustomerBookingCustomer.fromJson(Map<String, dynamic> json) {
    return CustomerBookingCustomer(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
    };
  }
}

/// Package info embedded in booking
class CustomerBookingPackageInfo {
  final int id;
  final String name;
  final String price;

  const CustomerBookingPackageInfo({
    required this.id,
    required this.name,
    required this.price,
  });

  factory CustomerBookingPackageInfo.fromJson(Map<String, dynamic> json) {
    return CustomerBookingPackageInfo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      price: json['price'] as String? ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price};
  }

  /// Get price as double
  double get priceValue => double.tryParse(price) ?? 0.0;
}

/// Response model for customer booking list
class CustomerBookingListResponse {
  final bool success;
  final String message;
  final int total;
  final List<CustomerBookingItem> data;

  const CustomerBookingListResponse({
    required this.success,
    required this.message,
    required this.total,
    required this.data,
  });

  factory CustomerBookingListResponse.fromJson(Map<String, dynamic> json) {
    return CustomerBookingListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) => CustomerBookingItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

/// Response model for customer booking detail
class CustomerBookingDetailResponse {
  final bool success;
  final String message;
  final CustomerBookingDetail data;

  const CustomerBookingDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CustomerBookingDetailResponse.fromJson(Map<String, dynamic> json) {
    return CustomerBookingDetailResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: CustomerBookingDetail.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Response model for customer booking notifications
class CustomerBookingNotificationListResponse {
  final bool success;
  final String message;
  final int total;
  final List<CustomerBookingNotification> data;

  const CustomerBookingNotificationListResponse({
    required this.success,
    required this.message,
    required this.total,
    required this.data,
  });

  factory CustomerBookingNotificationListResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomerBookingNotificationListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) => CustomerBookingNotification.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}
