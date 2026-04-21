import 'package:get/get.dart';
import 'auth_controller.dart';

/// Unified binding for all authentication screens.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
  }
}
