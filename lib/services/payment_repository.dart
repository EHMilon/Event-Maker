import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/models/payment_models.dart';
import 'package:event_maker/services/api_service.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/utils/logger.dart';

/// Repository for Payment Gateway Integration (Stripe & PayPal)
///
/// Handles creating checkout sessions and orders for payment processing.
class PaymentRepository {
  final ApiService _apiService;

  PaymentRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Creates a Stripe checkout session for the given booking.
  ///
  /// POST /payments/stripe/create-checkout-session
  /// Body: { "booking_id": int }
  ///
  /// Returns [StripeCheckoutResponse] containing:
  /// - payment_id: Database payment record ID
  /// - session_id: Stripe checkout session ID
  /// - checkout_url: URL to redirect user for payment
  Future<StripeCheckoutResponse> createStripeCheckoutSession({
    required int bookingId,
  }) async {
    try {
      Log.d(
        '=======> PaymentRepository: Creating Stripe checkout session for booking $bookingId',
      );

      final response = await _apiService.post(
        ApiConstant.stripeCreateCheckoutSession,
        body: {'booking_id': bookingId},
      );

      Log.d(
        '=======> PaymentRepository: Stripe checkout response: $response',
      );

      return StripeCheckoutResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e(
        '=======> PaymentRepository: ApiException creating Stripe session: ${e.message}',
      );
      rethrow;
    } catch (e) {
      Log.e(
        '=======> PaymentRepository: Error creating Stripe checkout session: $e',
      );
      throw ApiException(
        message: 'Failed to create Stripe checkout session: $e',
      );
    }
  }

  /// Creates a PayPal order for the given booking.
  ///
  /// POST /payments/paypal/create-order
  /// Body: { "booking_id": int }
  ///
  /// Returns [PayPalOrderResponse] containing:
  /// - payment_id: Database payment record ID
  /// - order_id: PayPal order ID
  /// - approval_url: URL to redirect user for payment approval
  Future<PayPalOrderResponse> createPayPalOrder({
    required int bookingId,
  }) async {
    try {
      Log.d(
        '=======> PaymentRepository: Creating PayPal order for booking $bookingId',
      );

      final response = await _apiService.post(
        ApiConstant.paypalCreateOrder,
        body: {'booking_id': bookingId},
      );

      Log.d(
        '=======> PaymentRepository: PayPal order response: $response',
      );

      return PayPalOrderResponse.fromJson(response);
    } on ApiException catch (e) {
      Log.e(
        '=======> PaymentRepository: ApiException creating PayPal order: ${e.message}',
      );
      rethrow;
    } catch (e) {
      Log.e(
        '=======> PaymentRepository: Error creating PayPal order: $e',
      );
      throw ApiException(
        message: 'Failed to create PayPal order: $e',
      );
    }
  }
}
