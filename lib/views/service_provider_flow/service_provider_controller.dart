import 'package:event_maker/views/service_provider_flow/notifications/notification_controller.dart';
import 'package:get/get.dart';

class ServiceProviderController extends GetxController {
  final _selectedIndex = 0.obs;
  int get selectedIndex => _selectedIndex.value;

  void changeIndex(int index) {
    _selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
