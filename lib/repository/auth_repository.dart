import '../models/auth_models.dart';
import '../models/user_model.dart';
import '../utils/user_preferences.dart';
import '../utils/logger.dart';
import '../services/api_service.dart';

/// Repository for handling all authentication-related API operations.
///
/// Uses ApiService for all HTTP requests.
/// Handles user session persistence and token management.
class AuthRepository {
  final ApiService _apiService = ApiService();

  /// Check network connectivity
  Future<bool> _checkConnectivity() async {
    return _apiService.hasConnectivity();
  }

  /// Handle API errors and return user-friendly messages
  String _handleError(dynamic error) {
    Log.e('AuthRepository Error', error);
    return 'somethingWentWrong';
  }

  /// Parse validation errors from backend response
  Map<String, String>? _parseErrors(Map<String, dynamic>? response) {
    if (response == null || response['errors'] == null) return null;

    final errors = <String, String>{};
    final errorData = response['errors'] as Map<String, dynamic>;

    errorData.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        errors[key] = value.first.toString();
      } else if (value is String) {
        errors[key] = value;
      }
    });

    return errors.isNotEmpty ? errors : null;
  }

  // ===== LOGIN =====

  /// Login user with email and password
  ///
  /// Backend: POST /auth/login
  /// Request: { email, password, remember_me }
  /// Response: { success, message, data: { user, tokens } }
  Future<AuthApiResponse<LoginResponseModel>> login(
    LoginRequestModel request,
  ) async {
    try {
      if (!await _checkConnectivity()) {
        return const AuthApiResponse(
          success: false,
          message: 'noInternetConnection',
        );
      }

      // TODO: Replace with actual API call
      // final response = await _httpClient.post(
      //   '$_baseUrl/auth/login',
      //   data: request.toJson(),
      // );
      //
      // final responseData = response.data as Map<String, dynamic>;
      //
      // if (responseData['success'] == true) {
      //   final loginResponse = LoginResponseModel.fromJson(responseData['data']);
      //   await _saveSession(loginResponse);
      //   return AuthApiResponse(
      //     success: true,
      //     message: responseData['message'] ?? 'loginSuccess',
      //     data: loginResponse,
      //   );
      // }
      //
      // return AuthApiResponse(
      //   success: false,
      //   message: responseData['message'] ?? 'loginFailed',
      //   errors: _parseErrors(responseData),
      // );

      // Mock implementation for development
      await Future.delayed(const Duration(seconds: 2));

      final mockResponse = LoginResponseModel(
        user: UserModel(
          id: '1',
          name: 'Test User',
          email: request.email,
          userType: await UserPreferences.getUserType(),
          isVerified: true,
        ),
        tokens: const AuthTokenModel(
          accessToken: 'mock_access_token',
          refreshToken: 'mock_refresh_token',
          expiresIn: 3600,
        ),
      );

      await _saveSession(mockResponse);

      return AuthApiResponse(
        success: true,
        message: 'loginSuccess',
        data: mockResponse,
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  // ===== SIGNUP =====

  /// Register new user
  ///
  /// Backend: POST /auth/register
  /// Request: { name, email, password, user_type, phone, nationality, ... }
  /// Response: { success, message, data: { user, tokens } }
  Future<AuthApiResponse<LoginResponseModel>> signup(
    SignupRequestModel request,
  ) async {
    try {
      if (!await _checkConnectivity()) {
        return const AuthApiResponse(
          success: false,
          message: 'noInternetConnection',
        );
      }

      // TODO: Replace with actual API call
      // final response = await _httpClient.post(
      //   '$_baseUrl/auth/register',
      //   data: request.toJson(),
      // );

      // Mock implementation
      await Future.delayed(const Duration(seconds: 2));

      final mockResponse = LoginResponseModel(
        user: UserModel(
          id: '1',
          name: request.name,
          email: request.email,
          phone: request.phone,
          userType: request.userType,
          nationality: request.nationality,
          isVerified: false,
        ),
        tokens: const AuthTokenModel(
          accessToken: 'mock_access_token',
          refreshToken: 'mock_refresh_token',
          expiresIn: 3600,
        ),
      );

      await _saveSession(mockResponse);

      return AuthApiResponse(
        success: true,
        message: 'signupSuccess',
        data: mockResponse,
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  // ===== FORGOT PASSWORD =====

  /// Request password reset OTP
  ///
  /// Backend: POST /auth/forgot-password
  /// Request: { email }
  /// Response: { success, message }
  Future<AuthApiResponse<void>> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    try {
      if (!await _checkConnectivity()) {
        return const AuthApiResponse(
          success: false,
          message: 'noInternetConnection',
        );
      }

      // TODO: Replace with actual API call
      // final response = await _httpClient.post(
      //   '$_baseUrl/auth/forgot-password',
      //   data: request.toJson(),
      // );

      // Mock implementation
      await Future.delayed(const Duration(seconds: 2));

      return const AuthApiResponse(success: true, message: 'otpSent');
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  // ===== OTP VERIFICATION =====

  /// Verify OTP code
  ///
  /// Backend: POST /auth/verify-otp
  /// Request: { email, otp, purpose }
  /// Response: { success, message, data: { verified: true } }
  Future<AuthApiResponse<bool>> verifyOTP(
    OTPVerificationRequestModel request,
  ) async {
    try {
      if (!await _checkConnectivity()) {
        return const AuthApiResponse(
          success: false,
          message: 'noInternetConnection',
        );
      }

      // TODO: Replace with actual API call
      // final response = await _httpClient.post(
      //   '$_baseUrl/auth/verify-otp',
      //   data: request.toJson(),
      // );

      // Mock implementation - accept "123456" as valid OTP
      await Future.delayed(const Duration(seconds: 1));

      if (request.otp == '123456') {
        return const AuthApiResponse(
          success: true,
          message: 'otpVerified',
          data: true,
        );
      }

      return const AuthApiResponse(success: false, message: 'invalidOtp');
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  /// Resend OTP code
  ///
  /// Backend: POST /auth/resend-otp
  /// Request: { email, purpose }
  /// Response: { success, message }
  Future<AuthApiResponse<void>> resendOTP(ResendOTPRequestModel request) async {
    try {
      if (!await _checkConnectivity()) {
        return const AuthApiResponse(
          success: false,
          message: 'noInternetConnection',
        );
      }

      // TODO: Replace with actual API call
      // final response = await _httpClient.post(
      //   '$_baseUrl/auth/resend-otp',
      //   data: request.toJson(),
      // );

      // Mock implementation
      await Future.delayed(const Duration(seconds: 1));

      return const AuthApiResponse(success: true, message: 'otpResent');
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  // ===== RESET PASSWORD =====

  /// Reset password with verified OTP
  ///
  /// Backend: POST /auth/reset-password
  /// Request: { email, otp, new_password, confirm_password }
  /// Response: { success, message }
  Future<AuthApiResponse<void>> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    try {
      if (!await _checkConnectivity()) {
        return const AuthApiResponse(
          success: false,
          message: 'noInternetConnection',
        );
      }

      // TODO: Replace with actual API call
      // final response = await _httpClient.post(
      //   '$_baseUrl/auth/reset-password',
      //   data: request.toJson(),
      // );

      // Mock implementation
      await Future.delayed(const Duration(seconds: 2));

      return const AuthApiResponse(
        success: true,
        message: 'passwordResetSuccess',
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  // ===== TOKEN MANAGEMENT =====

  /// Refresh access token using refresh token
  ///
  /// Backend: POST /auth/refresh-token
  /// Request: { refresh_token }
  /// Response: { success, data: { access_token, refresh_token, expires_in } }
  Future<AuthApiResponse<AuthTokenModel>> refreshToken() async {
    try {
      final refreshToken = await UserPreferences.getRefreshToken();
      if (refreshToken == null) {
        return const AuthApiResponse(success: false, message: 'sessionExpired');
      }

      // TODO: Replace with actual API call
      // final response = await _httpClient.post(
      //   '$_baseUrl/auth/refresh-token',
      //   data: {'refresh_token': refreshToken},
      // );

      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 500));

      const newTokens = AuthTokenModel(
        accessToken: 'new_mock_access_token',
        refreshToken: 'new_mock_refresh_token',
        expiresIn: 3600,
      );

      await UserPreferences.saveTokens(
        accessToken: newTokens.accessToken,
        refreshToken: newTokens.refreshToken,
        expiresIn: newTokens.expiresIn,
      );

      return const AuthApiResponse(
        success: true,
        message: 'tokenRefreshed',
        data: newTokens,
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  // ===== LOGOUT =====

  /// Logout user and clear session
  ///
  /// Backend: POST /auth/logout
  /// Request: { refresh_token } (optional, for token blacklisting)
  /// Response: { success, message }
  Future<AuthApiResponse<void>> logout() async {
    try {
      // TODO: Replace with actual API call
      // final refreshToken = await UserPreferences.getRefreshToken();
      // await _httpClient.post(
      //   '$_baseUrl/auth/logout',
      //   data: {'refresh_token': refreshToken},
      // );

      // Clear local session regardless of API response
      await _clearSession();

      return const AuthApiResponse(success: true, message: 'logoutSuccess');
    } catch (e) {
      // Still clear local session even if API fails
      await _clearSession();
      return AuthApiResponse(success: true, message: 'logoutSuccess');
    }
  }

  // ===== SESSION MANAGEMENT =====

  /// Save user session after successful login/signup
  Future<void> _saveSession(LoginResponseModel response) async {
    await Future.wait([
      UserPreferences.saveUserDetails(
        userId: response.user.id,
        name: response.user.name,
        email: response.user.email,
        userType: response.user.userType,
      ),
      UserPreferences.saveTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
        expiresIn: response.tokens.expiresIn,
      ),
      UserPreferences.setLoggedIn(true),
    ]);
  }

  /// Clear user session on logout
  Future<void> _clearSession() async {
    await UserPreferences.clearUserData();
  }

  /// Check if user has valid session
  Future<bool> hasValidSession() async {
    final isLoggedIn = await UserPreferences.isLoggedIn();
    final accessToken = await UserPreferences.getAccessToken();
    return isLoggedIn && accessToken != null;
  }

  /// Get current user from preferences
  Future<UserModel?> getCurrentUser() async {
    final details = await UserPreferences.getUserDetails();
    if (details == null) return null;

    return UserModel(
      id: details['id']!,
      name: details['name']!,
      email: details['email']!,
      userType: details['type']!,
    );
  }
}
