import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../shared/utils/user_preferences.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalityController = TextEditingController();
  final captionController = TextEditingController();

  final RxString userName = 'John Doe'.obs;
  final RxString userEmail = 'example@gmail.com'.obs;
  final RxString profileImage = 'assets/images/person.jpg'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    // Simulate network delay as per user rules
    await Future.delayed(const Duration(seconds: 2));

    final userData = await UserPreferences.getUserDetails();
    if (userData != null) {
      userName.value = userData['name'] ?? 'John Doe';
      userEmail.value = userData['email'] ?? 'example@gmail.com';

      nameController.text = userName.value;
      emailController.text = userEmail.value;
      phoneController.text = '000-0000-000'; // Mock data
      nationalityController.text = 'UAE'; // Mock data
    }
    isLoading.value = false;
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2));

    userName.value = nameController.text;
    userEmail.value = emailController.text;

    // TODO: Integrate with backend

    isLoading.value = false;
    Get.back();
    Get.snackbar(
      'Success',
      'Profile updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> logOut() async {
    await UserPreferences.clearUserData();
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nationalityController.dispose();
    captionController.dispose();
    super.onClose();
  }
}
