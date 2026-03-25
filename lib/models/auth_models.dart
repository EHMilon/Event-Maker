import 'user_model.dart';

/// Authentication token model for JWT tokens.
///
/// Backend Contract:
/// {
///   "access_token": "eyJhbGciOiJIUzI1NiIs...",
///   "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
///   "expires_in": 3600,
///   "token_type": "Bearer"
/// }
class AuthTokenModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn; // seconds
  final String tokenType;

  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.tokenType = 'Bearer',
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refresh_token'] ?? json['refreshToken'] ?? '',
      expiresIn: json['expires_in'] ?? json['expiresIn'] ?? 3600,
      tokenType: json['token_type'] ?? json['tokenType'] ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'token_type': tokenType,
    };
  }

  /// Calculate token expiration time
  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expiresIn));
}

/// Login request model for user authentication.
///
/// Backend Contract:
/// POST /auth/login
/// {
///   "email": "user@example.com",
///   "password": "securePassword",
///   "remember_me": true
/// }
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
    return {
      'email': email,
      'password': password,
      'remember_me': rememberMe,
    };
  }
}

/// Login response model containing user data and tokens.
///
/// Backend Contract:
/// Response:
/// {
///   "user": { ... },
///   "tokens": {
///     "access_token": "...",
///     "refresh_token": "...",
///     "expires_in": 3600
///   }
/// }
class LoginResponseModel {
  final UserModel user;
  final AuthTokenModel tokens;

  const LoginResponseModel({
    required this.user,
    required this.tokens,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      user: UserModel.fromJson(json['user'] ?? {}),
      tokens: AuthTokenModel.fromJson(json['tokens'] ?? json['token'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'tokens': tokens.toJson(),
    };
  }
}

/// Signup request model for multi-step registration.
///
/// Backend Contract:
/// POST /auth/register
/// Step 1 (Basic Info):
/// {
///   "name": "John Doe",
///   "email": "user@example.com",
///   "password": "securePassword",
///   "user_type": "customer" | "provider",
///   "accepted_terms": true
/// }
/// Step 2 (Additional Info - optional for customer):
/// {
///   "nationality": "UAE",
///   "phone": "+971501234567"
/// }
/// Step 3 (Provider Details - provider only):
/// {
///   "service_type": "Hospitality",
///   "role": "Freelancer",
///   "service_category": "Catering"
/// }
class SignupRequestModel {
  // Step 1: Basic Info
  final String name;
  final String email;
  final String password;
  final String userType;
  final bool acceptedTerms;

  // Step 2: Additional Info
  final String? nationality;
  final String? phone;

  // Step 3: Provider Details
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

  /// Create a copy with updated fields (for multi-step form)
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

    // Add optional fields if present
    if (nationality != null) json['nationality'] = nationality;
    if (phone != null) json['phone'] = phone;

    // Add provider-specific fields
    if (userType == 'provider') {
      if (serviceType != null) json['service_type'] = serviceType;
      if (role != null) json['role'] = role;
      if (serviceCategory != null) json['service_category'] = serviceCategory;
    }

    return json;
  }
}

/// Forgot password request model.
///
/// Backend Contract:
/// POST /auth/forgot-password
/// {
///   "email": "user@example.com"
/// }
class ForgotPasswordRequestModel {
  final String email;

  const ForgotPasswordRequestModel({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

/// OTP verification request model.
///
/// Backend Contract:
/// POST /auth/verify-otp
/// {
///   "email": "user@example.com",
///   "otp": "123456",
///   "purpose": "password_reset" | "email_verification"
/// }
class OTPVerificationRequestModel {
  final String email;
  final String otp;
  final String purpose; // 'password_reset' or 'email_verification'

  const OTPVerificationRequestModel({
    required this.email,
    required this.otp,
    required this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'purpose': purpose,
    };
  }
}

/// Resend OTP request model.
///
/// Backend Contract:
/// POST /auth/resend-otp
/// {
///   "email": "user@example.com",
///   "purpose": "password_reset" | "email_verification"
/// }
class ResendOTPRequestModel {
  final String email;
  final String purpose;

  const ResendOTPRequestModel({
    required this.email,
    required this.purpose,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'purpose': purpose,
    };
  }
}

/// Reset password request model.
///
/// Backend Contract:
/// POST /auth/reset-password
/// {
///   "email": "user@example.com",
///   "otp": "123456",  // OTP for verification
///   "new_password": "newSecurePassword",
///   "confirm_password": "newSecurePassword"
/// }
class ResetPasswordRequestModel {
  final String email;
  final String otp;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordRequestModel({
    required this.email,
    required this.otp,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}

/// Generic API response wrapper for auth endpoints.
///
/// Backend Contract:
/// {
///   "success": true,
///   "message": "Operation successful",
///   "data": { ... }
/// }
class AuthApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors; // Validation errors

  const AuthApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory AuthApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return AuthApiResponse(
      success: json['success'] ?? json['status'] == 'success',
      message: json['message'] ?? json['msg'] ?? '',
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'] ?? json['error'],
    );
  }

  bool get hasErrors => errors != null && errors!.isNotEmpty;
}
