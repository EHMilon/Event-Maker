/// Provider Home API Response Models
///
/// Contains data models for the provider home endpoint.
/// API Endpoint: GET /providers/home
///
/// Response Structure:
/// {
///   "success": true,
///   "message": "Provider home data retrieved successfully.",
///   "data": {
///     "this_month_earning": { ... },
///     "analytics": { ... },
///     "total_balance": { ... },
///     "active_orders": { ... }
///   }
/// }
library;

/// This month's earning data
class ThisMonthEarning {
  final String amount;
  final String currency;
  final double growthPercent;

  ThisMonthEarning({
    required this.amount,
    required this.currency,
    required this.growthPercent,
  });

  factory ThisMonthEarning.fromJson(Map<String, dynamic> json) {
    return ThisMonthEarning(
      amount: json['amount'] as String? ?? '0',
      currency: json['currency'] as String? ?? 'AED',
      growthPercent: (json['growth_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Get formatted amount with currency
  String get formattedAmount => '$amount $currency';
}

/// Analytics stat item (for total_earnings, total_requests, completed, pending)
class AnalyticsStat {
  final dynamic value; // Can be String or int
  final String? currency;
  final double growthPercent;

  AnalyticsStat({
    required this.value,
    this.currency,
    required this.growthPercent,
  });

  factory AnalyticsStat.fromJson(Map<String, dynamic> json) {
    return AnalyticsStat(
      value: json['value'] ?? 0,
      currency: json['currency'] as String?,
      growthPercent: (json['growth_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Get display value with currency if applicable
  String get displayValue {
    if (currency != null) {
      return '$value $currency';
    }
    return value.toString();
  }

  /// Get numeric value for calculations
  int get numericValue {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

/// Provider analytics data
class ProviderAnalytics {
  final String basedOn;
  final AnalyticsStat totalEarnings;
  final AnalyticsStat totalRequests;
  final AnalyticsStat completed;
  final AnalyticsStat pending;

  ProviderAnalytics({
    required this.basedOn,
    required this.totalEarnings,
    required this.totalRequests,
    required this.completed,
    required this.pending,
  });

  factory ProviderAnalytics.fromJson(Map<String, dynamic> json) {
    return ProviderAnalytics(
      basedOn: json['based_on'] as String? ?? 'last_30_days',
      totalEarnings: AnalyticsStat.fromJson(
        json['total_earnings'] as Map<String, dynamic>? ?? {},
      ),
      totalRequests: AnalyticsStat.fromJson(
        json['total_requests'] as Map<String, dynamic>? ?? {},
      ),
      completed: AnalyticsStat.fromJson(
        json['completed'] as Map<String, dynamic>? ?? {},
      ),
      pending: AnalyticsStat.fromJson(
        json['pending'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Total balance/wallet summary
class TotalBalance {
  final String totalEarned;
  final String totalWithdrawn;
  final String availableBalance;
  final String pendingBalance;
  final String currency;

  TotalBalance({
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.availableBalance,
    required this.pendingBalance,
    required this.currency,
  });

  factory TotalBalance.fromJson(Map<String, dynamic> json) {
    return TotalBalance(
      totalEarned: json['total_earned'] as String? ?? '0.00',
      totalWithdrawn: json['total_withdrawn'] as String? ?? '0.00',
      availableBalance: json['available_balance'] as String? ?? '0.00',
      pendingBalance: json['pending_balance'] as String? ?? '0.00',
      currency: json['currency'] as String? ?? 'AED',
    );
  }

  /// Get formatted available balance
  String get formattedAvailableBalance => '$availableBalance $currency';

  /// Get formatted total earned
  String get formattedTotalEarned => '$totalEarned $currency';
}

/// Individual booking within a service group
class ActiveBooking {
  final int id;
  final String bookingCode;
  final int serviceId;
  final String serviceTitle;
  final String serviceImage;
  final String customerName;
  final String customerEmail;
  final String? customerAvatar;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status;
  final String paymentStatus;
  final String currency;
  final String totalAmount;
  final int guestCount;
  final String eventAddress;
  final String createdAt;

  ActiveBooking({
    required this.id,
    required this.bookingCode,
    required this.serviceId,
    required this.serviceTitle,
    required this.serviceImage,
    required this.customerName,
    required this.customerEmail,
    required this.customerAvatar,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.paymentStatus,
    required this.currency,
    required this.totalAmount,
    required this.guestCount,
    required this.eventAddress,
    required this.createdAt,
  });

  factory ActiveBooking.fromJson(Map<String, dynamic> json) {
    return ActiveBooking(
      id: json['id'] as int? ?? 0,
      bookingCode: json['booking_code'] as String? ?? '',
      serviceId: json['service_id'] as int? ?? 0,
      serviceTitle: json['service_title'] as String? ?? '',
      serviceImage: json['service_image'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      customerEmail: json['customer_email'] as String? ?? '',
      customerAvatar: json['customer_avatar'] as String? ?? '',
      bookingDate: json['booking_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      status: json['status'] as String? ?? '',
      paymentStatus: json['payment_status'] as String? ?? '',
      currency: json['currency'] as String? ?? 'AED',
      totalAmount: json['total_amount'] as String? ?? '0.00',
      guestCount: json['guest_count'] as int? ?? 0,
      eventAddress: json['event_address'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  /// Get formatted date range for display
  String get formattedDateTime => '$startTime - $endTime, $bookingDate';

  /// Get formatted amount
  String get formattedAmount => '$totalAmount $currency';
}

/// Service group containing multiple bookings
class ServiceOrderGroup {
  final String groupKey;
  final int serviceId;
  final String serviceTitle;
  final int totalBookings;
  final String serviceImage;
  final List<ActiveBooking> bookings;

  ServiceOrderGroup({
    required this.groupKey,
    required this.serviceId,
    required this.serviceTitle,
    required this.totalBookings,
    required this.serviceImage,
    required this.bookings,
  });

  factory ServiceOrderGroup.fromJson(Map<String, dynamic> json) {
    return ServiceOrderGroup(
      groupKey: json['group_key'] as String? ?? '',
      serviceId: json['service_id'] as int? ?? 0,
      serviceTitle: json['service_title'] as String? ?? '',
      totalBookings: json['total_bookings'] as int? ?? 0,
      serviceImage: json['service_image'] as String? ?? '',
      bookings:
          (json['bookings'] as List<dynamic>?)
              ?.map((e) => ActiveBooking.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Active orders section data
class ActiveOrders {
  final int total;
  final List<ServiceOrderGroup> results;

  ActiveOrders({required this.total, required this.results});

  factory ActiveOrders.fromJson(Map<String, dynamic> json) {
    return ActiveOrders(
      total: json['total'] as int? ?? 0,
      results:
          (json['results'] as List<dynamic>?)
              ?.map(
                (e) => ServiceOrderGroup.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

/// Complete Provider Home Data
class ProviderHomeData {
  final ThisMonthEarning thisMonthEarning;
  final ProviderAnalytics analytics;
  final TotalBalance totalBalance;
  final ActiveOrders activeOrders;

  ProviderHomeData({
    required this.thisMonthEarning,
    required this.analytics,
    required this.totalBalance,
    required this.activeOrders,
  });

  factory ProviderHomeData.fromJson(Map<String, dynamic> json) {
    return ProviderHomeData(
      thisMonthEarning: ThisMonthEarning.fromJson(
        json['this_month_earning'] as Map<String, dynamic>? ?? {},
      ),
      analytics: ProviderAnalytics.fromJson(
        json['analytics'] as Map<String, dynamic>? ?? {},
      ),
      totalBalance: TotalBalance.fromJson(
        json['total_balance'] as Map<String, dynamic>? ?? {},
      ),
      activeOrders: ActiveOrders.fromJson(
        json['active_orders'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Empty instance for initialization
  factory ProviderHomeData.empty() {
    return ProviderHomeData(
      thisMonthEarning: ThisMonthEarning(
        amount: '0',
        currency: 'AED',
        growthPercent: 0,
      ),
      analytics: ProviderAnalytics(
        basedOn: 'last_30_days',
        totalEarnings: AnalyticsStat(
          value: '0',
          currency: 'AED',
          growthPercent: 0,
        ),
        totalRequests: AnalyticsStat(value: 0, growthPercent: 0),
        completed: AnalyticsStat(value: 0, growthPercent: 0),
        pending: AnalyticsStat(value: 0, growthPercent: 0),
      ),
      totalBalance: TotalBalance(
        totalEarned: '0.00',
        totalWithdrawn: '0.00',
        availableBalance: '0.00',
        pendingBalance: '0.00',
        currency: 'AED',
      ),
      activeOrders: ActiveOrders(total: 0, results: []),
    );
  }
}

/// Provider Home API Response wrapper
class ProviderHomeResponse {
  final bool success;
  final String message;
  final ProviderHomeData data;

  ProviderHomeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProviderHomeResponse.fromJson(Map<String, dynamic> json) {
    return ProviderHomeResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: ProviderHomeData.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
