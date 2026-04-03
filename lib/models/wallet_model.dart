/// Provider Wallet History API Models
/// 
/// Contains data models for the provider wallet history endpoint.
/// API Endpoint: GET /payments/provider-wallet-history
library;

/// Customer info nested in transaction
class WalletCustomer {
  final int id;
  final String name;
  final String email;

  WalletCustomer({
    required this.id,
    required this.name,
    required this.email,
  });

  factory WalletCustomer.fromJson(Map<String, dynamic> json) {
    return WalletCustomer(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }
}

/// Payment info nested in transaction
class WalletPayment {
  final int id;
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;
  final String? gatewayPaymentIntent;
  final String? paidAt;

  WalletPayment({
    required this.id,
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionId,
    this.gatewayPaymentIntent,
    this.paidAt,
  });

  factory WalletPayment.fromJson(Map<String, dynamic> json) {
    return WalletPayment(
      id: json['id'] as int? ?? 0,
      paymentMethod: json['payment_method'] as String? ?? '',
      paymentStatus: json['payment_status'] as String? ?? '',
      transactionId: json['transaction_id'] as String?,
      gatewayPaymentIntent: json['gateway_payment_intent'] as String?,
      paidAt: json['paid_at'] as String?,
    );
  }
}

/// Individual wallet transaction/entry
class WalletTransaction {
  final int id;
  final int providerWalletId;
  final int? bookingId;
  final String? bookingCode;
  final int? paymentId;
  final String transactionType; // credit, debit, withdrawal
  final String amount;
  final String currency;
  final String status; // success, pending, failed
  final String? description;
  final String? groupReference;
  final String createdAt;
  final WalletCustomer? customer;
  final WalletPayment? payment;

  WalletTransaction({
    required this.id,
    required this.providerWalletId,
    this.bookingId,
    this.bookingCode,
    this.paymentId,
    required this.transactionType,
    required this.amount,
    required this.currency,
    required this.status,
    this.description,
    this.groupReference,
    required this.createdAt,
    this.customer,
    this.payment,
  });

  /// Returns true if this is a credit transaction
  bool get isCredit => transactionType == 'credit';

  /// Returns true if this is a debit transaction
  bool get isDebit => transactionType == 'debit';

  /// Returns formatted amount with sign
  String get formattedAmount {
    final prefix = isCredit ? '+' : '-';
    return '$prefix$amount $currency';
  }

  /// Returns the display time - handles both relative time strings and ISO datetime
  /// API now returns strings like "21 hours ago" directly
  String get displayTime {
    // If it's already a relative time string, return as-is
    if (createdAt.contains('ago') || 
        createdAt.contains('just') ||
        createdAt.contains('yesterday') ||
        createdAt.contains('today')) {
      return createdAt;
    }
    
    // Try to parse as ISO datetime and format
    try {
      final dt = DateTime.parse(createdAt);
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
      // If parsing fails, return the string as-is or fallback to paid_at
      if (createdAt.isNotEmpty) return createdAt;
      return payment?.paidAt ?? 'Unknown';
    }
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as int? ?? 0,
      providerWalletId: json['provider_wallet_id'] as int? ?? 0,
      bookingId: json['booking_id'] as int?,
      bookingCode: json['booking_code'] as String?,
      paymentId: json['payment_id'] as int?,
      transactionType: json['transaction_type'] as String? ?? 'credit',
      amount: json['amount'] as String? ?? '0.00',
      currency: json['currency'] as String? ?? 'AED',
      status: json['status'] as String? ?? 'success',
      description: json['description'] as String?,
      groupReference: json['group_reference'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      customer: json['customer'] != null
          ? WalletCustomer.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      payment: json['payment'] != null
          ? WalletPayment.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Pagination metadata for wallet history
class WalletPagination {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final String? next;
  final String? previous;

  WalletPagination({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    this.next,
    this.previous,
  });

  /// Returns true if there are more pages
  bool get hasNext => next != null;

  /// Returns true if there are previous pages
  bool get hasPrevious => previous != null;

  factory WalletPagination.fromJson(Map<String, dynamic> json) {
    return WalletPagination(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 10,
      totalPages: json['total_pages'] as int? ?? 1,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
    );
  }
}

/// Wallet history list with pagination
class WalletHistory {
  final WalletPagination pagination;
  final List<WalletTransaction> transactions;

  WalletHistory({
    required this.pagination,
    required this.transactions,
  });

  factory WalletHistory.fromJson(Map<String, dynamic> json) {
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? json;
    return WalletHistory(
      pagination: WalletPagination.fromJson(paginationJson),
      transactions: (json['data'] as List<dynamic>?)
              ?.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Wallet summary/overview data
class WalletSummary {
  final int walletId;
  final int providerId;
  final String currency;
  final String totalEarned;
  final String totalWithdrawn;
  final String availableBalance;
  final String pendingBalance;
  final String createdAt;
  final String updatedAt;

  WalletSummary({
    required this.walletId,
    required this.providerId,
    required this.currency,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.availableBalance,
    required this.pendingBalance,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse amount string to double
  double get totalEarnedAmount => double.tryParse(totalEarned) ?? 0.0;
  double get totalWithdrawnAmount => double.tryParse(totalWithdrawn) ?? 0.0;
  double get availableBalanceAmount => double.tryParse(availableBalance) ?? 0.0;
  double get pendingBalanceAmount => double.tryParse(pendingBalance) ?? 0.0;

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      walletId: json['wallet_id'] as int? ?? 0,
      providerId: json['provider_id'] as int? ?? 0,
      currency: json['currency'] as String? ?? 'AED',
      totalEarned: json['total_earned'] as String? ?? '0.00',
      totalWithdrawn: json['total_withdrawn'] as String? ?? '0.00',
      availableBalance: json['available_balance'] as String? ?? '0.00',
      pendingBalance: json['pending_balance'] as String? ?? '0.00',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

/// Complete wallet history response
class WalletHistoryResponse {
  final bool success;
  final String message;
  final WalletSummary? summary;
  final WalletHistory? history;

  WalletHistoryResponse({
    required this.success,
    required this.message,
    this.summary,
    this.history,
  });

  factory WalletHistoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return WalletHistoryResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      summary: data['summary'] != null
          ? WalletSummary.fromJson(data['summary'] as Map<String, dynamic>)
          : null,
      history: data['history'] != null
          ? WalletHistory.fromJson(data['history'] as Map<String, dynamic>)
          : null,
    );
  }
}
