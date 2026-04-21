import 'user_model.dart';

/// Authentication token model for JWT tokens.
///
/// Backend Contract:
/// {
///   "access_token": "eyJhbGciOiJIUzI1NiIs...",
///   "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
///   "expires_in": 864000000,
///   "expires_at": 1775457068904
/// }
class AuthTokenModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn; // milliseconds
  final int? expiresAt; // timestamp in milliseconds

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.expiresAt,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refresh_token'] ?? json['refreshToken'] ?? '',
      expiresIn: json['expires_in'] ?? json['expiresIn'] ?? 864000000,
      expiresAt: json['expires_at'] ?? json['expiresAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'expires_at': expiresAt,
    };
  }

  /// Calculate token expiration time
  DateTime get expiresAtDateTime => expiresAt != null
      ? DateTime.fromMillisecondsSinceEpoch(expiresAt!)
      : DateTime.now().add(Duration(milliseconds: expiresIn));
}

/// Sign-up request model for customer registration.
///
/// Backend Contract:
/// POST /auth/sign-up
/// {
///   "role": "customer",
///   "full_name": "Abdul Kader",
///   "email_address": "kader@test.com",
///   "password": "12345678",
///   "nationality": "Bangladeshi",
///   "phone_number": "+8801712345678",
///   "terms_agreed": true
/// }
class SignUpRequestModel {
  final String role;
  final String fullName;
  final String emailAddress;
  final String password;
  final String nationality;
  final String phoneNumber;
  final bool termsAgreed;

  // Provider-specific fields
  final String? serviceTypeName;
  final String? providerType;
  final String? serviceCategoryName;

  const SignUpRequestModel({
    required this.role,
    required this.fullName,
    required this.emailAddress,
    required this.password,
    required this.nationality,
    required this.phoneNumber,
    required this.termsAgreed,
    this.serviceTypeName,
    this.providerType,
    this.serviceCategoryName,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'role': role,
      'full_name': fullName,
      'email_address': emailAddress,
      'password': password,
      'nationality': nationality,
      'phone_number': phoneNumber,
      'terms_agreed': termsAgreed,
    };

    // Add provider-specific fields
    if (role == 'provider') {
      if (serviceTypeName != null) json['service_type_name'] = serviceTypeName;
      if (providerType != null) json['provider_type'] = providerType;
      if (serviceCategoryName != null) {
        json['service_category_name'] = serviceCategoryName;
      }
    }

    return json;
  }
}

/// Sign-up response model.
///
/// Backend Contract:
/// {
///   "message": "Account created successfully. Please verify your email using the OTP sent.",
///   "user_id": "8kDpwLhnbxvQ",
///   "role": "customer"
/// }
class SignUpResponseModel {
  final String message;
  final String userId;
  final String role;

  const SignUpResponseModel({
    required this.message,
    required this.userId,
    required this.role,
  });

  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    // Some endpoints nest the data, some don't
    final dataMap = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    
    return SignUpResponseModel(
      message: json['message'] ?? dataMap['message'] ?? '',
      userId: (dataMap['user_id'] ?? dataMap['userId'] ?? json['user_id'] ?? json['userId'] ?? '').toString(),
      role: json['role'] ?? dataMap['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'user_id': userId, 'role': role};
  }
}

/// Sign-in request model.
///
/// Backend Contract:
/// POST /auth/sign-in
/// {
///   "role": "provider",
///   "email_address": "milon@gmail.com",
///   "password": "12345678"
/// }
class SignInRequestModel {
  final String role;
  final String emailAddress;
  final String password;

  const SignInRequestModel({
    required this.role,
    required this.emailAddress,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'role': role, 'email_address': emailAddress, 'password': password};
  }
}

/// Sign-in response model.
///
/// Backend Contract:
/// {
///   "message": "Login successful.",
///   "access_token": "...",
///   "refresh_token": "...",
///   "expires_in": 864000000,
///   "expires_at": 1775472632472,
///   "user": {
///     "id": "aa9WjW93DdgP",
///     "email_address": "milon@gmail.com",
///     "full_name": "Service Provider",
///     "phone_number": "+8801712345678",
///     "nationality": "Bangladeshi",
///     "role": "provider",
///     "is_verified": true,
///     "is_active": true,
///     "avatar": null
///   }
/// }
class SignInResponseModel {
  final String message;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int? expiresAt;
  final AuthUserModel user;

  const SignInResponseModel({
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.expiresAt,
    required this.user,
  });

  factory SignInResponseModel.fromJson(Map<String, dynamic> json) {
    return SignInResponseModel(
      message: json['message'] ?? '',
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 864000000,
      expiresAt: json['expires_at'],
      user: AuthUserModel.fromJson(json['user'] ?? {}),
    );
  }

  AuthTokenModel get tokens => AuthTokenModel(
    accessToken: accessToken,
    refreshToken: refreshToken,
    expiresIn: expiresIn,
    expiresAt: expiresAt,
  );
}

/// User model for auth responses.
///
/// Backend Contract:
/// {
///   "id": "aa9WjW93DdgP",
///   "email_address": "milon@gmail.com",
///   "full_name": "Service Provider",
///   "phone_number": "+8801712345678",
///   "nationality": "Bangladeshi",
///   "role": "provider",
///   "is_verified": true,
///   "is_active": true,
///   "avatar": null
/// }
class AuthUserModel {
  final String id;
  final String emailAddress;
  final String fullName;
  final String phoneNumber;
  final String nationality;
  final String role;
  final bool isVerified;
  final bool isActive;
  final String? avatar;

  const AuthUserModel({
    required this.id,
    required this.emailAddress,
    required this.fullName,
    required this.phoneNumber,
    required this.nationality,
    required this.role,
    required this.isVerified,
    required this.isActive,
    this.avatar,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] ?? '',
      emailAddress: json['email_address'] ?? json['emailAddress'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      nationality: json['nationality'] ?? '',
      role: json['role'] ?? '',
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      isActive: json['is_active'] ?? json['isActive'] ?? false,
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email_address': emailAddress,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'nationality': nationality,
      'role': role,
      'is_verified': isVerified,
      'is_active': isActive,
      'avatar': avatar,
    };
  }

  /// Convert to UserModel for compatibility
  UserModel toUserModel() {
    return UserModel(
      id: id,
      name: fullName,
      email: emailAddress,
      phone: phoneNumber,
      userType: role,
      nationality: nationality,
      isVerified: isVerified,
      avatar: avatar,
    );
  }
}

/// Verify email request model.
///
/// Backend Contract:
/// POST /auth/verify-email
/// {
///   "user_id": "Mb7FoRGhSaZ8",
///   "verification_code": "648834"
/// }
class VerifyEmailRequestModel {
  final String userId;
  final String verificationCode;

  const VerifyEmailRequestModel({
    required this.userId,
    required this.verificationCode,
  });

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'verification_code': verificationCode};
  }
}

/// Verify email response model (customer).
///
/// Backend Contract:
/// {
///   "message": "Account verified successfully.",
///   "access_token": "...",
///   "refresh_token": "...",
///   "expires_in": 864000000,
///   "expires_at": 1775457068904,
///   "user_id": "8kDpwLhnbxvQ",
///   "role": "customer"
/// }
class VerifyEmailResponseModel {
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final int? expiresAt;
  final String userId;
  final String role;

  const VerifyEmailResponseModel({
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.expiresAt,
    required this.userId,
    required this.role,
  });

  factory VerifyEmailResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final tokensMap = dataMap['tokens'] ?? json['tokens'] ?? json;

    return VerifyEmailResponseModel(
      message: json['message'] ?? dataMap['message'] ?? '',
      accessToken: tokensMap['access_token'] ?? tokensMap['accessToken'] ?? json['access_token'],
      refreshToken: tokensMap['refresh_token'] ?? tokensMap['refreshToken'] ?? json['refresh_token'],
      expiresIn: tokensMap['expires_in'] ?? tokensMap['expiresIn'] ?? json['expires_in'],
      expiresAt: tokensMap['expires_at'] ?? tokensMap['expiresAt'] ?? json['expires_at'],
      userId: (dataMap['user_id'] ?? dataMap['userId'] ?? json['user_id'] ?? json['userId'] ?? '').toString(),
      role: json['role'] ?? dataMap['role'] ?? '',
    );
  }

  /// Check if this is a provider response (waiting for admin approval)
  bool get isProviderPending => role == 'provider' && accessToken == null;

  /// Get tokens if available
  AuthTokenModel? get tokens => accessToken != null
      ? AuthTokenModel(
          accessToken: accessToken!,
          refreshToken: refreshToken!,
          expiresIn: expiresIn!,
          expiresAt: expiresAt,
        )
      : null;
}

/// Resend verification code request model.
///
/// Backend Contract:
/// POST /auth/resend-verification-code
/// {
///   "user_id": "Mb7FoRGhSaZ8"
/// }
class ResendVerificationRequestModel {
  final String userId;

  const ResendVerificationRequestModel({required this.userId});

  Map<String, dynamic> toJson() {
    return {'user_id': userId};
  }
}

/// Forgot password request model.
///
/// Backend Contract:
/// POST /auth/forgot-password
/// {
///   "email_address": "provider@test.com"
/// }
class ForgotPasswordRequestModel {
  final String emailAddress;

  const ForgotPasswordRequestModel({required this.emailAddress});

  Map<String, dynamic> toJson() {
    return {'email_address': emailAddress};
  }
}

/// Forgot password response model.
///
/// Backend Contract:
/// {
///   "message": "A password reset verification code has been sent to your email address.",
///   "user_id": "Mb7FoRGhSaZ8"
/// }
class ForgotPasswordResponseModel {
  final String message;
  final String userId;

  const ForgotPasswordResponseModel({
    required this.message,
    required this.userId,
  });

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    return ForgotPasswordResponseModel(
      message: json['message'] ?? dataMap['message'] ?? '',
      userId: (dataMap['user_id'] ?? dataMap['userId'] ?? json['user_id'] ?? json['userId'] ?? '').toString(),
    );
  }
}

/// Verify reset code request model.
///
/// Backend Contract:
/// POST /auth/verify-reset-code
/// {
///   "user_id": "Mb7FoRGhSaZ8",
///   "verification_code": "262103"
/// }
class VerifyResetCodeRequestModel {
  final String userId;
  final String verificationCode;

  const VerifyResetCodeRequestModel({
    required this.userId,
    required this.verificationCode,
  });

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'verification_code': verificationCode};
  }
}

/// Verify reset code response model.
///
/// Backend Contract:
/// {
///   "message": "Verification successful. Use the provided secret key to reset your password.",
///   "secret_key": "461789c8-969f-4a51-93d8-708c7cc75f3f"
/// }
class VerifyResetCodeResponseModel {
  final String message;
  final String secretKey;

  const VerifyResetCodeResponseModel({
    required this.message,
    required this.secretKey,
  });

  factory VerifyResetCodeResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyResetCodeResponseModel(
      message: json['message'] ?? '',
      secretKey: json['secret_key'] ?? json['secretKey'] ?? '',
    );
  }
}

/// Reset password request model.
///
/// Backend Contract:
/// POST /auth/reset-password
/// {
///   "user_id": "Mb7FoRGhSaZ8",
///   "secret_key": "461789c8-969f-4a51-93d8-708c7cc75f3f",
///   "new_password": "event@1234",
///   "confirm_password": "event@1234"
/// }
class ResetPasswordRequestModel {
  final String userId;
  final String secretKey;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequestModel({
    required this.userId,
    required this.secretKey,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'secret_key': secretKey,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}

/// Change password request model.
///
/// Backend Contract:
/// POST /auth/change-password
/// {
///   "current_password": "12345678",
///   "new_password": "123456789",
///   "confirm_password": "123456789"
/// }
class ChangePasswordRequestModel {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequestModel({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}

/// Refresh token request model.
///
/// Backend Contract:
/// POST /auth/refresh
/// {
///   "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
/// }
class RefreshTokenRequestModel {
  final String refreshToken;

  const RefreshTokenRequestModel({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refresh_token': refreshToken};
  }
}

/// Refresh token response model.
///
/// Backend Contract:
/// {
///   "message": "Access token refreshed successfully.",
///   "access_token": "...",
///   "expires_in": 864000000,
///   "expires_at": 1775465013891
/// }
class RefreshTokenResponseModel {
  final String message;
  final String accessToken;
  final int expiresIn;
  final int? expiresAt;

  const RefreshTokenResponseModel({
    required this.message,
    required this.accessToken,
    required this.expiresIn,
    this.expiresAt,
  });

  factory RefreshTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponseModel(
      message: json['message'] ?? '',
      accessToken: json['access_token'] ?? '',
      expiresIn: json['expires_in'] ?? 864000000,
      expiresAt: json['expires_at'],
    );
  }
}

/// Generic API response wrapper for auth endpoints.
///
/// Backend Contract:
/// {
///   "message": "Operation successful",
///   ...other fields
/// }
class AuthApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  const AuthApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  factory AuthApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return AuthApiResponse(
      success: json['success'] ?? true, // API returns success implicitly
      message: json['message'] ?? '',
      data: fromJsonT != null ? fromJsonT(json) : json['data'] as T?,
      errors: json['errors'] ?? json['error'],
    );
  }

  bool get hasErrors => errors != null && errors!.isNotEmpty;
}

// ===== LEGACY MODELS FOR BACKWARD COMPATIBILITY =====

/// @deprecated Use SignInRequestModel instead
class LoginRequestModel {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequestModel({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'remember_me': rememberMe};
  }
}

/// @deprecated Use SignInResponseModel instead
class LoginResponseModel {
  final AuthUserModel user;
  final AuthTokenModel tokens;

  const LoginResponseModel({required this.user, required this.tokens});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      user: AuthUserModel.fromJson(json['user'] ?? {}),
      tokens: AuthTokenModel.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), ...tokens.toJson()};
  }
}

/// @deprecated Use SignUpRequestModel instead
class SignupRequestModel {
  final String name;
  final String email;
  final String password;
  final String userType;
  final bool acceptedTerms;
  final String? nationality;
  final String? phone;
  final String? serviceType;
  final String? role;
  final String? serviceCategory;

  const SignupRequestModel({
    required this.name,
    required this.email,
    required this.password,
    required this.userType,
    required this.acceptedTerms,
    this.nationality,
    this.phone,
    this.serviceType,
    this.role,
    this.serviceCategory,
  });

  SignupRequestModel copyWith({
    String? name,
    String? email,
    String? password,
    String? userType,
    bool? acceptedTerms,
    String? nationality,
    String? phone,
    String? serviceType,
    String? role,
    String? serviceCategory,
  }) {
    return SignupRequestModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      userType: userType ?? this.userType,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      nationality: nationality ?? this.nationality,
      phone: phone ?? this.phone,
      serviceType: serviceType ?? this.serviceType,
      role: role ?? this.role,
      serviceCategory: serviceCategory ?? this.serviceCategory,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'user_type': userType,
      'accepted_terms': acceptedTerms,
    };

    if (nationality != null) json['nationality'] = nationality;
    if (phone != null) json['phone'] = phone;

    if (userType == 'provider') {
      if (serviceType != null) json['service_type'] = serviceType;
      if (role != null) json['role'] = role;
      if (serviceCategory != null) json['service_category'] = serviceCategory;
    }

    return json;
  }
}

/// @deprecated Use VerifyEmailRequestModel instead
class OTPVerificationRequestModel {
  final String email;
  final String otp;
  final String purpose;

  const OTPVerificationRequestModel({
    required this.email,
    required this.otp,
    required this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp, 'purpose': purpose};
  }
}

/// @deprecated Use ResendVerificationRequestModel instead
class ResendOTPRequestModel {
  final String email;
  final String purpose;

  const ResendOTPRequestModel({required this.email, required this.purpose});

  Map<String, dynamic> toJson() {
    return {'email': email, 'purpose': purpose};
  }
}
