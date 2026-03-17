import 'package:event_maker/views/customer_flow/home/customer_home_controller.dart';
import 'package:get/get.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(HomeController());
    }
  }
}
