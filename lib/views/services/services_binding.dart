import 'package:event_maker/views/services/services_controller.dart';
import 'package:get/get.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServicesController>(() => ServicesController());
  }
}
