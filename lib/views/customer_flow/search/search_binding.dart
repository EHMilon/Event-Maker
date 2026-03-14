import 'package:event_maker/views/customer_flow/search/search_controller.dart';
import 'package:event_maker/views/common/profile/profile_controller.dart';
import 'package:get/get.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure ProfileController is available (it's created in HomeBinding)
    if (!Get.isRegistered<ProfileController>()) {
      Get.put<ProfileController>(ProfileController());
    }
    Get.lazyPut<ServiceSearchController>(() => ServiceSearchController());
  }
}
