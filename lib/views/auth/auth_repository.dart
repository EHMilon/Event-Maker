import '../../models/auth_models.dart';
import '../../models/user_model.dart';
import '../../utils/user_preferences.dart';
import '../../utils/logger.dart';
import '../../services/api_service.dart';
import '../../constants/api_constant.dart';

/// Repository for handling all authentication-related API operations.
class AuthRepository {
  final ApiService _apiService = ApiService();

  String _handleError(dynamic error) {
    Log.e('AuthRepository Error', error);
    return 'Something went wrong';
  }

  /// Register new user
  Future<AuthApiResponse<SignUpResponseModel>> signUp(
    SignUpRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.signUp,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final signUpResponse = SignUpResponseModel.fromJson(response.data!);
        return AuthApiResponse(
          success: true,
          message: response.message,
          data: signUpResponse,
          statusCode: response.statusCode,
        );
      }

      return AuthApiResponse(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  /// Sign in user
  Future<AuthApiResponse<SignInResponseModel>> signIn(
    SignInRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.signIn,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final signInResponse = SignInResponseModel.fromJson(response.data!);
        await _saveSession(signInResponse);

        return AuthApiResponse(
          success: true,
          message: response.message,
          data: signInResponse,
          statusCode: response.statusCode,
        );
      }

      return AuthApiResponse(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  /// Verify email with OTP
  Future<AuthApiResponse<VerifyEmailResponseModel>> verifyEmail(
    VerifyEmailRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.verifyEmail,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final verifyResponse = VerifyEmailResponseModel.fromJson(response.data!);
        
        if (verifyResponse.tokens != null) {
          await _saveTokensFromVerify(verifyResponse);
        }

        return AuthApiResponse(
          success: true,
          message: response.message,
          data: verifyResponse,
          statusCode: response.statusCode,
        );
      }

      return AuthApiResponse(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  /// Resend verification code
  Future<AuthApiResponse<void>> resendVerificationCode(
    ResendVerificationRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.resendVerificationCode,
        data: request.toJson(),
      );

      return AuthApiResponse(
        success: response.success,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  /// Request password reset
  Future<AuthApiResponse<ForgotPasswordResponseModel>> forgotPassword(
    ForgotPasswordRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.forgotPassword,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final forgotResponse = ForgotPasswordResponseModel.fromJson(response.data!);
        return AuthApiResponse(
          success: true,
          message: response.message,
          data: forgotResponse,
          statusCode: response.statusCode,
        );
      }

      return AuthApiResponse(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  /// Verify reset code
  Future<AuthApiResponse<VerifyResetCodeResponseModel>> verifyResetCode(
    VerifyResetCodeRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.verifyResetCode,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final verifyResponse = VerifyResetCodeResponseModel.fromJson(response.data!);
        return AuthApiResponse(
          success: true,
          message: response.message,
          data: verifyResponse,
          statusCode: response.statusCode,
        );
      }

      return AuthApiResponse(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  /// Reset password
  Future<AuthApiResponse<void>> resetPassword(
    ResetPasswordRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.resetPassword,
        data: request.toJson(),
      );

      return AuthApiResponse(
        success: response.success,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  /// Change password
  Future<AuthApiResponse<void>> changePassword(
    ChangePasswordRequestModel request,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConstant.changePassword,
        data: request.toJson(),
      );

      return AuthApiResponse(
        success: response.success,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  /// Refresh access token
  Future<AuthApiResponse<RefreshTokenResponseModel>> refreshToken() async {
    try {
      final refreshToken = await UserPreferences.getRefreshToken();
      if (refreshToken == null) {
        return const AuthApiResponse(success: false, message: 'Session expired');
      }

      final request = RefreshTokenRequestModel(refreshToken: refreshToken);
      final response = await _apiService.post(
        ApiConstant.refreshToken,
        data: request.toJson(),
      );

      if (response.success && response.data != null) {
        final refreshResponse = RefreshTokenResponseModel.fromJson(response.data!);
        
        await UserPreferences.saveTokens(
          accessToken: refreshResponse.accessToken,
          refreshToken: refreshToken,
          expiresIn: refreshResponse.expiresIn,
        );

        return AuthApiResponse(
          success: true,
          message: response.message,
          data: refreshResponse,
          statusCode: response.statusCode,
        );
      }

      return AuthApiResponse(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    } catch (e) {
      return AuthApiResponse(success: false, message: _handleError(e));
    }
  }

  /// Logout user
  Future<AuthApiResponse<void>> logout() async {
    try {
      await _apiService.post(ApiConstant.logout);
      await _clearSession();
      return const AuthApiResponse(success: true, message: 'Logout successful');
    } catch (e) {
      await _clearSession();
      return const AuthApiResponse(success: true, message: 'Logout successful');
    }
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

  Future<bool> hasValidSession() async {
    final isLoggedIn = await UserPreferences.isLoggedIn();
    final accessToken = await UserPreferences.getAccessToken();
    return isLoggedIn && accessToken != null;
  }

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

  /// Use signIn instead
  Future<AuthApiResponse<SignInResponseModel>> login(
    SignInRequestModel request,
  ) async {
    return signIn(request);
  }

  /// Use signUp instead
  Future<AuthApiResponse<SignUpResponseModel>> signup(
    SignUpRequestModel request,
  ) async {
    return signUp(request);
  }
}
