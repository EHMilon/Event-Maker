import 'package:get/get.dart';
import 'service_provider_controller.dart';
import 'home/sp_home_controller.dart';
import '../profile/profile_controller.dart';

class ServiceProviderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceProviderController>(() => ServiceProviderController());
    Get.lazyPut<SPHomeController>(() => SPHomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
