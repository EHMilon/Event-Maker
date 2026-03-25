import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/auth_models.dart';
import '../../repository/auth_repository.dart';
import '../../utils/logger.dart';
import '../../utils/user_preferences.dart';
import '../../app_routes.dart';

/// Unified Auth Controller for all authentication screens.
///
/// Handles login, signup, forgot password, OTP verification, and password reset.
/// Uses AuthRepository for all backend API calls.
class AuthController extends GetxController {
  // Repository instance
  final AuthRepository _authRepository = AuthRepository();

  // ===== TextEditingControllers =====
  
  // Login
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  
  // Signup Step 1
  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  
  // Signup Step 2
  final signupPhoneController = TextEditingController();
  
  // Forgot Password
  final forgotEmailController = TextEditingController();
  
  // OTP Verification
  final otpController = TextEditingController();
  
  // Reset Password
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ===== UI State =====
  
  // Login state
  final RxBool rememberMe = false.obs;
  final RxBool obscurePassword = true.obs;

  // Signup state
  final RxBool obscureSignupPassword = true.obs;
  final RxBool acceptedTerms = false.obs;
  final RxString selectedNationality = 'UAE'.obs;
  final RxString selectedServiceType = ''.obs;
  final RxString selectedRole = ''.obs;
  final RxString selectedServiceCategory = ''.obs;

  // Reset password state
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  // User Type state
  final RxString selectedType = ''.obs; // 'customer' or 'provider'

  // Auth flow state
  final RxString currentAuthFlow = ''.obs;
  final RxBool isLoading = false.obs;
  
  // Signup data aggregation
  final Rx<SignupRequestModel?> signupData = Rx<SignupRequestModel?>(null);
  
  // OTP state
  final RxInt otpResendTimer = 0.obs;
  final RxBool canResendOtp = false.obs;
  Timer? _otpTimer;
  
  // Email for OTP verification flow
  final RxString verificationEmail = ''.obs;

  // ===== Lifecycle =====
  
  @override
  void onClose() {
    // Dispose all controllers
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
    
    _otpTimer?.cancel();
    super.onClose();
  }

  // ===== User Type Methods =====

  void selectType(String type) {
    selectedType.value = type;
  }

  Future<void> onContinueUserType() async {
    if (selectedType.value.isNotEmpty) {
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
    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      final request = LoginRequestModel(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text,
        rememberMe: rememberMe.value,
      );

      final response = await _authRepository.login(request);

      if (response.success) {
        // Clear form
        loginEmailController.clear();
        loginPasswordController.clear();
        
        // Navigate based on user type
        final userType = await UserPreferences.getUserType();
        if (userType == UserPreferences.USER_TYPE_SERVICE_PROVIDER) {
          Get.offAllNamed(AppRoutes.serviceProviderHome);
        } else {
          Get.offAllNamed(AppRoutes.customerHome);
        }
      } else {
        Get.snackbar(
          'error'.tr,
          response.message.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
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

  /// Validate and proceed to step 2 of signup
  void onSignup() {
    // Validate step 1
    if (signupNameController.text.trim().isEmpty) {
      Get.snackbar('error'.tr, 'pleaseEnterName'.tr);
      return;
    }
    
    if (!GetUtils.isEmail(signupEmailController.text.trim())) {
      Get.snackbar('error'.tr, 'pleaseEnterValidEmail'.tr);
      return;
    }
    
    if (signupPasswordController.text.length < 6) {
      Get.snackbar('error'.tr, 'passwordMinLength'.tr);
      return;
    }
    
    if (!acceptedTerms.value) {
      Get.snackbar('error'.tr, 'pleaseAcceptTerms'.tr);
      return;
    }

    // Initialize signup data
    signupData.value = SignupRequestModel(
      name: signupNameController.text.trim(),
      email: signupEmailController.text.trim(),
      password: signupPasswordController.text,
      userType: selectedType.value,
      acceptedTerms: true,
    );

    Get.toNamed('/signup-step-two');
  }

  /// Continue to provider details or complete signup
  Future<void> onContinueSignup() async {
    if (signupPhoneController.text.trim().isEmpty) {
      Get.snackbar('error'.tr, 'pleaseEnterPhone'.tr);
      return;
    }

    // Update signup data with step 2 info
    signupData.value = signupData.value?.copyWith(
      nationality: selectedNationality.value,
      phone: signupPhoneController.text.trim(),
    );

    // Save user type
    await UserPreferences.setUserType(selectedType.value);

    if (selectedType.value == 'provider') {
      Get.toNamed(AppRoutes.providerDetails);
    } else {
      // For customer, complete registration
      await _completeSignup();
    }
  }

  /// Complete provider details and register
  Future<void> onContinueProviderDetails() async {
    if (selectedServiceType.value.isEmpty ||
        selectedRole.value.isEmpty ||
        selectedServiceCategory.value.isEmpty) {
      Get.snackbar('error'.tr, 'pleaseSelectAllFields'.tr);
      return;
    }

    // Update signup data with provider details
    signupData.value = signupData.value?.copyWith(
      serviceType: selectedServiceType.value,
      role: selectedRole.value,
      serviceCategory: selectedServiceCategory.value,
    );

    await _completeSignup();
  }

  /// Complete the signup process
  Future<void> _completeSignup() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    try {
      final response = await _authRepository.signup(signupData.value!);

      if (response.success) {
        // Clear form
        _clearSignupForm();
        
        // Navigate to get started
        Get.offAllNamed(AppRoutes.getStarted);
      } else {
        Get.snackbar(
          'error'.tr,
          response.message.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Log.e('Signup failed', e);
      Get.snackbar(
        'error'.tr,
        'signupFailed'.tr,
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
    signupData.value = null;
    acceptedTerms.value = false;
  }

  void onLoginFromSignup() {
    _clearSignupForm();
    Get.offAllNamed(AppRoutes.login);
  }

  // ===== Forgot Password Methods =====

  Future<void> onResetPassword() async {
    if (isLoading.value) return;
    
    final email = forgotEmailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar('error'.tr, 'pleaseEnterValidEmail'.tr);
      return;
    }

    // Store email for OTP verification
    verificationEmail.value = email;

    isLoading.value = true;
    try {
      final request = ForgotPasswordRequestModel(email: email);
      final response = await _authRepository.forgotPassword(request);

      if (response.success) {
        Get.toNamed('/otp-verification');
        _startOtpTimer();
      } else {
        Get.snackbar(
          'error'.tr,
          response.message.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Log.e('Forgot password failed', e);
      Get.snackbar(
        'error'.tr,
        'somethingWentWrong'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===== OTP Verification Methods =====

  void _startOtpTimer() {
    otpResendTimer.value = 60; // 60 seconds countdown
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
    if (otp.length < 4) {
      Get.snackbar('error'.tr, 'pleaseEnterValidOtp'.tr);
      return;
    }

    isLoading.value = true;
    try {
      final request = OTPVerificationRequestModel(
        email: verificationEmail.value,
        otp: otp,
        purpose: currentAuthFlow.value == 'change-password' 
            ? 'password_reset' 
            : 'email_verification',
      );

      final response = await _authRepository.verifyOTP(request);

      if (response.success) {
        _otpTimer?.cancel();
        
        // Check if this is a change password flow
        String? authFlow = Get.parameters['authFlow'];
        if (authFlow == 'change-password' || currentAuthFlow.value == 'change-password') {
          Get.toNamed('/congratulations');
        } else {
          Get.toNamed('/reset-password-new');
        }
      } else {
        Get.snackbar(
          'error'.tr,
          response.message.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Log.e('OTP verification failed', e);
      Get.snackbar(
        'error'.tr,
        'verificationFailed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onResend() async {
    if (!canResendOtp.value) return;
    
    isLoading.value = true;
    try {
      final request = ResendOTPRequestModel(
        email: verificationEmail.value,
        purpose: currentAuthFlow.value == 'change-password' 
            ? 'password_reset' 
            : 'email_verification',
      );

      final response = await _authRepository.resendOTP(request);

      if (response.success) {
        _startOtpTimer();
        Get.snackbar("OTP", "otpResent".tr);
      } else {
        Get.snackbar(
          'error'.tr,
          response.message.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Log.e('Resend OTP failed', e);
      Get.snackbar(
        'error'.tr,
        'somethingWentWrong'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===== Reset Password Methods =====

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

    if (newPassword.length < 6) {
      Get.snackbar('error'.tr, 'passwordMinLength'.tr);
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar('error'.tr, 'passwordsDoNotMatch'.tr);
      return;
    }

    isLoading.value = true;
    try {
      final request = ResetPasswordRequestModel(
        email: verificationEmail.value,
        otp: otpController.text.trim(),
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final response = await _authRepository.resetPassword(request);

      if (response.success) {
        // Clear form
        newPasswordController.clear();
        confirmPasswordController.clear();
        otpController.clear();
        forgotEmailController.clear();
        
        Get.toNamed('/congratulations');
      } else {
        Get.snackbar(
          'error'.tr,
          response.message.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Log.e('Reset password failed', e);
      Get.snackbar(
        'error'.tr,
        'somethingWentWrong'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onGoToLogin() {
    // Navigate based on auth flow
    if (currentAuthFlow.value == 'change-password') {
      currentAuthFlow.value = '';
      Get.offAllNamed('/profile');
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ===== Get Started =====

  Future<void> onGetStarted() async {
    String userType = await UserPreferences.getUserType();

    if (userType == UserPreferences.USER_TYPE_SERVICE_PROVIDER) {
      Get.offAllNamed(AppRoutes.serviceProviderHome);
    } else {
      Get.offAllNamed(AppRoutes.customerHome);
    }
  }

  // ===== Shared Methods =====

  void goBack() {
    Get.back();
  }
}
