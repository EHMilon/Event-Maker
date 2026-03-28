import '../../models/auth_models.dart';
import '../../models/user_model.dart';
import '../../models/api_result.dart';
import '../../utils/user_preferences.dart';
import '../../utils/logger.dart';
import '../../services/api_service.dart';
import '../../constants/api_constant.dart';

/// Repository for handling all authentication-related API operations.
/// 
/// Uses [Result<T>] pattern for type-safe response handling with
/// comprehensive error management.
class AuthRepository {
  final ApiService _apiService = ApiService();

  // ===== SIGN UP =====

  /// Register new user
  Future<Result<SignUpResponseModel>> signUp(
    SignUpRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.signUp,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        try {
          final signUpResponse = SignUpResponseModel.fromJson(response.data!);
          return Success(signUpResponse);
        } catch (e, stackTrace) {
          Log.e('Failed to parse sign up response', e, stackTrace);
          return Error(
            'Failed to process registration response.',
            statusCode: response.statusCode,
            errorType: ErrorType.parseError,
          );
        }
      }

      return Error(
        response.message,
        statusCode: response.statusCode,
        validationErrors: response.errors,
        errorType: response.errorType ?? ErrorType.unknown,
      );
    } catch (e, stackTrace) {
      Log.e('Sign up error', e, stackTrace);
      return Error(
        'Registration failed. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }

  // ===== SIGN IN =====

  /// Sign in user
  Future<Result<SignInResponseModel>> signIn(
    SignInRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.signIn,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        try {
          final signInResponse = SignInResponseModel.fromJson(response.data!);
          await _saveSession(signInResponse);
          return Success(signInResponse);
        } catch (e, stackTrace) {
          Log.e('Failed to parse sign in response', e, stackTrace);
          return Error(
            'Failed to process login response.',
            statusCode: response.statusCode,
            errorType: ErrorType.parseError,
          );
        }
      }

      return Error(
        response.message,
        statusCode: response.statusCode,
        validationErrors: response.errors,
        errorType: response.errorType ?? ErrorType.unknown,
      );
    } catch (e, stackTrace) {
      Log.e('Sign in error', e, stackTrace);
      return Error(
        'Login failed. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }

  // ===== EMAIL VERIFICATION =====

  /// Verify email with OTP
  Future<Result<VerifyEmailResponseModel>> verifyEmail(
    VerifyEmailRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.verifyEmail,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        try {
          final verifyResponse = VerifyEmailResponseModel.fromJson(response.data!);
          
          if (verifyResponse.tokens != null) {
            await _saveTokensFromVerify(verifyResponse);
          }

          return Success(verifyResponse);
        } catch (e, stackTrace) {
          Log.e('Failed to parse verify email response', e, stackTrace);
          return Error(
            'Failed to process verification response.',
            statusCode: response.statusCode,
            errorType: ErrorType.parseError,
          );
        }
      }

      return Error(
        response.message,
        statusCode: response.statusCode,
        validationErrors: response.errors,
        errorType: response.errorType ?? ErrorType.unknown,
      );
    } catch (e, stackTrace) {
      Log.e('Verify email error', e, stackTrace);
      return Error(
        'Verification failed. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }

  /// Resend verification code
  Future<Result<void>> resendVerificationCode(
    ResendVerificationRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.resendVerificationCode,
        data: request.toJson(),
      );

      if (response.success) {
        return const Success(null);
      }

      return Error(
        response.message,
        statusCode: response.statusCode,
        validationErrors: response.errors,
        errorType: response.errorType ?? ErrorType.unknown,
      );
    } catch (e, stackTrace) {
      Log.e('Resend verification error', e, stackTrace);
      return Error(
        'Failed to resend code. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }

  // ===== PASSWORD RESET =====

  /// Request password reset
  Future<Result<ForgotPasswordResponseModel>> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.forgotPassword,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        try {
          final forgotResponse = ForgotPasswordResponseModel.fromJson(response.data!);
          return Success(forgotResponse);
        } catch (e, stackTrace) {
          Log.e('Failed to parse forgot password response', e, stackTrace);
          return Error(
            'Failed to process response.',
            statusCode: response.statusCode,
            errorType: ErrorType.parseError,
          );
        }
      }

      return Error(
        response.message,
        statusCode: response.statusCode,
        validationErrors: response.errors,
        errorType: response.errorType ?? ErrorType.unknown,
      );
    } catch (e, stackTrace) {
      Log.e('Forgot password error', e, stackTrace);
      return Error(
        'Failed to send reset link. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }

  /// Verify reset code
  Future<Result<VerifyResetCodeResponseModel>> verifyResetCode(
    VerifyResetCodeRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.verifyResetCode,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        try {
          final verifyResponse = VerifyResetCodeResponseModel.fromJson(response.data!);
          return Success(verifyResponse);
        } catch (e, stackTrace) {
          Log.e('Failed to parse verify reset code response', e, stackTrace);
          return Error(
            'Failed to process response.',
            statusCode: response.statusCode,
            errorType: ErrorType.parseError,
          );
        }
      }

      return Error(
        response.message,
        statusCode: response.statusCode,
        validationErrors: response.errors,
        errorType: response.errorType ?? ErrorType.unknown,
      );
    } catch (e, stackTrace) {
      Log.e('Verify reset code error', e, stackTrace);
      return Error(
        'Verification failed. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }

  /// Reset password
  Future<Result<void>> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.resetPassword,
        data: request.toJson(),
      );

      if (response.success) {
        return const Success(null);
      }

      return Error(
        response.message,
        statusCode: response.statusCode,
        validationErrors: response.errors,
        errorType: response.errorType ?? ErrorType.unknown,
      );
    } catch (e, stackTrace) {
      Log.e('Reset password error', e, stackTrace);
      return Error(
        'Failed to reset password. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }

  // ===== CHANGE PASSWORD =====

  /// Change password (for logged in users)
  Future<Result<void>> changePassword(
    ChangePasswordRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.changePassword,
        data: request.toJson(),
      );

      if (response.success) {
        return const Success(null);
      }

      // Handle session expired
      if (response.isAuthError) {
        await UserPreferences.clearUserData();
        return Error(
          'Session expired. Please login again.',
          statusCode: response.statusCode,
          errorType: ErrorType.sessionExpired,
        );
      }

      return Error(
        response.message,
        statusCode: response.statusCode,
        validationErrors: response.errors,
        errorType: response.errorType ?? ErrorType.unknown,
      );
    } catch (e, stackTrace) {
      Log.e('Change password error', e, stackTrace);
      return Error(
        'Failed to change password. Please try again.',
        errorType: ErrorType.unknown,
      );
    }
  }

  // ===== TOKEN MANAGEMENT =====

  /// Refresh access token
  Future<Result<RefreshTokenResponseModel>> refreshToken() async {
    try {
      final refreshToken = await UserPreferences.getRefreshToken();
      if (refreshToken == null) {
        return const Error(
          'Session expired. Please login again.',
          errorType: ErrorType.sessionExpired,
        );
      }

      final request = RefreshTokenRequestModel(refreshToken: refreshToken);
      final response = await _apiService.post(
        ApiConstant.refreshToken,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        try {
          final refreshResponse = RefreshTokenResponseModel.fromJson(response.data!);
          
          await UserPreferences.saveTokens(
            accessToken: refreshResponse.accessToken,
            refreshToken: refreshToken,
            expiresIn: refreshResponse.expiresIn,
          );

          return Success(refreshResponse);
        } catch (e, stackTrace) {
          Log.e('Failed to parse refresh token response', e, stackTrace);
          return Error(
            'Failed to process token refresh.',
            statusCode: response.statusCode,
            errorType: ErrorType.parseError,
          );
        }
      }

      // Token refresh failed - clear session
      await UserPreferences.clearUserData();
      return Error(
        response.message.isNotEmpty 
            ? response.message 
            : 'Session expired. Please login again.',
        statusCode: response.statusCode,
        errorType: ErrorType.sessionExpired,
      );
    } catch (e, stackTrace) {
      Log.e('Refresh token error', e, stackTrace);
      await UserPreferences.clearUserData();
      return Error(
        'Session expired. Please login again.',
        errorType: ErrorType.sessionExpired,
      );
    }
  }

  // ===== LOGOUT =====

  /// Logout user
  Future<Result<void>> logout() async {
    try {
      // Try to notify server, but don't wait for response
      await _apiService.post(ApiConstant.logout).timeout(
        const Duration(seconds: 5),
        onTimeout: () => ApiResponse(
          success: true,
          message: 'Logout successful',
          statusCode: 200,
        ),
      );
    } catch (e) {
      Log.e('Logout API call failed', e);
      // Continue with local logout even if API call fails
    }

    // Always clear local session
    await _clearSession();
    return const Success(null);
  }

  // ===== SESSION MANAGEMENT =====

  Future<void> _saveSession(SignInResponseModel response) async {
    await Future.wait([
      UserPreferences.saveUserDetails(
        userId: response.user.id,
        name: response.user.fullName,
        email: response.user.emailAddress,
        userType: response.user.role,
      ),
      UserPreferences.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresIn: response.expiresIn,
      ),
      UserPreferences.setLoggedIn(true),
    ]);
  }

  Future<void> _saveTokensFromVerify(VerifyEmailResponseModel response) async {
    if (response.tokens != null) {
      await UserPreferences.saveTokens(
        accessToken: response.tokens!.accessToken,
        refreshToken: response.tokens!.refreshToken,
        expiresIn: response.tokens!.expiresIn,
      );
      await UserPreferences.saveUserDetails(
        userId: response.userId,
        name: '',
        email: '',
        userType: response.role,
      );
      await UserPreferences.setLoggedIn(true);
    }
  }

  Future<void> _clearSession() async {
    await UserPreferences.clearUserData();
  }

  // ===== SESSION CHECKS =====

  /// Check if user has a valid session
  Future<bool> hasValidSession() async {
    final isLoggedIn = await UserPreferences.isLoggedIn();
    final accessToken = await UserPreferences.getAccessToken();
    return isLoggedIn && accessToken != null;
  }

  /// Get current user from local storage
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

  // ===== LEGACY COMPATIBILITY =====
  // These methods maintain backward compatibility with the old AuthApiResponse pattern

  /// Use signIn instead
  @Deprecated('Use signIn instead')
  Future<Result<SignInResponseModel>> login(
    SignInRequestModel request,
  ) async {
    return signIn(request);
  }

  /// Use signUp instead
  @Deprecated('Use signUp instead')
  Future<Result<SignUpResponseModel>> signup(
    SignUpRequestModel request,
  ) async {
    return signUp(request);
  }
}
