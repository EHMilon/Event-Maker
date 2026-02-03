import 'package:get/get.dart';
import 'user_type_controller.dart';

class UserTypeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UserTypeController());
  }
}
