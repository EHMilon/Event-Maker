import 'package:event_maker/views/service_provider_flow/notifications/notification_controller.dart';
import 'package:event_maker/views/service_provider_flow/services/services_controller.dart';
import 'package:get/get.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationController());
    // Ensure ServicesController is available for payment navigation
    if (!Get.isRegistered<ServicesController>()) {
      Get.lazyPut<ServicesController>(() => ServicesController());
    }
  }
}
