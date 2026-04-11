import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_maker/models/auth_models.dart';
import 'package:event_maker/global/base_controller.dart';
import 'package:event_maker/utils/logger.dart';
import 'package:event_maker/services/storage_service.dart';
import 'package:event_maker/app_routes.dart';
import 'package:event_maker/services/api_service.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/constants/api_constant.dart';

/// Controller for handling authentication state and operations.
///
/// Extends [BaseController] for built-in loading/error state management
/// and uses try-catch pattern with ApiException for error handling.
class AuthController extends BaseController {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();

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
  final selectedNationality = 'Emirati'.obs;
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
  final otpResendTimer = 0.obs;
  final canResendOtp = false.obs;
  final verificationUserId = ''.obs;
  final resetSecretKey = ''.obs;

  Timer? _otpTimer;
  bool _controllersDisposed = false;

  // Constants for user types
  static const String USER_TYPE_CUSTOMER = 'customer';
  static const String USER_TYPE_SERVICE_PROVIDER = 'provider';
  static const String DEFAULT_LANGUAGE = 'en';

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

  /// Restore user type from StorageService
  Future<void> restoreUserType() async {
    try {
      final userType = await _storage.getUserType();
      if (userType.isNotEmpty && selectedType.value.isEmpty) {
        selectedType.value = userType;
      }
    } catch (e) {
      Log.e('Error restoring user type', e);
    }
  }

  Future<void> onContinueUserType() async {
    if (selectedType.value.isNotEmpty) {
      await _storage.setUserType(selectedType.value);
      Get.toNamed(AppRoutes.login);
    } else {
      showWarning('Please select user type');
    }
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Handles user login with comprehensive error handling
  Future<void> onLogin() async {
    if (isLoading.value) return;

    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    if (email.isEmpty) {
      showWarning('Please enter your email');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      showWarning('Please enter a valid email');
      return;
    }

    if (password.isEmpty) {
      showWarning('Please enter your password');
      return;
    }

    setLoading(true);

    try {
      var userType = await _storage.getUserType();

      if (userType == USER_TYPE_CUSTOMER) {
        final hasUserType = await _storage.hasUserType();
        if (!hasUserType) {
          if (selectedType.value.isNotEmpty) {
            userType = selectedType.value;
            await _storage.setUserType(userType);
          } else {
            showError('Please select user type');
            Get.offAllNamed('/user-type');
            return;
          }
        }
      }

      if (selectedType.value.isEmpty && userType.isNotEmpty) {
        selectedType.value = userType;
      }

      if (userType.isEmpty) {
        showError('Please select user type');
        Get.offAllNamed('/user-type');
        return;
      }

      final request = SignInRequestModel(
        role: userType,
        emailAddress: email,
        password: password,
      );

      final response = await _apiService.post(
        ApiConstant.signIn,
        body: request.toJson(),
        requiresAuth: false, // Login doesn't require auth
      );

      final data = SignInResponseModel.fromJson(response);

      // Save session using StorageService
      await Future.wait([
        _storage.saveUserDetails(
          userId: data.user.id,
          name: data.user.fullName,
          email: data.user.emailAddress,
          userType: data.user.role,
        ),
        _storage.saveTokens(
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
          expiresIn: data.expiresIn,
        ),
      ]);

      loginEmailController.clear();
      loginPasswordController.clear();
      clearError();

      if (!data.user.isVerified) {
        showSuccess('accountCreatedSuccessfully'.tr);
        return;
      }

      if (userType == USER_TYPE_SERVICE_PROVIDER) {
        Get.offAllNamed(AppRoutes.serviceProviderHome);
      } else {
        Get.offAllNamed(AppRoutes.customerHome);
      }
    } on ApiException catch (e) {
      final errorMessage = _parseLoginError(e);
      setError(errorMessage);
      showError(errorMessage);
    } catch (e, stackTrace) {
      Log.e('Login failed', e, stackTrace);
      setError('Login failed. Please try again.');
      showError('Login failed. Please try again.');
    } finally {
      setLoading(false);
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
      showWarning('Please enter your name');
      return;
    }

    if (!GetUtils.isEmail(signupEmailController.text.trim())) {
      showWarning('Please enter a valid email');
      return;
    }

    if (signupPasswordController.text.length < 8) {
      showWarning('Password must be at least 8 characters');
      return;
    }

    if (!acceptedTerms.value) {
      showWarning('Please accept the terms and conditions');
      return;
    }

    Get.toNamed('/signup-step-two');
  }

  Future<void> onContinueSignup() async {
    if (signupPhoneController.text.trim().isEmpty) {
      showWarning('Please enter your phone number');
      return;
    }

    await _storage.setUserType(selectedType.value);

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
      showWarning('Please select all fields');
      return;
    }

    await _completeProviderSignup();
  }

  Future<void> _completeCustomerSignup() async {
    if (isLoading.value) return;

    setLoading(true);

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

      final response = await _apiService.post(
        ApiConstant.signUp,
        body: request.toJson(),
        requiresAuth: false, // Signup doesn't require auth
      );

      final data = SignUpResponseModel.fromJson(response);

      await _persistUserId(data.userId);
      signupPasswordController.clear();
      clearError();
      Get.toNamed('/otp-verification');
      _startOtpTimer();
    } on ApiException catch (e) {
      final errorMessage = _parseSignupError(e);
      setError(errorMessage);
      showError(errorMessage);
    } catch (e, stackTrace) {
      Log.e('Customer signup failed', e, stackTrace);
      setError('Signup failed. Please try again.');
      showError('Signup failed. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  Future<void> _completeProviderSignup() async {
    if (isLoading.value) return;

    setLoading(true);

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

      final response = await _apiService.post(
        ApiConstant.signUp,
        body: request.toJson(),
        requiresAuth: false, // Signup doesn't require auth
      );

      final data = SignUpResponseModel.fromJson(response);

      await _persistUserId(data.userId);
      signupPasswordController.clear();
      clearError();
      Get.toNamed('/otp-verification');
      _startOtpTimer();
    } on ApiException catch (e) {
      final errorMessage = _parseSignupError(e);
      setError(errorMessage);
      showError(errorMessage);
    } catch (e, stackTrace) {
      Log.e('Provider signup failed', e, stackTrace);
      setError('Signup failed. Please try again.');
      showError('Signup failed. Please try again.');
    } finally {
      setLoading(false);
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
      showWarning('Please enter a valid email');
      return;
    }

    setLoading(true);

    try {
      final request = ForgotPasswordRequestModel(emailAddress: email);

      final response = await _apiService.post(
        ApiConstant.forgotPassword,
        body: request.toJson(),
        requiresAuth: false, // Forgot password doesn't require auth
      );

      final data = ForgotPasswordResponseModel.fromJson(response);

      await _persistUserId(data.userId);
      clearError();
      Get.toNamed('/otp-verification');
      _startOtpTimer();
    } on ApiException catch (e) {
      final errorMessage = _parseForgotPasswordError(e);
      setError(errorMessage);
      showError(errorMessage);
    } catch (e, stackTrace) {
      Log.e('Forgot password failed', e, stackTrace);
      setError('Something went wrong. Please try again.');
      showError('Something went wrong. Please try again.');
    } finally {
      setLoading(false);
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
      showWarning('Please enter a valid 6-digit OTP');
      return;
    }

    if (verificationUserId.value.isEmpty) {
      await _loadPersistedUserId();
      if (verificationUserId.value.isEmpty) {
        showError('User ID not found. Please try again.');
        return;
      }
    }

    setLoading(true);

    try {
      if (currentAuthFlow.value == 'forgot-password') {
        final request = VerifyResetCodeRequestModel(
          userId: verificationUserId.value,
          verificationCode: otp,
        );

        final response = await _apiService.post(
          ApiConstant.verifyResetCode,
          body: request.toJson(),
          requiresAuth: false,
        );

        final data = VerifyResetCodeResponseModel.fromJson(response);

        _otpTimer?.cancel();
        resetSecretKey.value = data.secretKey;
        clearError();
        Get.toNamed('/reset-password-new');
      } else {
        final request = VerifyEmailRequestModel(
          userId: verificationUserId.value,
          verificationCode: otp,
        );

        final response = await _apiService.post(
          ApiConstant.verifyEmail,
          body: request.toJson(),
          requiresAuth: false,
        );

        final data = VerifyEmailResponseModel.fromJson(response);

        // Save tokens if present
        if (data.tokens != null) {
          await _storage.saveTokens(
            accessToken: data.tokens!.accessToken,
            refreshToken: data.tokens!.refreshToken,
            expiresIn: data.tokens!.expiresIn,
          );
          await _storage.saveUserDetails(
            userId: data.userId,
            name: '',
            email: '',
            userType: data.role,
          );
        }

        _otpTimer?.cancel();
        _clearPersistedUserId();
        clearError();

        if (data.isProviderPending) {
          Get.toNamed('/request-sent');
        } else {
          Get.offAllNamed(AppRoutes.getStarted);
        }
      }
    } on ApiException catch (e) {
      final errorMessage = _parseOtpError(e);
      setError(errorMessage);
      showError(errorMessage);
    } catch (e, stackTrace) {
      Log.e('OTP verification failed', e, stackTrace);
      setError('Verification failed. Please try again.');
      showError('Verification failed. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  Future<void> onResend() async {
    if (!canResendOtp.value) return;

    if (verificationUserId.value.isEmpty) {
      await _loadPersistedUserId();
      if (verificationUserId.value.isEmpty) {
        showError('User ID not found. Please try again.');
        return;
      }
    }

    setLoading(true);

    try {
      final request = ResendVerificationRequestModel(
        userId: verificationUserId.value,
      );

      await _apiService.post(
        ApiConstant.resendVerificationCode,
        body: request.toJson(),
        requiresAuth: false,
      );

      _startOtpTimer();
      showSuccess('OTP resent successfully');
    } on ApiException catch (e) {
      final errorMessage = _parseResendOtpError(e);
      setError(errorMessage);
      showError(errorMessage);
    } catch (e, stackTrace) {
      Log.e('Resend OTP failed', e, stackTrace);
      setError('Something went wrong. Please try again.');
      showError('Something went wrong. Please try again.');
    } finally {
      setLoading(false);
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
      showWarning('Password must be at least 8 characters');
      return;
    }

    if (newPassword != confirmPassword) {
      showWarning('Passwords do not match');
      return;
    }

    if (verificationUserId.value.isEmpty) {
      showError('User ID not found. Please try again.');
      return;
    }

    setLoading(true);

    try {
      final request = ResetPasswordRequestModel(
        userId: verificationUserId.value,
        secretKey: resetSecretKey.value,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      await _apiService.post(
        ApiConstant.resetPassword,
        body: request.toJson(),
        requiresAuth: false,
      );

      newPasswordController.clear();
      confirmPasswordController.clear();
      otpController.clear();
      forgotEmailController.clear();
      resetSecretKey.value = '';
      _clearPersistedUserId();
      clearError();
      Get.toNamed('/congratulations');
    } on ApiException catch (e) {
      final errorMessage = _parseResetPasswordError(e);
      setError(errorMessage);
      showError(errorMessage);
    } catch (e, stackTrace) {
      Log.e('Reset password failed', e, stackTrace);
      setError('Something went wrong. Please try again.');
      showError('Something went wrong. Please try again.');
    } finally {
      setLoading(false);
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

    // Validation with user-friendly messages
    if (currentPassword.isEmpty) {
      showWarning('Please enter your current password');
      return;
    }

    if (newPassword.isEmpty) {
      showWarning('Please enter a new password');
      return;
    }

    if (newPassword.length < 8) {
      showWarning('New password must be at least 8 characters');
      return;
    }

    if (confirmPassword.isEmpty) {
      showWarning('Please confirm your new password');
      return;
    }

    if (newPassword != confirmPassword) {
      showError('New password and confirm password do not match');
      return;
    }

    setLoading(true);

    try {
      final request = ChangePasswordRequestModel(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      await _apiService.post(
        ApiConstant.changePassword,
        body: request.toJson(),
      );

      currentPasswordController.clear();
      changeNewPasswordController.clear();
      changeConfirmPasswordController.clear();
      clearError();
      // Show congratulations view then navigate to home
      currentAuthFlow.value = 'change-password';
      Get.offAllNamed('/congratulations');
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await _storage.clearUserData();
      }
      // Parse backend error message for user-friendly feedback
      final errorMessage = _parseChangePasswordError(e);
      setError(errorMessage);
      showError(errorMessage);
    } catch (e, stackTrace) {
      Log.e('Change password failed', e, stackTrace);
      setError('Something went wrong. Please try again.');
      showError('Something went wrong. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  /// Parses API exceptions into user-friendly error messages for change password
  String _parseChangePasswordError(ApiException exception) {
    final int? statusCode = exception.statusCode;
    final dynamic data = exception.data;

    // Try to extract message from backend response
    if (data != null && data is Map<String, dynamic>) {
      final backendMessage = data['message']?.toString().toLowerCase() ?? '';
      final errors = data['errors'];

      // Handle validation errors
      if (errors != null && errors is Map<String, dynamic>) {
        if (errors.containsKey('current_password')) {
          return 'Current password is incorrect';
        }
        if (errors.containsKey('new_password')) {
          return errors['new_password'].toString();
        }
        if (errors.containsKey('confirm_password')) {
          return 'Passwords do not match';
        }
      }

      // Match common backend messages
      if (backendMessage.contains('current password') ||
          backendMessage.contains('incorrect') ||
          backendMessage.contains('wrong')) {
        return 'Current password is incorrect';
      }
      if (backendMessage.contains('match') ||
          backendMessage.contains('confirm')) {
        return 'New password and confirm password do not match';
      }
      if (backendMessage.contains('new password') ||
          backendMessage.contains('weak') ||
          backendMessage.contains('stronger')) {
        return 'New password is too weak. Use at least 8 characters';
      }
    }

    // Fallback to status code based messages
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your password and try again';
      case 401:
        return 'Session expired. Please login again';
      case 403:
        return 'You do not have permission to change password';
      case 422:
        return 'Invalid password format. Please check all fields';
      default:
        return 'Failed to change password. Please try again';
    }
  }

  void onGoToLogin() {
    if (currentAuthFlow.value == 'change-password') {
      currentAuthFlow.value = '';
      // Navigate to appropriate home screen based on user type
      _navigateToHome();
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Navigate to appropriate home screen based on user type
  void _navigateToHome() async {
    try {
      final userType = await _storage.getUserType();
      if (userType == USER_TYPE_SERVICE_PROVIDER) {
        Get.offAllNamed(AppRoutes.serviceProviderHome);
      } else {
        Get.offAllNamed(AppRoutes.customerHome);
      }
    } catch (e) {
      // Fallback to login if user type not found
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> onGetStarted() async {
    String userType = await _storage.getUserType();

    if (userType == USER_TYPE_SERVICE_PROVIDER) {
      Get.offAllNamed(AppRoutes.serviceProviderHome);
    } else {
      Get.offAllNamed(AppRoutes.customerHome);
    }
  }

  /// Logout user and clear all session data
  Future<void> logout() async {
    if (isLoading.value) return;

    setLoading(true);

    try {
      // Only call logout API if we have a valid token
      final hasToken = await _storage.hasValidTokens();
      if (hasToken) {
        await _apiService
            .post(ApiConstant.logout)
            .timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      Log.e('Logout API call failed', e);
      // Continue with logout even if API fails
    }

    try {
      _clearPersistedUserId();
      disposeAllControllers();
      await _storage.clearUserData();
      Get.offAllNamed(AppRoutes.onboarding);
    } catch (e) {
      Log.e('Logout cleanup failed', e);
      Get.offAllNamed(AppRoutes.onboarding);
    } finally {
      setLoading(false);
    }
  }

  /// Parses API exceptions into user-friendly error messages for login
  String _parseLoginError(ApiException exception) {
    final int? statusCode = exception.statusCode;
    final dynamic data = exception.data;

    // Try to extract message from backend response
    if (data != null && data is Map<String, dynamic>) {
      final backendMessage = data['message']?.toString().toLowerCase() ?? '';
      final errors = data['errors'];

      // Handle validation errors
      if (errors != null && errors is Map<String, dynamic>) {
        if (errors.containsKey('email_address') || errors.containsKey('email')) {
          return 'Please enter a valid email address';
        }
        if (errors.containsKey('password')) {
          return 'Please enter your password';
        }
        if (errors.containsKey('role')) {
          return 'Please select a user type';
        }
      }

      // Match common backend messages
      if (backendMessage.contains('invalid') ||
          backendMessage.contains('credentials') ||
          backendMessage.contains('password')) {
        return 'Incorrect email or password';
      }
      if (backendMessage.contains('not found') ||
          backendMessage.contains('does not exist')) {
        return 'No account found with this email';
      }
      if (backendMessage.contains('verified') ||
          backendMessage.contains('verify')) {
        return 'Please verify your email before logging in';
      }
      if (backendMessage.contains('active') ||
          backendMessage.contains('disabled') ||
          backendMessage.contains('suspended')) {
        return 'Your account has been disabled. Please contact support';
      }
    }

    // Fallback to status code based messages
    switch (statusCode) {
      case 400:
        return 'Invalid login credentials';
      case 401:
        return 'Incorrect email or password';
      case 403:
        return 'Your account is not authorized to login';
      case 404:
        return 'No account found with this email';
      case 422:
        return 'Invalid login information. Please check your details';
      default:
        return 'Login failed. Please try again';
    }
  }

  /// Parses API exceptions into user-friendly error messages for signup
  String _parseSignupError(ApiException exception) {
    final int? statusCode = exception.statusCode;
    final dynamic data = exception.data;

    // Try to extract message from backend response
    if (data != null && data is Map<String, dynamic>) {
      final backendMessage = data['message']?.toString().toLowerCase() ?? '';
      final errors = data['errors'];

      // Handle validation errors
      if (errors != null && errors is Map<String, dynamic>) {
        if (errors.containsKey('full_name') || errors.containsKey('name')) {
          return 'Please enter your full name';
        }
        if (errors.containsKey('email_address') || errors.containsKey('email')) {
          final emailError = errors['email_address'] ?? errors['email'];
          if (emailError.toString().contains('taken') ||
              emailError.toString().contains('exists')) {
            return 'This email is already registered. Please use a different email';
          }
          return 'Please enter a valid email address';
        }
        if (errors.containsKey('password')) {
          return 'Password must be at least 8 characters';
        }
        if (errors.containsKey('phone_number') || errors.containsKey('phone')) {
          return 'Please enter a valid phone number';
        }
        if (errors.containsKey('nationality')) {
          return 'Please select your nationality';
        }
        if (errors.containsKey('terms_agreed')) {
          return 'You must accept the terms and conditions';
        }
      }

      // Match common backend messages
      if (backendMessage.contains('already') ||
          backendMessage.contains('exists') ||
          backendMessage.contains('taken')) {
        return 'This email is already registered. Please use a different email';
      }
    }

    // Fallback to status code based messages
    switch (statusCode) {
      case 400:
        return 'Invalid signup information. Please check all fields';
      case 422:
        return 'Invalid signup data. Please check your information';
      default:
        return 'Signup failed. Please try again';
    }
  }

  /// Parses API exceptions into user-friendly error messages for forgot password
  String _parseForgotPasswordError(ApiException exception) {
    final int? statusCode = exception.statusCode;
    final dynamic data = exception.data;

    // Try to extract message from backend response
    if (data != null && data is Map<String, dynamic>) {
      final backendMessage = data['message']?.toString().toLowerCase() ?? '';
      final errors = data['errors'];

      // Handle validation errors
      if (errors != null && errors is Map<String, dynamic>) {
        if (errors.containsKey('email_address') || errors.containsKey('email')) {
          return 'Please enter a valid email address';
        }
      }

      // Match common backend messages
      if (backendMessage.contains('not found') ||
          backendMessage.contains('does not exist')) {
        return 'No account found with this email address';
      }
    }

    // Fallback to status code based messages
    switch (statusCode) {
      case 404:
        return 'No account found with this email address';
      case 422:
        return 'Invalid email address. Please check and try again';
      default:
        return 'Failed to send reset email. Please try again';
    }
  }

  /// Parses API exceptions into user-friendly error messages for OTP
  String _parseOtpError(ApiException exception) {
    final int? statusCode = exception.statusCode;
    final dynamic data = exception.data;

    // Try to extract message from backend response
    if (data != null && data is Map<String, dynamic>) {
      final backendMessage = data['message']?.toString().toLowerCase() ?? '';
      final errors = data['errors'];

      // Handle validation errors
      if (errors != null && errors is Map<String, dynamic>) {
        if (errors.containsKey('verification_code') ||
            errors.containsKey('otp')) {
          return 'Please enter a valid verification code';
        }
      }

      // Match common backend messages
      if (backendMessage.contains('invalid') ||
          backendMessage.contains('incorrect') ||
          backendMessage.contains('wrong')) {
        return 'Invalid verification code. Please check and try again';
      }
      if (backendMessage.contains('expired')) {
        return 'Verification code has expired. Please request a new one';
      }
    }

    // Fallback to status code based messages
    switch (statusCode) {
      case 400:
        return 'Invalid verification code. Please check and try again';
      case 401:
        return 'Session expired. Please start the process again';
      case 404:
        return 'User not found. Please signup again';
      case 422:
        return 'Invalid verification code format';
      default:
        return 'Verification failed. Please try again';
    }
  }

  /// Parses resend OTP error messages
  String _parseResendOtpError(ApiException exception) {
    // Resend errors are usually network/server related
    return 'Failed to resend code. Please check your connection and try again';
  }

  /// Parses reset password error messages
  String _parseResetPasswordError(ApiException exception) {
    final int? statusCode = exception.statusCode;
    final dynamic data = exception.data;

    // Try to extract message from backend response
    if (data != null && data is Map<String, dynamic>) {
      final errors = data['errors'];

      // Handle validation errors
      if (errors != null && errors is Map<String, dynamic>) {
        if (errors.containsKey('new_password')) {
          return 'Password must be at least 8 characters';
        }
        if (errors.containsKey('confirm_password')) {
          return 'Passwords do not match';
        }
        if (errors.containsKey('secret_key')) {
          return 'Session expired. Please start the reset process again';
        }
      }
    }

    // Fallback to status code based messages
    switch (statusCode) {
      case 400:
        return 'Invalid reset request. Please check your password';
      case 401:
        return 'Session expired. Please start the reset process again';
      case 404:
        return 'Reset session not found. Please try again';
      default:
        return 'Failed to reset password. Please try again';
    }
  }
}
