/// API Constants for backend integration.
///
/// Contains all API-related constants including:
/// - Base URLs (dev, staging, production)
/// - Endpoint paths
/// - Request/Response keys
/// - Timeout configurations
/// - HTTP headers
/// - WebSocket URLs and event types
class ApiConstant {
  // ===== BASE URLS =====
  static const String baseUrl = 'http://10.10.12.62:8005/api';

  /// Base URL for serving media files
  static const String mediaBaseUrl = 'http://10.10.12.62:8005';

  /// Helper to get full URL for media/image paths
  /// Returns the full URL if path is relative, otherwise returns as-is
  static String getFullMediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Prepend media base URL for relative paths
    return '$mediaBaseUrl$path';
  }

  // ===== WEBSOCKET URLS =====

  /// WebSocket base URL for real-time chat
  static const String wsBaseUrl = 'ws://10.10.12.62:8005/ws';

  /// Build chat WebSocket URL with chat ID and JWT token
  /// Format: ws://10.10.12.62:8005/ws/chat/{chatId}?token={jwt}
  static String chatWebSocketUrl(String chatId, String token) =>
      '$wsBaseUrl/chat/$chatId?token=$token';

  // ===== AUTH ENDPOINTS =====

  static const String signUp = '/auth/sign-up';
  static const String signIn = '/auth/sign-in';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerificationCode = '/auth/resend-verification-code';
  static const String verifyResetCode = '/auth/verify-reset-code';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh';
  static const String changePassword = '/auth/change-password';

  // Legacy aliases for backward compatibility
  static const String login = signIn;
  static const String register = signUp;
  static const String verifyOtp = verifyEmail;
  static const String resendOtp = resendVerificationCode;

  // ===== USER ENDPOINTS =====

  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String deleteAccount = '/user/account/delete';

  /// Personal info endpoints for settings
  static const String personalInfoMe = '/settings/personal-info/me';

  /// Contact info endpoint for settings
  /// GET /settings/contact-info
  static const String contactInfo = '/settings/contact-info';

  /// Upload avatar image (uses PATCH personal-info with multipart)
  static const String uploadAvatar = '/settings/personal-info/me';

  /// Delete account endpoint
  /// DELETE /settings/personal-info/me (same as GET/PATCH personal info)
  static const String deleteAccountV1 = '/settings/personal-info/me';

  // ===== SERVICE PROVIDER ENDPOINTS =====

  static const String providerProfile = '/provider/profile';
  static const String providerServices = '/provider/services';
  static const String providerBookings = '/provider/bookings';
  static const String providerEarnings = '/provider/earnings';
  static const String providerReviews = '/provider/reviews';
  static const String providerAvailability = '/provider/availability';
  static const String providerDashboard = '/provider/dashboard';
  static const String providerActiveOrders = '/provider/orders/active';

  /// Service provider's own profile with section-based data
  /// Query params: section=about | section=reviews
  static const String providerMyProfile = '/providers/my-profile';

  /// Provider schedule endpoint
  /// Query params: date={yyyy-MM-dd}
  static const String providerSchedule = '/bookings/provider/schedule';

  /// Provider availability toggle endpoint
  /// POST /providers/availability-toggle
  /// Response: { "success": true, "message": "...", "data": { "provider_id": 4, "is_available": false } }
  static const String providerAvailabilityToggle =
      '/providers/availability-toggle';

  /// Get vendor profile by provider ID
  /// GET /providers/vendor-info/{id}
  /// Response: { "success": true, "message": "...", "data": { "id": 4, "name": "...", ... } }
  static String vendorProfile(int providerId) =>
      '/providers/vendor-info/$providerId';

  // ===== CUSTOMER ENDPOINTS =====

  static const String customerBookings = '/customer/bookings';
  static const String customerFavorites = '/customer/favorites';
  static const String customerReviews = '/customer/reviews';

  // ===== SERVICE ENDPOINTS =====

  static const String services = '/services';
  static const String serviceCategories = '/services/categories';
  static const String serviceSearch = '/services/search';

  /// Get customer services grouped by service_as_name
  /// Query params: service_type_name (required), service_as_name (optional)
  static const String customerServices = '/services/customer-services';

  /// Get subcategories (unique service_as_name list) by service_type_name
  /// Query params: service_type_name (required)
  static const String subcategories = '/services/subcategories';

  /// Get service detail by ID: /services/detail/{id}
  static String serviceDetail(int id) => '/services/detail/$id';

  /// Get customer service detail by ID: /services/customer-services/{id}
  static String customerServiceDetail(int id) => '/services/customer-services/$id';

  /// Update service by ID: /services/update/{id}
  /// Note: Uses POST with multipart/form-data for update
  static String serviceUpdate(int id) => '/services/update/$id';

  /// Toggle bookmark status for a service
  /// POST /services/bookmark-toggle/{serviceId}
  /// Response: { "success": true, "message": "Service bookmark status updated successfully.", "data": { "service_id": 16, "is_bookmarked": false } }
  static String bookmarkToggle(int serviceId) => '/services/bookmark-toggle/$serviceId';

  /// Get user's bookmarked services
  /// GET /services/my-bookmarked?page=1&page_size=10
  static const String myBookmarked = '/services/my-bookmarked';

  // ===== BOOKING ENDPOINTS =====

  static const String bookings = '/bookings';
  static const String createBooking = '/bookings/create';
  static const String cancelBooking = '/bookings/cancel';

  /// ===== CUSTOMER BOOKING ENDPOINTS =====

  /// Send booking request (POST)
  /// Body: { service_id, selected_package_id, booking_date, start_time, services_duration, special_request, location, latitude, longitude }
  static const String sendBookingRequest = '/bookings/send-bookings-request';

  /// Get customer booking list
  /// Query params: tab=upcoming (default) | tab=past
  static const String customerBookingList = '/bookings/request-list';

  /// Get customer booking detail
  static String customerBookingDetail(int id) => '/bookings/request/detail/$id';

  /// Get customer booking notifications
  static const String customerBookingNotifications = '/bookings/notification-list';

  /// ===== PROVIDER BOOKING ENDPOINTS =====

  /// Provider booking requests: GET api/bookings/provider/booking-request
  /// Query params: tab=upcoming (default) | tab=past
  static const String providerBookingRequests =
      '/bookings/provider/booking-request';

  /// Get single booking request detail: /bookings/provider/booking-request/{id}
  static String providerBookingRequestDetail(int id) =>
      '/bookings/provider/booking-request/$id';

  /// Accept or reject booking request: POST /bookings/provider/booking-request-decision/{id}
  /// Body: {"action": "accepted"} or {"action": "rejected"}
  static String providerBookingRequestDecision(int id) =>
      '/bookings/provider/booking-request-decision/$id';

  /// Mark booking as completed: POST /providers/mark-as-completed/{booking_id}
  /// Body: {} (empty body)
  static String providerMarkAsComplete(int bookingId) =>
      '/providers/mark-as-completed/$bookingId';

  // ===== REVIEW ENDPOINTS =====

  static const String reviews = '/reviews';
  static const String createReview = '/reviews/create';

  // ===== REPORT ENDPOINTS =====

  static const String submitProviderReport = '/providers/submit-report';

  // ===== DOCUMENT ENDPOINTS =====

  /// Provider documents: GET, POST
  static const String providerDocuments = '/providers/documents';

  /// Get single document detail: /providers/documents/detail/{id}
  static String providerDocumentDetail(int id) =>
      '/providers/documents/detail/$id';

  /// Update document: /providers/documents/update/{id}
  static String providerDocumentUpdate(int id) =>
      '/providers/documents/update/$id';

  /// Delete document: /providers/documents/delete/{id}
  static String providerDocumentDelete(int id) =>
      '/providers/documents/delete/$id';

  // ===== CERTIFICATE ENDPOINTS =====

  /// Provider certificates: GET, POST
  static const String providerCertificates = '/providers/certificates';

  /// Get single certificate detail: /providers/certificates/detail/{id}
  static String providerCertificateDetail(int id) =>
      '/providers/certificates/detail/$id';

  /// Update certificate: /providers/certificates/update/{id}
  static String providerCertificateUpdate(int id) =>
      '/providers/certificates/update/$id';

  /// Delete certificate: /providers/certificates/delete/{id}
  static String providerCertificateDelete(int id) =>
      '/providers/certificates/delete/$id';

  // ===== PAYMENTS / WALLET ENDPOINTS =====

  /// Provider wallet history endpoint
  /// Returns wallet summary and transaction history with pagination
  static const String providerWalletHistory = '/payments/provider-wallet-history';

  /// Customer payment history endpoint
  /// Returns paginated payment history for customers
  static const String customerPaymentHistory = '/payments/customer-history';

  /// Stripe checkout session creation endpoint
  /// POST /payments/stripe/create-checkout-session
  /// Body: { "booking_id": int }
  /// Response: { "success": true, "message": "...", "data": { "payment_id": int, "session_id": string, "checkout_url": string } }
  static const String stripeCreateCheckoutSession = '/payments/stripe/create-checkout-session';

  /// PayPal order creation endpoint
  /// POST /payments/paypal/create-order
  /// Body: { "booking_id": int }
  /// Response: { "success": true, "message": "...", "data": { "payment_id": int, "order_id": string, "approval_url": string } }
  static const String paypalCreateOrder = '/payments/paypal/create-order';

  /// Provider Stripe Connect endpoint
  /// GET /payments/provider-connect
  /// Returns Stripe account info and onboarding URL
  /// Response: { "success": true, "message": "...", "data": { "stripe_account_id": string, "onboarding_url": string, "charges_enabled": bool, "payouts_enabled": bool, "details_submitted": bool } }
  static const String providerConnect = '/payments/provider-connect';

  /// Provider withdrawal endpoint
  /// POST /payments/provider-withdrawal
  /// Body: { "amount": double, "method": "stripe" }
  /// Response: { "success": true, "message": "...", "data": { ... } }
  static const String providerWithdrawal = '/payments/provider-withdrawal';

  // ===== CHAT ENDPOINTS =====

  static const String chats = '/chats';
  
  /// Query param for filtering chats: chat_type=normal | admin
  static const String chatTypeParam = 'chat_type';
  static const String chatTypeNormal = 'normal';
  static const String chatTypeAdmin = 'admin';
  
  /// Create private chat with another user
  /// POST /chats/private
  /// Body: { "other_user_id": "userId" }
  static const String chatsPrivate = '/chats/private';
  
  /// Create private admin chat
  /// POST /chats/private-admin
  static const String chatsPrivateAdmin = '/chats/private-admin';
  
  /// Get chat details by ID: /chats/{chatId}
  static String chatDetail(String chatId) => '/chats/$chatId';
  
  /// Get messages for a chat: /chats/{chatId}/messages
  static String chatMessages(String chatId) => '/chats/$chatId/messages';
  
  /// Send message to a chat: /chats/{chatId}/messages
  static String sendChatMessage(String chatId) => '/chats/$chatId/messages';
  
  static const String chatRead = '/chats/read';
  static const String chatCreate = '/chats/create';

  // ===== NOTIFICATION ENDPOINTS =====

  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';

  /// Provider booking notifications: GET api/bookings/provider/booking-notification
  static const String providerBookingNotifications =
      '/bookings/provider/booking-notification';

  /// Provider home screen data
  /// GET /providers/home
  /// Returns: Provider home data including earnings, analytics, balance, and active orders
  static const String providerHome = '/providers/home';

  // ===== TIMEOUTS (in milliseconds) =====

  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // ===== WEBSOCKET TIMEOUTS =====

  /// WebSocket connection timeout
  static const int wsConnectionTimeout = 10000; // 10 seconds

  /// Heartbeat interval for keeping connection alive
  static const int wsHeartbeatInterval = 30000; // 30 seconds

  /// Reconnect delay base (exponential backoff)
  static const int wsReconnectDelayBase = 1000; // 1 second

  /// Maximum reconnect delay
  static const int wsReconnectMaxDelay = 30000; // 30 seconds

  /// Maximum reconnect attempts (0 = infinite)
  static const int wsMaxReconnectAttempts = 0; // infinite

  // ===== PAGINATION =====

  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

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
}
