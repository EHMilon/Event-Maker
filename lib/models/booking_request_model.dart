/// Booking Request Model for Service Provider booking requests.
/// Matches API response from: GET api/bookings/provider/booking-request
class BookingRequestModel {
  final int id;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String servicesDuration;
  final String title;
  final String status;
  final BookingServiceInfo service;

  const BookingRequestModel({
    required this.id,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.servicesDuration,
    required this.title,
    required this.status,
    required this.service,
  });

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestModel(
      id: json['id'] as int? ?? 0,
      bookingDate: json['booking_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      servicesDuration: json['services_duration'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      service: BookingServiceInfo.fromJson(
        json['service'] as Map<String, dynamic>? ?? {},
      ),
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
      'status': status,
      'service': service.toJson(),
    };
  }

  /// Get formatted date time for display
  String get displayDateTime => '$bookingDate - $startTime';
}

/// Service info embedded in booking request
class BookingServiceInfo {
  final int id;
  final String title;
  final String coverImage;

  const BookingServiceInfo({
    required this.id,
    required this.title,
    required this.coverImage,
  });

  factory BookingServiceInfo.fromJson(Map<String, dynamic> json) {
    return BookingServiceInfo(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      coverImage: json['cover_image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cover_image': coverImage,
    };
  }
}

/// Booking Request Details Model.
/// Matches API response from: GET api/bookings/provider/booking-request/{id}
class BookingRequestDetailModel {
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
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final BookingCustomerInfo customer;
  final BookingProviderInfo provider;
  final BookingServiceInfo service;
  final BookingPackageInfo? selectedPackage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingRequestDetailModel({
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
    required this.customer,
    required this.provider,
    required this.service,
    this.selectedPackage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingRequestDetailModel.fromJson(Map<String, dynamic> json) {
    return BookingRequestDetailModel(
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
      acceptedAt: json['accepted_at'] != null
          ? DateTime.tryParse(json['accepted_at'] as String)
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.tryParse(json['rejected_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'] as String)
          : null,
      cancelReason: json['cancel_reason'] as String?,
      customer: BookingCustomerInfo.fromJson(
        json['customer'] as Map<String, dynamic>? ?? {},
      ),
      provider: BookingProviderInfo.fromJson(
        json['provider'] as Map<String, dynamic>? ?? {},
      ),
      service: BookingServiceInfo.fromJson(
        json['service'] as Map<String, dynamic>? ?? {},
      ),
      selectedPackage: json['selected_package'] != null
          ? BookingPackageInfo.fromJson(
              json['selected_package'] as Map<String, dynamic>,
            )
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
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
      'accepted_at': acceptedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancel_reason': cancelReason,
      'customer': customer.toJson(),
      'provider': provider.toJson(),
      'service': service.toJson(),
      'selected_package': selectedPackage?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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

  /// Check if booking is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Get formatted date time for display
  String get displayDateTime => '$bookingDate - $startTime - $endTime';

  /// Get total amount with currency
  String get displayTotal => '$totalAmount $currency';

  /// Get subtotal with currency
  String get displaySubtotal => '$subtotal $currency';
}

/// Customer info embedded in booking detail
class BookingCustomerInfo {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatar;

  const BookingCustomerInfo({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.avatar,
  });

  factory BookingCustomerInfo.fromJson(Map<String, dynamic> json) {
    return BookingCustomerInfo(
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

/// Provider info embedded in booking detail
class BookingProviderInfo {
  final int id;
  final String fullName;
  final String email;
  final String? avatar;
  final String ratingAvg;
  final int totalReviews;

  const BookingProviderInfo({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
    this.ratingAvg = '0.00',
    this.totalReviews = 0,
  });

  factory BookingProviderInfo.fromJson(Map<String, dynamic> json) {
    return BookingProviderInfo(
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

/// Package info embedded in booking detail
class BookingPackageInfo {
  final int id;
  final String name;
  final String price;

  const BookingPackageInfo({
    required this.id,
    required this.name,
    required this.price,
  });

  factory BookingPackageInfo.fromJson(Map<String, dynamic> json) {
    return BookingPackageInfo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      price: json['price'] as String? ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  /// Get price as double
  double get priceValue => double.tryParse(price) ?? 0.0;
}

/// Response model for booking request list
class BookingRequestListResponse {
  final bool success;
  final String message;
  final int total;
  final List<BookingRequestModel> data;

  const BookingRequestListResponse({
    required this.success,
    required this.message,
    required this.total,
    required this.data,
  });

  factory BookingRequestListResponse.fromJson(Map<String, dynamic> json) {
    return BookingRequestListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      total: json['total'] as int? ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => BookingRequestModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Response model for booking request detail
class BookingRequestDetailResponse {
  final bool success;
  final String message;
  final BookingRequestDetailModel data;

  const BookingRequestDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BookingRequestDetailResponse.fromJson(Map<String, dynamic> json) {
    return BookingRequestDetailResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: BookingRequestDetailModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

