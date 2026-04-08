/// Payment Models for Stripe and PayPal Integration
///
/// Contains data models for payment checkout sessions and order responses.
library;

/// Response model for Stripe checkout session creation
class StripeCheckoutResponse {
  final bool success;
  final String message;
  final StripeCheckoutData? data;

  StripeCheckoutResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory StripeCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return StripeCheckoutResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? StripeCheckoutData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Data returned from Stripe checkout session creation
class StripeCheckoutData {
  final int paymentId;
  final String sessionId;
  final String checkoutUrl;

  StripeCheckoutData({
    required this.paymentId,
    required this.sessionId,
    required this.checkoutUrl,
  });

  factory StripeCheckoutData.fromJson(Map<String, dynamic> json) {
    return StripeCheckoutData(
      paymentId: json['payment_id'] as int? ?? 0,
      sessionId: json['session_id'] as String? ?? '',
      checkoutUrl: json['checkout_url'] as String? ?? '',
    );
  }
}

/// Response model for PayPal order creation
class PayPalOrderResponse {
  final bool success;
  final String message;
  final PayPalOrderData? data;

  PayPalOrderResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PayPalOrderResponse.fromJson(Map<String, dynamic> json) {
    return PayPalOrderResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? PayPalOrderData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Data returned from PayPal order creation
class PayPalOrderData {
  final int paymentId;
  final String orderId;
  final String approvalUrl;

  PayPalOrderData({
    required this.paymentId,
    required this.orderId,
    required this.approvalUrl,
  });

  factory PayPalOrderData.fromJson(Map<String, dynamic> json) {
    return PayPalOrderData(
      paymentId: json['payment_id'] as int? ?? 0,
      orderId: json['order_id'] as String? ?? json['id'] as String? ?? '',
      approvalUrl: json['approval_url'] as String? ?? json['approveUrl'] as String? ?? '',
    );
  }
}
