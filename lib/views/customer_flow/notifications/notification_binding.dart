import 'package:get/get.dart';
import 'notification_controller.dart';

class CustomerNotificationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerNotificationController>(() => CustomerNotificationController());
  }
}