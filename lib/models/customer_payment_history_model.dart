/// Customer Payment History API Models
///
/// Contains data models for the customer payment history endpoint.
/// API Endpoint: GET /payments/customer-history
library;

/// Individual customer payment transaction
class CustomerPaymentTransaction {
  final int id;
  final String bookingCode;
  final String title;
  final String amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String paidAt;
  final String createdAt;

  CustomerPaymentTransaction({
    required this.id,
    required this.bookingCode,
    required this.title,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.paidAt,
    required this.createdAt,
  });

  /// Returns true if this is a paid transaction
  bool get isPaid => status.toLowerCase() == 'paid';

  /// Returns true if this is a pending transaction
  bool get isPending => status.toLowerCase() == 'pending';

  /// Returns true if this is a failed transaction
  bool get isFailed => status.toLowerCase() == 'failed';

  /// Returns formatted amount with currency
  String get formattedAmount => '$amount $currency';

  /// Returns the display time - handles both relative time strings and ISO datetime
  String get displayTime {
    // If it's already a relative time string, return as-is
    if (paidAt.contains('ago') ||
        paidAt.contains('just') ||
        paidAt.contains('yesterday') ||
        paidAt.contains('today')) {
      return paidAt;
    }

    // Try to parse as ISO datetime and format
    try {
      final dt = DateTime.parse(paidAt);
      // Format to relative time
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) {
        return 'Just now';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} minutes ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} hours ago';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return '${(diff.inDays / 7).floor()} weeks ago';
      }
    } catch (_) {
      // If parsing fails, return the string as-is or fallback to created_at
      if (paidAt.isNotEmpty) return paidAt;
      return createdAt;
    }
  }

  factory CustomerPaymentTransaction.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentTransaction(
      id: json['id'] as int? ?? 0,
      bookingCode: json['booking_code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: json['amount'] as String? ?? '0.00',
      currency: json['currency'] as String? ?? 'AED',
      paymentMethod: json['payment_method'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      paidAt: json['paid_at'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

/// Pagination metadata for customer payment history
class CustomerPaymentPagination {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  CustomerPaymentPagination({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  /// Returns true if there are more pages
  bool get hasNext => page < totalPages;

  /// Returns true if there are previous pages
  bool get hasPrevious => page > 1;

  factory CustomerPaymentPagination.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentPagination(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 10,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

/// Complete customer payment history response
class CustomerPaymentHistoryResponse {
  final bool success;
  final String message;
  final CustomerPaymentPagination pagination;
  final List<CustomerPaymentTransaction> data;

  CustomerPaymentHistoryResponse({
    required this.success,
    required this.message,
    required this.pagination,
    required this.data,
  });

  factory CustomerPaymentHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CustomerPaymentHistoryResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      pagination: CustomerPaymentPagination(
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        pageSize: json['page_size'] as int? ?? 10,
        totalPages: json['total_pages'] as int? ?? 1,
      ),
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) => CustomerPaymentTransaction.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}
