import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:event_maker/models/auth_models.dart';
import 'package:event_maker/global/base_controller.dart';
import 'package:event_maker/utils/logger.dart';
import 'package:event_maker/services/storage_service.dart';
import 'package:event_maker/app_routes.dart';
import 'package:event_maker/services/api_service.dart';
import 'package:event_maker/services/api_exception.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
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
  final selectedCountryCode = 'AE'.obs;
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
  final verificationOnboardKey = ''.obs;
  final resetSecretKey = ''.obs;

  // Signup documents & certifications
  final signupDocuments = <Map<String, dynamic>>[].obs;
  final signupCertifications = <Map<String, dynamic>>[].obs;
  final selectedSignupFile = Rxn<File>();
  final selectedSignupFileName = ''.obs;
  final selectedCertificationImage = Rxn<File>();
  final selectedDocumentType = 'National ID'.obs; // Default to National ID

  String get fileName => selectedSignupFileName.value;

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
    selectedCountryCode.value =
        nationalityCountryCodes[selectedNationality.value] ?? 'AE';
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
    Log.i("AuthController: selectType called with $type");
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
      // ALWAYS restore user type from storage FIRST - never rely on reactive state
      var userType = await _storage.getUserType();

      // If storage empty, use current selected type (fallback)
      if (userType.isEmpty) {
        userType = selectedType.value;
      }

      // If still empty, try restore again
      if (userType.isEmpty) {
        await restoreUserType();
        userType = selectedType.value;
      }

      if (userType.isEmpty) {
        showError('Please select user type');
        // Don't redirect - let user go back manually or select again
        return;
      }

      // ALWAYS persist user type before login attempt - prevents loss on failed login
      await _storage.setUserType(userType);
      selectedType.value = userType;

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
      await _storage.saveTokens(
        accessToken: data.accessToken,
        refreshToken: data.refreshToken,
        expiresIn: data.expiresIn,
      );

      await _storage.saveUserDetails(
        userId: data.user.id,
        name: data.user.fullName,
        email: data.user.emailAddress,
        userType: data.user.role,
      );

      loginEmailController.clear();
      loginPasswordController.clear();
      clearError();

      if (userType == USER_TYPE_SERVICE_PROVIDER) {
        Get.offAllNamed(AppRoutes.serviceProviderHome);
      } else {
        Get.offAllNamed(AppRoutes.customerHome);
      }
    } on ApiException catch (e) {
      // Check if onboarding is required
      if (e.statusCode == 403 &&
          e.data != null &&
          e.data is Map<String, dynamic>) {
        final responseData = e.data['data'] as Map<String, dynamic>?;
        if (responseData != null &&
            responseData['onboarding_required'] == true) {
          // Auto start onboarding flow
          verificationUserId.value = responseData['user_id']?.toString() ?? '';
          verificationOnboardKey.value =
              responseData['onboard_key']?.toString() ?? '';

          // NEVER overwrite existing selectedType unless we have a valid role
          if (responseData['role'] != null &&
              responseData['role'].toString().isNotEmpty) {
            selectedType.value = responseData['role'].toString();
            await _storage.setUserType(selectedType.value);
          }

          showWarning(e.data['message'] ?? 'Please complete onboarding.');

          // Navigate to signup step 2 to start onboarding
          Get.offAllNamed(AppRoutes.signupStepTwo);
          return;
        }
      }

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
    // Clear all auth fields before opening signup
    loginEmailController.clear();
    loginPasswordController.clear();
    signupNameController.clear();
    signupEmailController.clear();
    signupPasswordController.clear();
    otpController.clear();
    Get.toNamed('/signup');
  }

  void toggleSignupPasswordVisibility() {
    obscureSignupPassword.value = !obscureSignupPassword.value;
  }

  void toggleTerms(bool? value) {
    acceptedTerms.value = value ?? false;
  }

  static const Map<String, String> nationalityCountryCodes = {
    'Emirati': 'AE',
    'American': 'US',
    'British': 'GB',
    'Indian': 'IN',
    'Bangladeshi': 'BD',
  };

  void updateNationality(String? value) {
    if (value != null) {
      selectedNationality.value = value;
      selectedCountryCode.value = nationalityCountryCodes[value] ?? 'AE';
    }
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

  Future<void> pickSignupDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          selectedSignupFile.value = File(file.path!);
          selectedSignupFileName.value = file.name;
        }
      }
    } catch (e) {
      Log.e('Error picking document', e);
      showError('Failed to pick document');
    }
  }

  void addSignupDocument(String title, String documentType) {
    if (selectedSignupFile.value == null) {
      showWarning('Please select a file');
      return;
    }
    final fileName = selectedSignupFileName.value;
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    signupDocuments.add({
      'title': title,
      'document_type': documentType,
      'fileName': fileName,
      'file': selectedSignupFile.value,
      'isPdf': isPdf,
    });
    selectedSignupFile.value = null;
    selectedSignupFileName.value = '';
    Get.back();
    // showSuccess('Document added');
  }

  void removeSignupDocument(int index) {
    if (index >= 0 && index < signupDocuments.length) {
      signupDocuments.removeAt(index);
      // showSuccess('Document removed');
    }
  }

  Future<void> pickSignupCertificationImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedCertificationImage.value = File(image.path);
      }
    } catch (e) {
      Log.e('Error picking image', e);
      showError('Failed to pick image');
    }
  }

  void addSignupCertification(String title, String institute, String date) {
    if (selectedCertificationImage.value == null) {
      showWarning('Please select a certification image');
      return;
    }
    signupCertifications.add({
      'title': title,
      'institute': institute,
      'date': date,
      'image': selectedCertificationImage.value,
    });
    selectedCertificationImage.value = null;
    Get.back();
    // showSuccess('Certification added');
  }

  void removeSignupCertification(int index) {
    if (index >= 0 && index < signupCertifications.length) {
      signupCertifications.removeAt(index);
      // showSuccess('Certification removed');
    }
  }

  Future<void> onContinueToOtp() async {
    await submitProviderSignupWithDocuments();
  }

  Future<void> onSignup() async {
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

    // Call sign up API immediately - ONLY name, email, password
    if (selectedType.value == 'customer') {
      await _completeCustomerSignup();
    } else {
      await _completeProviderSignup();
    }
  }

  Future<void> onContinueSignup() async {
    if (signupPhoneController.text.trim().isEmpty) {
      showWarning('Please enter your phone number');
      return;
    }

    if (selectedType.value.isEmpty) {
      // If for some reason type is missing, try restoring it
      await restoreUserType();

      // If still missing, force selection
      if (selectedType.value.isEmpty) {
        showError('Please select user type');
        Get.offAllNamed(AppRoutes.userType);
        return;
      }
    }

    await _storage.setUserType(selectedType.value);

    if (selectedType.value == 'provider') {
      // After phone/nationality, continue to provider details onboarding
      Get.toNamed(AppRoutes.providerDetails);
    } else {
      // For customer, this is final onboarding step
      await _submitCustomerOnboarding();
    }
  }

  Future<void> onContinueProviderDetails() async {
    if (selectedServiceType.value.isEmpty ||
        selectedRole.value.isEmpty ||
        selectedServiceCategory.value.isEmpty) {
      showWarning('Please select all fields');
      return;
    }

    Get.toNamed(AppRoutes.signupDocuments);
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
        nationality: '',
        phoneNumber: '',
        termsAgreed: acceptedTerms.value,
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

      // Always show backend message
      showSuccess(data.message);

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

  Future<void> _submitCustomerOnboarding() async {
    if (isLoading.value) return;

    setLoading(true);

    try {
      final fields = {
        'user_id': verificationUserId.value,
        'onboard_key': verificationOnboardKey.value,
        'nationality': selectedNationality.value,
        'phone_number': signupPhoneController.text.trim(),
      };

      final response = await _apiService.post(
        ApiConstant.onboard,
        body: fields,
        requiresAuth: false,
      );

      // Always show backend message
      // final message =
      //     response['message'] ?? 'Onboarding completed successfully.';
      // showSuccess(message);

      // Check if we received tokens in response
      if (response['data'] != null &&
          response['data']['access_token'] != null) {
        // Save tokens from onboarding response
        final tokensData = response['data'] as Map<String, dynamic>;
        await _storage.saveTokens(
          accessToken: tokensData['access_token'],
          refreshToken: tokensData['refresh_token'],
          expiresIn: tokensData['expires_in'],
        );
        await _storage.saveUserDetails(
          userId: tokensData['user_id'],
          name: '',
          email: '',
          userType: tokensData['role'],
        );

        _clearPersistedUserId();
        verificationOnboardKey.value = '';
        signupPhoneController.clear();
        selectedNationality.value = 'Emirati';
        clearError();

        // Navigate directly to home
        _navigateToHome();
      } else {
        // Clear data and navigate to congratulations screen
        _clearPersistedUserId();
        verificationOnboardKey.value = '';
        signupPhoneController.clear();
        selectedNationality.value = 'Emirati';
        clearError();

        Get.offAllNamed('/congratulations');
      }
    } on ApiException catch (e) {
      final errorMessage = e.message ?? 'Onboarding failed. Please try again.';
      setError(errorMessage);
      showError(errorMessage);
    } catch (e, stackTrace) {
      Log.e('Customer onboarding failed', e, stackTrace);
      setError('Onboarding failed. Please try again.');
      showError('Onboarding failed. Please try again.');
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
        nationality: '',
        phoneNumber: '',
        termsAgreed: acceptedTerms.value,
      );

      final response = await _apiService.post(
        ApiConstant.signUp,
        body: request.toJson(),
        requiresAuth: false,
      );

      final data = SignUpResponseModel.fromJson(response);

      await _persistUserId(data.userId);
      signupPasswordController.clear();
      clearError();

      // Always show backend message
      showSuccess(data.message);

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

  Future<void> submitProviderSignupWithDocuments() async {
    if (isLoading.value) return;

    setLoading(true);

    try {
      // 1. Prepare text fields for onboarding
      final fields = {
        'user_id': verificationUserId.value,
        'onboard_key': verificationOnboardKey.value,
        'nationality': selectedNationality.value,
        'phone_number': signupPhoneController.text.trim(),
        'service_type_name': selectedServiceType.value,
        'provider_type': selectedRole.value,
        'service_category_name': selectedServiceCategory.value,
      };

      // 2. Prepare documents JSON string
      final List<Map<String, String>> docsMetadata = signupDocuments.map((doc) {
        return {
          'title': doc['title'] as String,
          'document_type': doc['document_type'] as String,
        };
      }).toList();
      fields['documents'] = jsonEncode(docsMetadata);

      // 3. Prepare certificates JSON string
      final List<Map<String, String>> certsMetadata = signupCertifications.map((
        cert,
      ) {
        return {
          'title': cert['title'] as String,
          'institute': cert['institute'] as String,
          'issue_date': cert['date'] as String,
        };
      }).toList();
      fields['certificates'] = jsonEncode(certsMetadata);

      // 4. Prepare files
      final List<http.MultipartFile> multipartFiles = [];

      // Add document files
      for (var doc in signupDocuments) {
        final File file = doc['file'];
        final mimeType = lookupMimeType(file.path)?.split('/');

        multipartFiles.add(
          await http.MultipartFile.fromPath(
            'document_files',
            file.path,
            contentType: mimeType != null
                ? MediaType(mimeType[0], mimeType[1])
                : MediaType('application', 'octet-stream'),
          ),
        );
      }

      // Add certificate files
      for (var cert in signupCertifications) {
        if (cert['image'] != null) {
          final File file = cert['image'];
          final mimeType = lookupMimeType(file.path)?.split('/');

          multipartFiles.add(
            await http.MultipartFile.fromPath(
              'certificate_files',
              file.path,
              contentType: mimeType != null
                  ? MediaType(mimeType[0], mimeType[1])
                  : MediaType('application', 'octet-stream'),
            ),
          );
        }
      }

      Log.d('Sending Provider Onboarding FormData: $fields');

      final response = await _apiService.postFormData(
        ApiConstant.onboard,
        body: fields,
        files: multipartFiles,
        requiresAuth: false,
      );

      // Always show backend message
      final message =
          response['message'] ?? 'Onboarding completed successfully.';
      showSuccess(message);

      // Clear data and navigate to login screen
      _clearPersistedUserId();
      verificationOnboardKey.value = '';
      signupPasswordController.clear();
      signupPhoneController.clear();
      selectedNationality.value = 'Emirati';
      selectedServiceType.value = '';
      selectedRole.value = '';
      selectedServiceCategory.value = '';
      signupDocuments.clear();
      signupCertifications.clear();
      clearError();

      Get.offAllNamed(AppRoutes.login);
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
    // Clear login fields as well
    loginEmailController.clear();
    loginPasswordController.clear();
    // Navigate to UserType first, then Login to ensure back button works
    Get.offAllNamed(AppRoutes.userType);
    Future.microtask(() => Get.toNamed(AppRoutes.login));
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

        // Save tokens ONLY if onboarding is NOT required
        if (data.tokens != null && !(data.onboardingRequired ?? false)) {
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
        clearError();

        // Always show backend message
        // showSuccess(data.message ?? 'Account verified successfully.');

        // Check if onboarding is required
        if (data.onboardingRequired ?? false) {
          // Store onboard key for onboarding process
          verificationOnboardKey.value = data.onboardKey ?? '';

          // BOTH customer AND provider first go to signup step 2 (phone + nationality)
          Get.offAllNamed(AppRoutes.signupStepTwo);
        } else {
          // No onboarding required, navigate to login screen
          _clearPersistedUserId();
          verificationOnboardKey.value = '';
          Get.offAllNamed(AppRoutes.login);
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

      final response = await _apiService.post(
        ApiConstant.resendVerificationCode,
        body: request.toJson(),
        requiresAuth: false,
      );

      _startOtpTimer();

      // _startOtpTimer();
      // showSuccess('OTP resent successfully');
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

    // ALWAYS use backend message FIRST if available
    if (data != null && data is Map<String, dynamic>) {
      final String? backendMessage = data['message']?.toString();
      if (backendMessage != null && backendMessage.isNotEmpty) {
        return backendMessage;
      }

      final errors = data['errors'];
      if (errors != null && errors is Map<String, dynamic>) {
        if (errors.containsKey('current_password')) {
          return errors['current_password'].toString();
        }
        if (errors.containsKey('new_password')) {
          return errors['new_password'].toString();
        }
        if (errors.containsKey('confirm_password')) {
          return errors['confirm_password'].toString();
        }
      }
    }

    // Also check exception message directly
    if (exception.message.isNotEmpty &&
        !exception.message.contains('ApiException') &&
        !exception.message.contains('unknown')) {
      return exception.message;
    }

    // Fallback to status code based messages ONLY if no backend message
    switch (statusCode) {
      case 401:
        return 'Session expired. Please login again';
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
      // Clear all auth fields on logout
      loginEmailController.clear();
      loginPasswordController.clear();
      signupNameController.clear();
      signupEmailController.clear();
      signupPasswordController.clear();
      signupPhoneController.clear();
      otpController.clear();
      forgotEmailController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      currentPasswordController.clear();
      changeNewPasswordController.clear();
      changeConfirmPasswordController.clear();
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

    // Try to extract message from backend response FIRST - use backend message if available
    if (data != null && data is Map<String, dynamic>) {
      final String? backendMessage = data['message']?.toString();

      // Use backend message DIRECTLY if it exists - NO FALLBACK! ALWAYS show server message first
      if (backendMessage != null && backendMessage.isNotEmpty) {
        return backendMessage;
      }

      final errors = data['errors'];

      // Handle validation errors
      if (errors != null && errors is Map<String, dynamic>) {
        if (errors.containsKey('email_address') ||
            errors.containsKey('email')) {
          return 'Please enter a valid email address';
        }
        if (errors.containsKey('password')) {
          return 'Please enter your password';
        }
        if (errors.containsKey('role')) {
          return 'Please select a user type';
        }
      }
    }

    // Also check exception message directly
    if (exception.message.isNotEmpty &&
        !exception.message.contains('ApiException') &&
        !exception.message.contains('unknown')) {
      return exception.message;
    }

    // Fallback to status code based messages ONLY if no backend message
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
    Log.d(
      'Parsing signup error: ${exception.statusCode}, data: ${exception.data}',
    );
    final int? statusCode = exception.statusCode;
    final dynamic data = exception.data;

    if (data != null && data is Map<String, dynamic>) {
      // 1. PRIORITIZE backend message FIRST - always use backend message if available
      final String? backendMessage = data['message']?.toString();
      if (backendMessage != null && backendMessage.isNotEmpty) {
        return backendMessage;
      }

      // 2. Handle specific validation errors
      final errors = data['errors'];
      if (errors != null && errors is Map<String, dynamic>) {
        if (errors.containsKey('full_name') || errors.containsKey('name')) {
          return 'Please enter your full name';
        }
        if (errors.containsKey('email_address') ||
            errors.containsKey('email')) {
          final emailError = errors['email_address'] ?? errors['email'];
          if (emailError.toString().contains('taken') ||
              emailError.toString().contains('exists')) {
            return 'This email is already registered. Please use a different email';
          }
          return 'Please enter a valid email address';
        }
        if (errors.containsKey('phone_number') || errors.containsKey('phone')) {
          return 'Please enter a valid phone number';
        }
      }
    }

    // 3. If data is null or empty, check the exception message itself
    if (exception.message.isNotEmpty &&
        !exception.message.contains('ApiException') &&
        !exception.message.contains('unknown')) {
      return exception.message;
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

    // ALWAYS use backend message FIRST if available
    if (data != null && data is Map<String, dynamic>) {
      final String? backendMessage = data['message']?.toString();
      if (backendMessage != null && backendMessage.isNotEmpty) {
        return backendMessage;
      }

      final errors = data['errors'];
      if (errors != null && errors is Map<String, dynamic>) {
        if (errors.containsKey('email_address') ||
            errors.containsKey('email')) {
          return errors['email_address']?.toString() ??
              errors['email'].toString();
        }
      }
    }

    // Also check exception message directly
    if (exception.message.isNotEmpty &&
        !exception.message.contains('ApiException') &&
        !exception.message.contains('unknown')) {
      return exception.message;
    }

    // Fallback only if no backend message
    return 'Failed to send reset email. Please try again';
  }

  /// Parses API exceptions into user-friendly error messages for OTP
  String _parseOtpError(ApiException exception) {
    final int? statusCode = exception.statusCode;
    final dynamic data = exception.data;

    // ALWAYS use backend message FIRST if available
    if (data != null && data is Map<String, dynamic>) {
      final String? backendMessage = data['message']?.toString();
      if (backendMessage != null && backendMessage.isNotEmpty) {
        return backendMessage;
      }

      final errors = data['errors'];
      if (errors != null && errors is Map<String, dynamic>) {
        if (errors.containsKey('verification_code') ||
            errors.containsKey('otp')) {
          return errors['verification_code']?.toString() ??
              errors['otp'].toString();
        }
      }
    }

    // Also check exception message directly
    if (exception.message.isNotEmpty &&
        !exception.message.contains('ApiException') &&
        !exception.message.contains('unknown')) {
      return exception.message;
    }

    // Fallback only if no backend message
    return 'Verification failed. Please try again';
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

    // ALWAYS use backend message FIRST if available
    if (data != null && data is Map<String, dynamic>) {
      final String? backendMessage = data['message']?.toString();
      if (backendMessage != null && backendMessage.isNotEmpty) {
        return backendMessage;
      }

      final errors = data['errors'];
      if (errors != null && errors is Map<String, dynamic>) {
        if (errors.containsKey('new_password')) {
          return errors['new_password'].toString();
        }
        if (errors.containsKey('confirm_password')) {
          return errors['confirm_password'].toString();
        }
        if (errors.containsKey('secret_key')) {
          return errors['secret_key'].toString();
        }
      }
    }

    // Also check exception message directly
    if (exception.message.isNotEmpty &&
        !exception.message.contains('ApiException') &&
        !exception.message.contains('unknown')) {
      return exception.message;
    }

    // Fallback only if no backend message
    return 'Failed to reset password. Please try again';
  }
}
