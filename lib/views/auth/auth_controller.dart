import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/auth_models.dart';
import '../../repository/auth_repository.dart';
import '../../utils/logger.dart';
import '../../utils/user_preferences.dart';
import '../../app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Controllers - using late to prevent early disposal issues
  late final loginEmailController = TextEditingController();
  late final loginPasswordController = TextEditingController();
  late final signupNameController = TextEditingController();
  late final signupEmailController = TextEditingController();
  late final signupPasswordController = TextEditingController();
  late final signupPhoneController = TextEditingController();
  late final forgotEmailController = TextEditingController();
  late final otpController = TextEditingController();
  late final newPasswordController = TextEditingController();
  late final confirmPasswordController = TextEditingController();
  late final currentPasswordController = TextEditingController();
  late final changeNewPasswordController = TextEditingController();
  late final changeConfirmPasswordController = TextEditingController();

  // UI State
  final rememberMe = false.obs;
  final obscurePassword = true.obs;
  final obscureSignupPassword = true.obs;
  final acceptedTerms = false.obs;
  final selectedNationality = 'Bangladeshi'.obs;
  final selectedServiceType = ''.obs;
  final selectedRole = ''.obs;
  final selectedServiceCategory = ''.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final obscureCurrentPassword = true.obs;
  final obscureChangeNewPassword = true.obs;
  final obscureChangeConfirmPassword = true.obs;
  final selectedType = ''.obs;
  final currentAuthFlow = ''.obs;
  final isLoading = false.obs;
  final otpResendTimer = 0.obs;
  final canResendOtp = false.obs;
  final verificationUserId = ''.obs;
  final resetSecretKey = ''.obs;

  Timer? _otpTimer;
  bool _controllersDisposed = false;

  @override
  void onInit() {
    super.onInit();
    _loadPersistedUserId();
  }

  /// Load persisted user ID from SharedPreferences
  Future<void> _loadPersistedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('temp_verification_user_id');
      if (userId != null && userId.isNotEmpty) {
        verificationUserId.value = userId;
      }
    } catch (e) {
      Log.e('Error loading user ID', e);
    }
  }

  /// Persist user ID to SharedPreferences
  Future<void> _persistUserId(String userId) async {
    try {
      verificationUserId.value = userId;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_verification_user_id', userId);
    } catch (e) {
      Log.e('Error persisting user ID', e);
    }
  }

  /// Clear persisted user ID
  Future<void> _clearPersistedUserId() async {
    try {
      verificationUserId.value = '';
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('temp_verification_user_id');
    } catch (e) {
      Log.e('Error clearing user ID', e);
    }
  }

  @override
  void onClose() {
    // Cancel timer only - controllers persist for app lifetime
    _otpTimer?.cancel();
    super.onClose();
  }

  /// Dispose all controllers - call ONLY on app logout/termination
  void disposeAllControllers() {
    if (_controllersDisposed) return;
    _controllersDisposed = true;

    try {
      loginEmailController.dispose();
      loginPasswordController.dispose();
      signupNameController.dispose();
      signupEmailController.dispose();
      signupPasswordController.dispose();
      signupPhoneController.dispose();
      forgotEmailController.dispose();
      otpController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
      currentPasswordController.dispose();
      changeNewPasswordController.dispose();
      changeConfirmPasswordController.dispose();
    } catch (e) {
      Log.e('Error disposing controllers', e);
    }
    _otpTimer?.cancel();
  }

  void selectType(String type) {
    selectedType.value = type;
  }

  /// Restore user type from SharedPreferences
  /// This ensures user type is restored even after password reset flow
  Future<void> restoreUserType() async {
    try {
      final userType = await UserPreferences.getUserType();
      if (userType.isNotEmpty && selectedType.value.isEmpty) {
        selectedType.value = userType;
      }
    } catch (e) {
      Log.e('Error restoring user type', e);
    }
  }

  Future<void> onContinueUserType() async {
    if (selectedType.value.isNotEmpty) {
      await UserPreferences.setUserType(selectedType.value);
      Get.toNamed(AppRoutes.login);
    } else {
      Get.snackbar('Error', 'Please select user type');
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> onLogin() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      // Always try to get user type from SharedPreferences first
      // This ensures user type is restored even after password reset flow
      var userType = await UserPreferences.getUserType();

      // If SharedPreferences returns default 'customer', check if it was actually set
      if (userType == UserPreferences.USER_TYPE_CUSTOMER) {
        final hasUserType = await UserPreferences.hasUserType();
        if (!hasUserType) {
          // User type was not explicitly set, check controller state
          if (selectedType.value.isNotEmpty) {
            userType = selectedType.value;
            await UserPreferences.setUserType(userType);
          } else {
            // No user type found, redirect to user type selection
            Get.snackbar(
              'Error',
              'Please select user type',
              snackPosition: SnackPosition.BOTTOM,
            );
            Get.offAllNamed('/user-type');
            return;
          }
        }
      }

      // Also update controller state to match SharedPreferences
      if (selectedType.value.isEmpty && userType.isNotEmpty) {
        selectedType.value = userType;
      }

      final request = SignInRequestModel(
        role: userType,
        emailAddress: loginEmailController.text.trim(),
        password: loginPasswordController.text,
      );

      final response = await _authRepository.signIn(request);

      if (response.success && response.data != null) {
        loginEmailController.clear();
        loginPasswordController.clear();

        if (userType == UserPreferences.USER_TYPE_SERVICE_PROVIDER) {
          Get.offAllNamed(AppRoutes.serviceProviderHome);
        } else {
          Get.offAllNamed(AppRoutes.customerHome);
        }
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Log.e('Login failed', e);
      Get.snackbar(
        'Error',
        'Login failed',
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

  void toggleSignupPasswordVisibility() {
    obscureSignupPassword.value = !obscureSignupPassword.value;
  }

  void toggleTerms(bool? value) {
    acceptedTerms.value = value ?? false;
  }

  void updateNationality(String? value) {
    if (value != null) selectedNationality.value = value;
  }

  void updatePhoneNumber(String phone) {
    signupPhoneController.text = phone;
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
    if (signupNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter name');
      return;
    }

    if (!GetUtils.isEmail(signupEmailController.text.trim())) {
      Get.snackbar('Error', 'Please enter valid email');
      return;
    }

    if (signupPasswordController.text.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters');
      return;
    }

    if (!acceptedTerms.value) {
      Get.snackbar('Error', 'Please accept terms');
      return;
    }

    Get.toNamed('/signup-step-two');
  }

  Future<void> onContinueSignup() async {
    if (signupPhoneController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter phone');
      return;
    }

    await UserPreferences.setUserType(selectedType.value);

    if (selectedType.value == 'provider') {
      Get.toNamed(AppRoutes.providerDetails);
    } else {
      await _completeCustomerSignup();
    }
  }

  Future<void> onContinueProviderDetails() async {
    if (selectedServiceType.value.isEmpty ||
        selectedRole.value.isEmpty ||
        selectedServiceCategory.value.isEmpty) {
      Get.snackbar('Error', 'Please select all fields');
      return;
    }

    await _completeProviderSignup();
  }

  Future<void> _completeCustomerSignup() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final request = SignUpRequestModel(
        role: 'customer',
        fullName: signupNameController.text.trim(),
        emailAddress: signupEmailController.text.trim(),
        password: signupPasswordController.text,
        nationality: selectedNationality.value,
        phoneNumber: signupPhoneController.text.trim(),
        termsAgreed: true,
      );

      final response = await _authRepository.signUp(request);

      if (response.success && response.data != null) {
        // Persist user ID for verification
        await _persistUserId(response.data!.userId);
        signupPasswordController.clear();
        Get.toNamed('/otp-verification');
        _startOtpTimer();
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Log.e('Customer signup failed', e);
      Get.snackbar(
        'Error',
        'Signup failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _completeProviderSignup() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final request = SignUpRequestModel(
        role: 'provider',
        fullName: signupNameController.text.trim(),
        emailAddress: signupEmailController.text.trim(),
        password: signupPasswordController.text,
        nationality: selectedNationality.value,
        phoneNumber: signupPhoneController.text.trim(),
        termsAgreed: true,
        serviceTypeName: selectedServiceType.value,
        providerType: selectedRole.value,
        serviceCategoryName: selectedServiceCategory.value,
      );

      final response = await _authRepository.signUp(request);

      if (response.success && response.data != null) {
        // Persist user ID for verification
        await _persistUserId(response.data!.userId);
        signupPasswordController.clear();
        Get.toNamed('/otp-verification');
        _startOtpTimer();
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Log.e('Provider signup failed', e);
      Get.snackbar(
        'Error',
        'Signup failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _clearSignupForm() {
    signupNameController.clear();
    signupEmailController.clear();
    signupPasswordController.clear();
    signupPhoneController.clear();
  }

  void onLoginFromSignup() {
    _clearSignupForm();
    _clearPersistedUserId();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> onResetPassword() async {
    if (isLoading.value) return;

    final email = forgotEmailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter valid email');
      return;
    }

    isLoading.value = true;
    try {
      final request = ForgotPasswordRequestModel(emailAddress: email);
      final response = await _authRepository.forgotPassword(request);

      if (response.success && response.data != null) {
        // Persist user ID for verification
        await _persistUserId(response.data!.userId);
        Get.toNamed('/otp-verification');
        _startOtpTimer();
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Log.e('Forgot password failed', e);
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _startOtpTimer() {
    otpResendTimer.value = 60;
    canResendOtp.value = false;

    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpResendTimer.value > 0) {
        otpResendTimer.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> onVerify() async {
    if (isLoading.value) return;

    final otp = otpController.text.trim();
    if (otp.length != 6) {
      Get.snackbar('Error', 'Please enter valid 6-digit OTP');
      return;
    }

    // Check if user ID is available
    if (verificationUserId.value.isEmpty) {
      await _loadPersistedUserId();
      if (verificationUserId.value.isEmpty) {
        Get.snackbar(
          'Error',
          'User ID not found. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    isLoading.value = true;
    try {
      if (currentAuthFlow.value == 'forgot-password') {
        final request = VerifyResetCodeRequestModel(
          userId: verificationUserId.value,
          verificationCode: otp,
        );

        final response = await _authRepository.verifyResetCode(request);

        if (response.success && response.data != null) {
          _otpTimer?.cancel();
          resetSecretKey.value = response.data!.secretKey;
          Get.toNamed('/reset-password-new');
        } else {
          Get.snackbar(
            'Error',
            response.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        final request = VerifyEmailRequestModel(
          userId: verificationUserId.value,
          verificationCode: otp,
        );

        final response = await _authRepository.verifyEmail(request);

        if (response.success && response.data != null) {
          _otpTimer?.cancel();
          _clearPersistedUserId();

          if (response.data!.isProviderPending) {
            Get.toNamed('/request-sent');
          } else {
            Get.offAllNamed(AppRoutes.getStarted);
          }
        } else {
          Get.snackbar(
            'Error',
            response.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e, stackTrace) {
      Log.e('OTP verification failed', e, stackTrace);
      Get.snackbar(
        'Error',
        'Verification failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onResend() async {
    if (!canResendOtp.value) return;

    if (verificationUserId.value.isEmpty) {
      await _loadPersistedUserId();
      if (verificationUserId.value.isEmpty) {
        Get.snackbar(
          'Error',
          'User ID not found. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    isLoading.value = true;
    try {
      final request = ResendVerificationRequestModel(
        userId: verificationUserId.value,
      );

      final response = await _authRepository.resendVerificationCode(request);

      if (response.success) {
        _startOtpTimer();
        Get.snackbar(
          "Success",
          "OTP resent",
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Log.e('Resend OTP failed', e);
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> onConfirmReset() async {
    if (isLoading.value) return;

    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters');
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    if (verificationUserId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'User ID not found. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final request = ResetPasswordRequestModel(
        userId: verificationUserId.value,
        secretKey: resetSecretKey.value,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final response = await _authRepository.resetPassword(request);

      if (response.success) {
        newPasswordController.clear();
        confirmPasswordController.clear();
        otpController.clear();
        forgotEmailController.clear();
        resetSecretKey.value = '';
        _clearPersistedUserId();
        Get.toNamed('/congratulations');
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Log.e('Reset password failed', e);
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleCurrentPasswordVisibility() {
    obscureCurrentPassword.value = !obscureCurrentPassword.value;
  }

  void toggleChangeNewPasswordVisibility() {
    obscureChangeNewPassword.value = !obscureChangeNewPassword.value;
  }

  void toggleChangeConfirmPasswordVisibility() {
    obscureChangeConfirmPassword.value = !obscureChangeConfirmPassword.value;
  }

  Future<void> onChangePassword() async {
    if (isLoading.value) return;

    final currentPassword = currentPasswordController.text;
    final newPassword = changeNewPasswordController.text;
    final confirmPassword = changeConfirmPasswordController.text;

    if (currentPassword.isEmpty) {
      Get.snackbar('Error', 'Please enter current password');
      return;
    }

    if (newPassword.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters');
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      final request = ChangePasswordRequestModel(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final response = await _authRepository.changePassword(request);

      if (response.success) {
        currentPasswordController.clear();
        changeNewPasswordController.clear();
        changeConfirmPasswordController.clear();
        Get.snackbar(
          'Success',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Log.e('Change password failed', e);
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onGoToLogin() {
    if (currentAuthFlow.value == 'change-password') {
      currentAuthFlow.value = '';
      Get.offAllNamed('/profile');
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> onGetStarted() async {
    String userType = await UserPreferences.getUserType();

    if (userType == UserPreferences.USER_TYPE_SERVICE_PROVIDER) {
      Get.offAllNamed(AppRoutes.serviceProviderHome);
    } else {
      Get.offAllNamed(AppRoutes.customerHome);
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authRepository.logout();
      _clearPersistedUserId();
      // Clear user type on logout so user can select again
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');
      // Dispose controllers
      disposeAllControllers();
      // Navigate to onboarding after logout
      Get.offAllNamed(AppRoutes.onboarding);
    } catch (e) {
      Log.e('Logout failed', e);
      // Still clear user type and go to onboarding
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_type');
      } catch (_) {}
      Get.offAllNamed(AppRoutes.onboarding);
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() {
    Get.back();
  }
}
