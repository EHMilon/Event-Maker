import 'package:get/get.dart';
import 'profile_controller.dart';

/// Binding for ProfileSettingsView that fetches personal info on init
class ProfileSettingsBinding extends Bindings {
  @override
  void dependencies() {
    // Use put instead of lazyPut to ensure onInit runs
    final controller = Get.put(ProfileController());
    // Fetch personal info when binding is initialized
    controller.fetchPersonalInfo();
  }
}
