import 'package:event_maker/views/service_provider_flow/services/services_controller.dart';
import 'package:get/get.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure ServicesController is available for the booking flow
    if (!Get.isRegistered<ServicesController>()) {
      Get.lazyPut<ServicesController>(() => ServicesController());
    }
  }
}
