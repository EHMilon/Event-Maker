/// API Constants for backend integration.
///
/// Contains all API-related constants including:
/// - Base URLs (dev, staging, production)
/// - Endpoint paths
/// - Request/Response keys
/// - Timeout configurations
/// - HTTP headers
class ApiConstant {
  // ===== BASE URLS =====
  
  /// Development server URL
  static const String devBaseUrl = 'https://dev-api.eventmaker.com/api/v1';
  
  /// Staging server URL
  static const String stagingBaseUrl = 'https://staging-api.eventmaker.com/api/v1';
  
  /// Production server URL
  static const String prodBaseUrl = 'https://api.eventmaker.com/api/v1';
  
  /// Current base URL (change based on build flavor)
  static const String baseUrl = devBaseUrl;

  // ===== AUTH ENDPOINTS =====
  
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String changePassword = '/auth/change-password';

  // ===== USER ENDPOINTS =====
  
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String deleteAccount = '/user/account/delete';

  // ===== SERVICE PROVIDER ENDPOINTS =====
  
  static const String providerProfile = '/provider/profile';
  static const String providerServices = '/provider/services';
  static const String providerBookings = '/provider/bookings';
  static const String providerEarnings = '/provider/earnings';
  static const String providerReviews = '/provider/reviews';
  static const String providerAvailability = '/provider/availability';

  // ===== CUSTOMER ENDPOINTS =====
  
  static const String customerBookings = '/customer/bookings';
  static const String customerFavorites = '/customer/favorites';
  static const String customerReviews = '/customer/reviews';

  // ===== SERVICE ENDPOINTS =====
  
  static const String services = '/services';
  static const String serviceCategories = '/services/categories';
  static const String serviceSearch = '/services/search';

  // ===== BOOKING ENDPOINTS =====
  
  static const String bookings = '/bookings';
  static const String createBooking = '/bookings/create';
  static const String cancelBooking = '/bookings/cancel';

  // ===== REVIEW ENDPOINTS =====
  
  static const String reviews = '/reviews';
  static const String createReview = '/reviews/create';

  // ===== CHAT ENDPOINTS =====
  
  static const String chats = '/chats';
  static const String chatMessages = '/chats/messages';

  // ===== NOTIFICATION ENDPOINTS =====
  
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';

  // ===== TIMEOUTS (in milliseconds) =====
  
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // ===== PAGINATION =====
  
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ===== HTTP HEADERS =====
  
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ===== REQUEST KEYS =====
  
  static const String keyEmail = 'email';
  static const String keyPassword = 'password';
  static const String keyName = 'name';
  static const String keyPhone = 'phone';
  static const String keyOtp = 'otp';
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyExpiresIn = 'expires_in';
  static const String keyUserType = 'user_type';
  static const String keyRememberMe = 'remember_me';
  static const String keyPage = 'page';
  static const String keyLimit = 'limit';
  static const String keySearch = 'search';

  // ===== RESPONSE KEYS =====
  
  static const String keySuccess = 'success';
  static const String keyMessage = 'message';
  static const String keyData = 'data';
  static const String keyErrors = 'errors';
  static const String keyStatusCode = 'status_code';

  // ===== ERROR CODES =====
  
  static const int codeSuccess = 200;
  static const int codeCreated = 201;
  static const int codeBadRequest = 400;
  static const int codeUnauthorized = 401;
  static const int codeForbidden = 403;
  static const int codeNotFound = 404;
  static const int codeValidationError = 422;
  static const int codeServerError = 500;
  static const int codeServiceUnavailable = 503;
}
