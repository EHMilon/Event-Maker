import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/models/customer_booking_model.dart';
import 'package:event_maker/services/customer_booking_repository.dart';
import 'package:event_maker/app_routes.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  final isLoading = true.obs;
  final selectedPaymentMethod = 0.obs; // 0: Stripe, 1: Paypal
  final errorMessage = ''.obs;

  ServiceModel? service;
  ServicePackage? selectedPackage;
  int? bookingId;
  CustomerBookingDetail? bookingDetail;

  // Booking date/time from arguments or API (reactive for Obx)
  final bookingDate = ''.obs;
  final bookingTime = ''.obs;
  final bookingLocation = ''.obs;

  final CustomerBookingRepository _repository = CustomerBookingRepository();

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

  void processPayment() {
    // TODO: Integrate with backend payment gateway (Stripe/Paypal)

    // For now, just navigate to confirmation
    Get.toNamed(AppRoutes.paymentConfirmation);
  }
}
