import 'package:event_maker/views/service_provider_flow/notifications/sp_notification_controller.dart';
import 'package:event_maker/views/service_provider_flow/services/services_controller.dart';
import 'package:get/get.dart';

class SPNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SPNotificationController>(() => SPNotificationController());
    if (!Get.isRegistered<ServicesController>()) {
      Get.lazyPut<ServicesController>(() => ServicesController());
    }
  }
}
