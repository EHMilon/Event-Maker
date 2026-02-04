import 'package:event_maker/views/customer_flow/customer_flow_controller.dart';
import 'package:event_maker/views/customer_flow/home/home_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerFlowController>(() => CustomerFlowController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
