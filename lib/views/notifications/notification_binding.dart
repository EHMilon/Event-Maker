import 'package:event_maker/views/service_provider_flow/services/services_controller.dart';
import 'package:get/get.dart';

import 'customer_notification_controller.dart';
import 'notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
    if (!Get.isRegistered<ServicesController>()) {
      Get.lazyPut<ServicesController>(() => ServicesController());
    }
  }
}

class CustomerNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerNotificationController>(
      () => CustomerNotificationController(),
    );
  }
}
