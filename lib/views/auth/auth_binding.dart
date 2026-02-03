import 'package:get/get.dart';
import 'auth_controller.dart';

/// Unified binding for all authentication screens.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
