import 'package:get/get.dart';
import 'sp_home_controller.dart';

class ServiceProviderHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SPHomeController>(() => SPHomeController());
  }
}
