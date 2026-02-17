import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../../shared/utils/logger.dart';
import '../../shared/utils/user_preferences.dart';
import '../../core/routes/app_routes.dart';

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
  final RxBool isLoading = false.obs;

  // ===== User Type Methods =====

  void selectType(String type) {
    selectedType.value = type;
  }

  void onContinueUserType() async {
    if (selectedType.value.isNotEmpty) {
      // Save user type to shared preferences
      await UserPreferences.setUserType(selectedType.value);
      Get.toNamed(AppRoutes.login);
    } else {
      Get.snackbar(
        'error'.tr,
        'pleaseSelectUserType'.tr,
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

  Future<void> onLogin() async {
    if (!await _checkConnectivity()) {
      Get.snackbar(
        'error'.tr,
        'noInternet'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      // TODO: Replace with actual login REST API call
      await Future.delayed(const Duration(seconds: 2));
      await UserPreferences.setLoggedIn(true);
      Get.offAllNamed(AppRoutes.getStarted);
    } catch (e) {
      Log.e('Login failed', e);
      Get.snackbar(
        'error'.tr,
        'loginFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
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

  void onContinueSignup() async {
    // Stage 2: Additional Info
    if (phoneNumber.value.isEmpty) {
      Get.snackbar('error'.tr, 'pleaseEnterPhone'.tr);
      return;
    }

    // Save user type to shared preferences
    if (selectedType.value.isNotEmpty) {
      await UserPreferences.setUserType(selectedType.value);
    }

    if (selectedType.value == 'provider') {
      Get.toNamed(AppRoutes.providerDetails);
    } else {
      // For customer, go straight to get started
      Get.offAllNamed(AppRoutes.getStarted);
    }
  }

  void onContinueProviderDetails() async {
    if (selectedServiceType.value.isEmpty ||
        selectedRole.value.isEmpty ||
        selectedServiceCategory.value.isEmpty) {
      Get.snackbar('error'.tr, 'pleaseSelectAllFields'.tr);
      return;
    }

    // Save user type to shared preferences
    await UserPreferences.setUserType('provider');

    // TODO: Implement actual registration logic for provider
    Get.offAllNamed(AppRoutes.getStarted);
  }

  Future<bool> _checkConnectivity() async {
    final status = await Connectivity().checkConnectivity();
    return status != ConnectivityResult.none;
  }

  void onLoginFromSignup() {
    Get.offAllNamed(AppRoutes.login);
  }

  void onGetStarted() async {
    // Navigate to appropriate home screen based on user type
    String userType = await UserPreferences.getUserType();

    if (userType == UserPreferences.USER_TYPE_SERVICE_PROVIDER) {
      Get.offAllNamed(AppRoutes.serviceProviderHome);
    } else {
      Get.offAllNamed(AppRoutes.customerHome);
    }
  }

  // ===== Forgot Password Methods =====

  void onResetPassword() {
    // TODO: Send OTP logic
    Get.toNamed('/otp-verification');
  }

  // ===== OTP Verification Methods =====

  void onVerify() {
    // TODO: Verify OTP logic
    // Check if this is a change password flow from parameters or state
    String? authFlow = Get.parameters['authFlow'];
    if (authFlow == 'change-password' || currentAuthFlow.value == 'change-password') {
      Get.toNamed('/congratulations');
    } else {
      Get.toNamed('/reset-password-new');
    }
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
    // Navigate based on auth flow - for change password, go to profile
    if (currentAuthFlow.value == 'change-password') {
      currentAuthFlow.value = ''; // Reset auth flow
      Get.offAllNamed('/profile');
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ===== Shared Methods =====

  void goBack() {
    Get.back();
  }
}
