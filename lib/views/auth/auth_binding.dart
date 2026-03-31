

import 'package:event_maker/controllers/auth_controller.dart';
import 'package:get/get.dart';

/// Unified binding for all authentication screens.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
