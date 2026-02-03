import 'package:get/get.dart';

/// Unified Auth Controller for all authentication screens.
///
/// Handles login, signup, forgot password, OTP verification, and password reset.
class AuthController extends GetxController {
  // Login state
  final RxBool rememberMe = false.obs;
  final RxBool obscurePassword = true.obs;

  // Signup state
  final RxBool obscureSignupPassword = true.obs;
  final RxBool acceptedTerms = false.obs;
  final RxString selectedNationality = 'UAE'.obs;
  final RxString phoneNumber = ''.obs;
  final RxString selectedServiceType = ''.obs;
  final RxString selectedRole = ''.obs;
  final RxString selectedServiceCategory = ''.obs;

  // Reset password state
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  // User Type state
  final RxString selectedType = ''.obs; // 'customer' or 'provider'

  // Auth state
  final RxString currentAuthFlow = ''.obs;

  // ===== User Type Methods =====

  void selectType(String type) {
    selectedType.value = type;
  }

  void onContinueUserType() {
    if (selectedType.value.isNotEmpty) {
      Get.toNamed('/login');
    } else {
      Get.snackbar(
        "Error",
        "Please select a user type",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ===== Login Methods =====

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void onLogin() {
    // TODO: Implement actual login logic
    Get.offAllNamed('/get-started');
  }

  void onForgotPassword() {
    currentAuthFlow.value = 'forgot-password';
    Get.toNamed('/forgot-password');
  }

  void onSignUp() {
    currentAuthFlow.value = 'signup';
    Get.toNamed('/signup');
  }

  // ===== Signup Methods =====

  void toggleSignupPasswordVisibility() {
    obscureSignupPassword.value = !obscureSignupPassword.value;
  }

  void toggleTerms(bool? value) {
    acceptedTerms.value = value ?? false;
  }

  void updateNationality(String? value) {
    if (value != null) selectedNationality.value = value;
  }

  void updatePhoneNumber(String value) {
    phoneNumber.value = value;
  }

  void updateServiceType(String? value) {
    if (value != null) selectedServiceType.value = value;
  }

  void updateRole(String? value) {
    if (value != null) selectedRole.value = value;
  }

  void updateServiceCategory(String? value) {
    if (value != null) selectedServiceCategory.value = value;
  }

  void onSignup() {
    // Stage 1: Basic Info
    Get.toNamed('/signup-step-two');
  }

  void onContinueSignup() {
    // Stage 2: Additional Info
    if (phoneNumber.value.isEmpty) {
      Get.snackbar("Error", "Please enter your phone number");
      return;
    }

    if (selectedType.value == 'provider') {
      Get.toNamed('/provider-details');
    } else {
      // For customer, go straight to get started
      Get.offAllNamed('/get-started');
    }
  }

  void onContinueProviderDetails() {
    if (selectedServiceType.value.isEmpty ||
        selectedRole.value.isEmpty ||
        selectedServiceCategory.value.isEmpty) {
      Get.snackbar("Error", "Please select all fields");
      return;
    }
    // TODO: Implement actual registration logic for provider
    Get.offAllNamed('/get-started');
  }

  void onLoginFromSignup() {
    Get.offAllNamed('/login');
  }

  void onGetStarted() {
    // Navigate to Get Started screen after successful login/signup
    Get.offAllNamed('/home'); // Or wherever the home screen is
  }

  // ===== Forgot Password Methods =====

  void onResetPassword() {
    // TODO: Send OTP logic
    Get.toNamed('/otp-verification');
  }

  // ===== OTP Verification Methods =====

  void onVerify() {
    // TODO: Verify OTP logic
    Get.toNamed('/reset-password-new');
  }

  void onResend() {
    // TODO: Resend OTP
    Get.snackbar("OTP", "OTP resent");
  }

  // ===== Reset Password Methods =====

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void onConfirmReset() {
    // TODO: Reset password logic
    Get.toNamed('/congratulations');
  }

  void onGoToLogin() {
    Get.offAllNamed('/login');
  }

  // ===== Shared Methods =====

  void goBack() {
    Get.back();
  }
}
