import 'package:get/get.dart';

class UserTypeController extends GetxController {
  final RxString selectedType = ''.obs; // 'customer' or 'provider'

  void selectType(String type) {
    selectedType.value = type;
  }

  void onContinue() {
    if (selectedType.value.isNotEmpty) {
      // Navigate to Login/Home
      Get.snackbar(
        "Selection",
        "You selected ${selectedType.value}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Error",
        "Please select a user type",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
