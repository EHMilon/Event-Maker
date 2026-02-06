import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/service_model.dart';
import '../../data/mock/mock_data.dart';
import '../../shared/utils/user_preferences.dart';

class ProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalityController = TextEditingController();
  final captionController = TextEditingController();

  // Change Password Controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Password visibility states
  final RxBool isCurrentPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // Toggle visibility methods
  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  final RxString userName = 'John Doe'.obs;
  final RxString userEmail = 'example@gmail.com'.obs;
  final RxString profileImage = 'assets/images/person.jpg'.obs;
  final RxBool isLoading = false.obs;

  // Mock data lists
  final RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;
  final RxList<ServiceModel> bookmarks = <ServiceModel>[].obs;
  final RxList<Map<String, dynamic>> faqs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadMockData();
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

  void loadMockData() {
    transactions.assignAll([
      {'title': 'Catering Service', 'time': 'Just Now', 'amount': '105'},
      {'title': 'Photography Package', 'time': '5 min ago', 'amount': '250'},
      {'title': 'Atif Aslam Concert', 'time': '2 days ago', 'amount': '350'},
      {'title': 'Videography Session', 'time': '10 days ago', 'amount': '400'},
      {'title': 'Deep Cleaning', 'time': '15 days ago', 'amount': '150'},
      {'title': 'Music Event', 'time': '28 days ago', 'amount': '500'},
    ]);

    // Use bookmarked services from centralized mock data
    bookmarks.assignAll(MockData.bookmarkedServices);

    faqs.assignAll([
      {
        'question': 'What payment methods do you accept?',
        'answer':
            'We accept online payment platforms such as PayPal & Stripe. Additional payment options may be available depending on your region.',
        'isExpanded': false.obs,
      },
      {
        'question': 'Is my payment information secure?',
        'answer':
            'Yes, we use industry-standard encryption for all transactions.',
        'isExpanded': false.obs,
      },
      {
        'question': 'Can I request a refund if needed?',
        'answer':
            'Refund policies vary depending on the service provider. Please check the contract.',
        'isExpanded': false.obs,
      },
      {
        'question': 'Will I receive an invoice for my payment?',
        'answer':
            'Yes, we will send an automated invoice once the booking is confirmed.',
        'isExpanded': false.obs,
      },
    ]);
  }

  Future<void> changePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    // TODO: Validate current password with backend
    // Navigate to OTP verification for password change with auth flow parameter
    Get.toNamed(
      '/otp-verification',
      parameters: {'authFlow': 'change-password'},
    );
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
