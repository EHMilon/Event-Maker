import 'package:get/get.dart';
import 'add_service_controller.dart';

/// Binding for add/edit service, event, and training screens
/// Registers all required controllers
/// Uses Get.put to ensure same controller instance is shared across views
class AddScreensBinding implements Bindings {
  @override
  void dependencies() {
    // Use Get.put to immediately create and register the controller
    // This ensures both AddServiceView and PackagesPricingsView use the same instance
    Get.put<AddServiceController>(AddServiceController());
  }
}
