import 'package:event_maker/views/service_provider_flow/services/sp_services_controller.dart';
import 'package:event_maker/views/customer_flow/service_booking/payment_controller.dart';
import 'package:event_maker/views/customer_flow/service_booking/booking_controller.dart';
import 'package:event_maker/views/customer_flow/service_booking/service_booking_controller.dart';
import 'package:get/get.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure ServicesController is available for the booking flow
    if (!Get.isRegistered<SPServicesController>()) {
      Get.lazyPut<SPServicesController>(() => SPServicesController());
    }

    // Add Controllers
    Get.lazyPut<PaymentController>(() => PaymentController());
    Get.lazyPut<BookingController>(() => BookingController());
    Get.lazyPut<ServiceBookingController>(() => ServiceBookingController());
  }
}
