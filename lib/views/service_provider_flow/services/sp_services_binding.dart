import 'package:event_maker/views/service_provider_flow/services/sp_services_controller.dart';
import 'package:get/get.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SPServicesController>(() => SPServicesController());
  }
}
