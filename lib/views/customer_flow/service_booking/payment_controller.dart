import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/models/customer_booking_model.dart';
import 'package:event_maker/services/customer_booking_repository.dart';
import 'package:event_maker/services/payment_repository.dart';
import 'package:event_maker/app_routes.dart';
import 'package:get/get.dart';

/// Controller for Payment screen handling Stripe and PayPal integration.
///
/// Manages payment method selection, checkout session creation, and URL launching.
class PaymentController extends GetxController {
  final isLoading = true.obs;
  final isProcessingPayment = false.obs;
  final selectedPaymentMethod = 0.obs; // 0: Stripe, 1: PayPal
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  ServiceModel? service;
  ServicePackage? selectedPackage;
  int? bookingId;
  CustomerBookingDetail? bookingDetail;

  // Booking date/time from arguments or API (reactive for Obx)
  final bookingDate = ''.obs;
  final bookingTime = ''.obs;
  final bookingLocation = ''.obs;

  final CustomerBookingRepository _repository = CustomerBookingRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  @override
  void onInit() {
    super.onInit();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    isLoading.value = true;
    errorMessage.value = '';

    // Get arguments passed from previous screen
    final args = Get.arguments;

    if (args is Map) {
      // Check if we have booking_id (from notification click)
      bookingId = args['booking_id'] as int?;

      if (bookingId != null) {
        // Fetch booking details from API
        await _fetchBookingDetails();
      } else {
        // Normal flow - get service and package from arguments
        service = args['service'] as ServiceModel?;
        selectedPackage = args['package'] as ServicePackage?;
      }

      // Get booking date/time from arguments
      bookingDate.value = args['booking_date'] as String? ?? '';
      bookingTime.value = args['booking_time'] as String? ?? '';
      bookingLocation.value = args['location'] as String? ?? '';
    } else if (args is ServiceModel) {
      // Fallback for safety
      service = args;
      selectedPackage = null;
    }

    isLoading.value = false;
  }

  Future<void> _fetchBookingDetails() async {
    if (bookingId == null) return;

    try {
      final response = await _repository.fetchBookingDetail(bookingId!);
      bookingDetail = response.data;

      // Convert CustomerBookingDetail to ServiceModel for display
      // The payment screen expects ServiceModel, so we create one from booking detail
      service = ServiceModel(
        id: bookingDetail!.serviceId.toString(),
        title: bookingDetail!.title,
        description: '',
        images: [],
        type: ServiceType.event,
        provider: ServiceProvider(
          name: bookingDetail!.provider.fullName,
          role: 'Service Provider',
          imageUrl: bookingDetail!.provider.avatar ?? '',
          isVerified: false,
        ),
        location: bookingDetail!.location,
        rating: null,
        reviewCount: null,
        date: null,
        basePrice: double.tryParse(bookingDetail!.totalAmount),
        priceUnit: bookingDetail!.currency,
        packages: [],
        isBookmarked: false,
      );

      // Create package from booking
      if (bookingDetail!.selectedPackage != null) {
        selectedPackage = ServicePackage(
          id: bookingDetail!.selectedPackage!.id,
          name: bookingDetail!.selectedPackage!.name,
          price: bookingDetail!.selectedPackage!.price,
        );
      }

      // Get date/time from booking detail
      bookingDate.value = bookingDetail!.bookingDate ?? '';
      bookingTime.value = bookingDetail!.startTime ?? '';
      bookingLocation.value = bookingDetail!.location ?? '';
    } catch (e) {
      errorMessage.value = 'Failed to load booking details';
    }
  }

  void selectPaymentMethod(int index) {
    selectedPaymentMethod.value = index;
  }

  /// Processes payment by creating checkout session/order and opening payment URL.
  ///
  /// For Stripe (index 0): Creates checkout session and opens Stripe checkout URL.
  /// For PayPal (index 1): Creates order and opens PayPal approval URL.
  ///
  /// Opens payment page inside the app using WebView for better UX and
  /// to detect payment completion via URL monitoring.
  Future<void> processPayment() async {
    // Validate booking ID exists
    if (bookingId == null) {
      errorMessage.value = 'Booking ID is required for payment';
      _showErrorSnackbar('Booking ID is required');
      return;
    }

    isProcessingPayment.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      String checkoutUrl;
      String paymentMethod = selectedPaymentMethodName;

      if (selectedPaymentMethod.value == 0) {
        // Stripe payment
        checkoutUrl = await _processStripePayment();
      } else {
        // PayPal payment
        checkoutUrl = await _processPayPalPayment();
        paymentMethod = 'PayPal';
      }

      if (checkoutUrl.isNotEmpty) {
        // Navigate to WebView payment screen
        _openWebViewPayment(checkoutUrl, paymentMethod);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      _showErrorSnackbar(errorMessage.value);
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Processes Stripe payment by creating checkout session.
  Future<String> _processStripePayment() async {
    try {
      final response = await _paymentRepository.createStripeCheckoutSession(
        bookingId: bookingId!,
      );

      if (response.success && response.data != null) {
        successMessage.value = response.message;
        return response.data!.checkoutUrl;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      // Re-throw to be handled by processPayment
      rethrow;
    }
  }

  /// Processes PayPal payment by creating order.
  Future<String> _processPayPalPayment() async {
    try {
      final response = await _paymentRepository.createPayPalOrder(
        bookingId: bookingId!,
      );

      if (response.success && response.data != null) {
        successMessage.value = response.message;
        return response.data!.approvalUrl;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      // Re-throw to be handled by processPayment
      rethrow;
    }
  }

  /// Opens the payment checkout URL in WebView.
  ///
  /// The WebView will monitor URL changes to detect payment success/cancel
  /// and automatically navigate to the appropriate screen.
  void _openWebViewPayment(String checkoutUrl, String paymentMethod) {
    // Navigate to WebView payment screen
    Get.toNamed(
      AppRoutes.webviewPayment,
      arguments: {
        'checkout_url': checkoutUrl,
        'booking_id': bookingId,
        'payment_method': paymentMethod,
      },
    );
  }

  /// Shows error snackbar with the given message.
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Payment Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  /// Gets the selected payment method name.
  String get selectedPaymentMethodName =>
      selectedPaymentMethod.value == 0 ? 'Stripe' : 'PayPal';

  /// Checks if booking is ready for payment.
  bool get canProcessPayment => bookingId != null;
}
