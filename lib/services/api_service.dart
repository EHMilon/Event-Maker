import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/user_preferences.dart';
import '../utils/logger.dart';
import '../utils/network_exception.dart';
import '../models/api_result.dart';
import '../constants/api_constant.dart';

/// HTTP methods supported by the API service.
enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete,
}

/// Configuration for retry behavior.
class RetryConfig {
  /// Maximum number of retry attempts.
  final int maxRetries;
  
  /// Initial delay before first retry.
  final Duration initialDelay;
  
  /// Maximum delay between retries.
  final Duration maxDelay;
  
  /// Multiplier for exponential backoff.
  final double backoffMultiplier;
  
  /// HTTP status codes that should trigger a retry.
  final Set<int> retryableStatusCodes;

  const RetryConfig({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.retryableStatusCodes = const {408, 429, 500, 502, 503, 504},
  });

  /// No retry configuration.
  static const RetryConfig noRetry = RetryConfig(maxRetries: 0);

  /// Default retry configuration.
  static const RetryConfig defaultConfig = RetryConfig();
}

/// Main API service for handling all HTTP requests.
/// 
/// Provides:
/// - Automatic connectivity checking
/// - Token management and refresh
/// - Request retry with exponential backoff
/// - Comprehensive error handling
/// - Response caching support
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Lock for preventing concurrent token refresh requests.
  Completer<bool>? _refreshTokenLock;
  
  /// Request counts for rate limiting tracking.
  final Map<String, int> _requestCounts = {};

  /// Checks if device has network connectivity.
  Future<bool> hasConnectivity() async {
    final status = await Connectivity().checkConnectivity();
    return !status.contains(ConnectivityResult.none);
  }

  /// Returns default headers for API requests.
  Map<String, String> _getHeaders({String? token}) {
    final headers = Map<String, String>.from(ApiConstant.defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Checks if an endpoint is public (doesn't require authentication).
  bool _isPublicEndpoint(String endpoint) {
    const publicEndpoints = [
      '/auth/sign-in',
      '/auth/sign-up',
      '/auth/forgot-password',
      '/auth/verify-email',
      '/auth/resend-verification-code',
      '/auth/verify-reset-code',
      '/auth/reset-password',
      '/auth/refresh',
      '/auth/change-password',
    ];
    return publicEndpoints.any((e) => endpoint.contains(e));
  }

  // ===== PUBLIC API METHODS =====

  /// Performs a POST request.
  Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? data,
    RetryConfig retryConfig = const RetryConfig(maxRetries: 2),
  }) async {
    return _handleRequest(
      endpoint,
      () => _postRequest(endpoint, data: data),
      retryConfig: retryConfig,
    );
  }

  /// Performs a GET request.
  Future<ApiResponse> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    RetryConfig retryConfig = const RetryConfig(maxRetries: 2),
  }) async {
    return _handleRequest(
      endpoint,
      () => _getRequest(endpoint, queryParameters: queryParameters),
      retryConfig: retryConfig,
    );
  }

  /// Performs a PUT request.
  Future<ApiResponse> put(
    String endpoint, {
    Map<String, dynamic>? data,
    RetryConfig retryConfig = const RetryConfig(maxRetries: 2),
  }) async {
    return _handleRequest(
      endpoint,
      () => _putRequest(endpoint, data: data),
      retryConfig: retryConfig,
    );
  }

  /// Performs a PATCH request.
  Future<ApiResponse> patch(
    String endpoint, {
    Map<String, dynamic>? data,
    RetryConfig retryConfig = const RetryConfig(maxRetries: 2),
  }) async {
    return _handleRequest(
      endpoint,
      () => _patchRequest(endpoint, data: data),
      retryConfig: retryConfig,
    );
  }

  /// Performs a DELETE request.
  Future<ApiResponse> delete(
    String endpoint, {
    Map<String, dynamic>? data,
    RetryConfig retryConfig = const RetryConfig(maxRetries: 2),
  }) async {
    return _handleRequest(
      endpoint,
      () => _deleteRequest(endpoint, data: data),
      retryConfig: retryConfig,
    );
  }

  // ===== INTERNAL REQUEST METHODS =====

  Future<http.Response> _postRequest(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    final token = await _getAuthToken(endpoint);
    final uri = _buildUri(endpoint);
    final body = data != null ? jsonEncode(data) : null;

    Log.d('API POST: $uri');
    Log.d('Request Body: $body');

    final response = await http
        .post(uri, headers: _getHeaders(token: token), body: body)
        .timeout(const Duration(milliseconds: ApiConstant.connectionTimeout));

    Log.d('Response Status: ${response.statusCode}');
    Log.d('Response Body: ${response.body}');
    return response;
  }

  Future<http.Response> _getRequest(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final token = await _getAuthToken(endpoint);
    final uri = _buildUri(endpoint, queryParameters);

    Log.d('API GET: $uri');

    final response = await http
        .get(uri, headers: _getHeaders(token: token))
        .timeout(const Duration(milliseconds: ApiConstant.connectionTimeout));

    Log.d('Response Status: ${response.statusCode}');
    Log.d('Response Body: ${response.body}');
    return response;
  }

  Future<http.Response> _putRequest(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    final token = await _getAuthToken(endpoint);
    final uri = _buildUri(endpoint);
    final body = data != null ? jsonEncode(data) : null;

    Log.d('API PUT: $uri');
    Log.d('Request Body: $body');

    final response = await http
        .put(uri, headers: _getHeaders(token: token), body: body)
        .timeout(const Duration(milliseconds: ApiConstant.connectionTimeout));

    Log.d('Response Status: ${response.statusCode}');
    return response;
  }

  Future<http.Response> _patchRequest(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    final token = await _getAuthToken(endpoint);
    final uri = _buildUri(endpoint);
    final body = data != null ? jsonEncode(data) : null;

    Log.d('API PATCH: $uri');

    final response = await http
        .patch(uri, headers: _getHeaders(token: token), body: body)
        .timeout(const Duration(milliseconds: ApiConstant.connectionTimeout));

    Log.d('Response Status: ${response.statusCode}');
    return response;
  }

  Future<http.Response> _deleteRequest(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    final token = await _getAuthToken(endpoint);
    final uri = _buildUri(endpoint);
    final body = data != null ? jsonEncode(data) : null;

    Log.d('API DELETE: $uri');

    final response = await http
        .delete(uri, headers: _getHeaders(token: token), body: body)
        .timeout(const Duration(milliseconds: ApiConstant.connectionTimeout));

    Log.d('Response Status: ${response.statusCode}');
    return response;
  }

  /// Builds a URI with optional query parameters.
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final uri = Uri.parse('${ApiConstant.baseUrl}$endpoint');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: queryParameters.map(
      (key, value) => MapEntry(key, value.toString()),
    ));
  }

  /// Gets the auth token for the request.
  Future<String?> _getAuthToken(String endpoint) async {
    if (_isPublicEndpoint(endpoint)) {
      return null;
    }
    return UserPreferences.getAccessToken();
  }

  // ===== MAIN REQUEST HANDLER =====

  /// Main handler for all API requests.
  /// 
  /// Handles:
  /// - Connectivity checks
  /// - Token refresh on 401
  /// - Retry logic with exponential backoff
  /// - Error mapping
  Future<ApiResponse> _handleRequest(
    String endpoint,
    Future<http.Response> Function() request, {
    RetryConfig retryConfig = const RetryConfig(),
  }) async {
    // Check connectivity first
    if (!await hasConnectivity()) {
      return ApiResponse(
        success: false,
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
        errorType: ErrorType.noConnection,
      );
    }

    int retryCount = 0;
    Duration delay = retryConfig.initialDelay;

    while (true) {
      try {
        final response = await request();
        final apiResponse = await _processResponse(endpoint, response, request);

        // Check if we should retry
        if (!apiResponse.success &&
            retryCount < retryConfig.maxRetries &&
            retryConfig.retryableStatusCodes.contains(apiResponse.statusCode)) {
          retryCount++;
          Log.d('Retrying request (attempt $retryCount/${retryConfig.maxRetries})');
          
          await Future.delayed(delay);
          delay = _calculateBackoff(delay, retryConfig);
          continue;
        }

        return apiResponse;
      } on TimeoutException catch (e, stackTrace) {
        Log.e('Request Timeout', e, stackTrace);
        
        // Retry on timeout
        if (retryCount < retryConfig.maxRetries) {
          retryCount++;
          Log.d('Retrying request after timeout (attempt $retryCount/${retryConfig.maxRetries})');
          await Future.delayed(delay);
          delay = _calculateBackoff(delay, retryConfig);
          continue;
        }

        return ApiResponse(
          success: false,
          message: 'Connection timeout. Please try again.',
          statusCode: 408,
          errorType: ErrorType.timeout,
        );
      } catch (e, stackTrace) {
        Log.e('API Request Error', e, stackTrace);
        return ApiResponse(
          success: false,
          message: 'Something went wrong. Please try again.',
          statusCode: 0,
          errorType: ErrorType.unknown,
        );
      }
    }
  }

  /// Calculates the next backoff delay.
  Duration _calculateBackoff(Duration currentDelay, RetryConfig config) {
    final newDelayMs = (currentDelay.inMilliseconds * config.backoffMultiplier).round();
    final maxDelayMs = config.maxDelay.inMilliseconds;
    return Duration(milliseconds: newDelayMs.clamp(0, maxDelayMs));
  }

  /// Processes the HTTP response and handles special cases.
  Future<ApiResponse> _processResponse(
    String endpoint,
    http.Response response,
    Future<http.Response> Function() request,
  ) async {
    // Try to parse response body
    Map<String, dynamic>? responseBody;
    try {
      if (response.body.isNotEmpty) {
        responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } on FormatException catch (e) {
      Log.e('Failed to parse response body', e);
      return ApiResponse(
        success: false,
        message: 'Failed to parse server response.',
        statusCode: response.statusCode,
        errorType: ErrorType.parseError,
      );
    }

    final message = responseBody?['message']?.toString() ?? '';
    final errors = responseBody?['errors'] as Map<String, dynamic>?;

    // Handle specific status codes
    switch (response.statusCode) {
      case 200:
      case 201:
        return ApiResponse(
          success: true,
          message: message.isNotEmpty ? message : 'Success',
          data: responseBody,
          statusCode: response.statusCode,
        );

      case 204:
        return ApiResponse(
          success: true,
          message: 'Success',
          statusCode: response.statusCode,
        );

      case 400:
        return ApiResponse(
          success: false,
          message: message.isNotEmpty ? message : 'Invalid request. Please check your input.',
          statusCode: 400,
          data: responseBody,
          errors: _extractValidationErrors(responseBody),
          errorType: ErrorType.validation,
        );

      case 401:
        return await _handleUnauthorized(endpoint, response, request, message);

      case 403:
        return ApiResponse(
          success: false,
          message: message.isNotEmpty ? message : 'Access denied. You do not have permission.',
          statusCode: 403,
          errorType: ErrorType.forbidden,
        );

      case 404:
        return ApiResponse(
          success: false,
          message: message.isNotEmpty ? message : 'The requested resource was not found.',
          statusCode: 404,
          errorType: ErrorType.notFound,
        );

      case 409:
        return ApiResponse(
          success: false,
          message: message.isNotEmpty ? message : 'A conflict occurred. Please refresh and try again.',
          statusCode: 409,
          data: responseBody,
        );

      case 422:
        return ApiResponse(
          success: false,
          message: message.isNotEmpty ? message : 'Validation failed. Please check your input.',
          statusCode: 422,
          data: responseBody,
          errors: _extractValidationErrors(responseBody),
          errorType: ErrorType.validation,
        );

      case 429:
        final retryAfter = response.headers['retry-after'];
        return ApiResponse(
          success: false,
          message: 'Too many requests. Please wait a moment and try again.',
          statusCode: 429,
          errorType: ErrorType.rateLimited,
          data: {'retryAfter': retryAfter},
        );

      case 500:
        return ApiResponse(
          success: false,
          message: 'Server error. Please try again later.',
          statusCode: 500,
          errorType: ErrorType.serverError,
        );

      case 502:
      case 503:
      case 504:
        return ApiResponse(
          success: false,
          message: 'Service temporarily unavailable. Please try again later.',
          statusCode: response.statusCode,
          errorType: ErrorType.serviceUnavailable,
        );

      default:
        return ApiResponse(
          success: response.statusCode >= 200 && response.statusCode < 300,
          message: message.isNotEmpty ? message : 'Request completed with status ${response.statusCode}',
          statusCode: response.statusCode,
          data: responseBody,
        );
    }
  }

  /// Handles 401 Unauthorized responses with token refresh.
  Future<ApiResponse> _handleUnauthorized(
    String endpoint,
    http.Response response,
    Future<http.Response> Function() request,
    String message,
  ) async {
    final hasToken = await UserPreferences.hasValidTokens();

    if (hasToken) {
      // Try to refresh token with lock to prevent concurrent refreshes
      final refreshed = await _refreshTokenWithLock();

      if (refreshed) {
        // Retry the original request
        Log.d('Token refreshed, retrying request');
        final retryResponse = await request();
        return _processResponse(endpoint, retryResponse, request);
      } else {
        // Refresh failed, clear session
        await UserPreferences.clearUserData();
        return ApiResponse(
          success: false,
          message: 'Session expired. Please login again.',
          statusCode: 401,
          errorType: ErrorType.sessionExpired,
        );
      }
    }

    // Not logged in - return the actual error from API
    return ApiResponse(
      success: false,
      message: message.isNotEmpty ? message : 'Invalid credentials',
      statusCode: 401,
      errorType: ErrorType.unauthorized,
    );
  }

  /// Refreshes the token with a lock to prevent concurrent refreshes.
  Future<bool> _refreshTokenWithLock() async {
    // If a refresh is already in progress, wait for it
    if (_refreshTokenLock != null) {
      Log.d('Token refresh already in progress, waiting...');
      return _refreshTokenLock!.future;
    }

    // Create a new lock
    _refreshTokenLock = Completer<bool>();

    try {
      final result = await _refreshToken();
      _refreshTokenLock!.complete(result);
      return result;
    } catch (e) {
      _refreshTokenLock!.complete(false);
      return false;
    } finally {
      _refreshTokenLock = null;
    }
  }

  /// Refreshes the access token.
  Future<bool> _refreshToken() async {
    try {
      Log.d('Refreshing access token');
      final storedRefreshToken = await UserPreferences.getRefreshToken();
      if (storedRefreshToken == null) {
        Log.d('No refresh token available');
        return false;
      }

      final uri = _buildUri(ApiConstant.refreshToken);
      final response = await http.post(
        uri,
        headers: ApiConstant.defaultHeaders,
        body: jsonEncode({'refresh_token': storedRefreshToken}),
      ).timeout(const Duration(milliseconds: ApiConstant.connectionTimeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken = data['access_token'] as String?;
        final expiresIn = data['expires_in'] as int?;

        if (accessToken != null) {
          await UserPreferences.saveTokens(
            accessToken: accessToken,
            refreshToken: storedRefreshToken,
            expiresIn: expiresIn ?? 864000000,
          );
          Log.d('Token refresh successful');
          return true;
        }
      }

      Log.d('Token refresh failed with status ${response.statusCode}');
      return false;
    } catch (e, stackTrace) {
      Log.e('Token Refresh Error', e, stackTrace);
      return false;
    }
  }

  /// Extracts validation errors from response body.
  Map<String, List<String>>? _extractValidationErrors(Map<String, dynamic>? body) {
    if (body == null) return null;

    final errors = <String, List<String>>{};

    // Format 1: { "errors": { "email": ["Invalid email"] } }
    if (body['errors'] is Map) {
      final errorsMap = body['errors'] as Map<String, dynamic>;
      errorsMap.forEach((field, value) {
        if (value is List) {
          errors[field] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          errors[field] = [value];
        }
      });
    }

    // Format 2: { "error": { "email": "Invalid email" } }
    if (body['error'] is Map) {
      final errorMap = body['error'] as Map<String, dynamic>;
      errorMap.forEach((field, value) {
        if (value is List) {
          errors[field] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          errors[field] = [value];
        }
      });
    }

    // Format 3: { "detail": { "fields": [...] } }
    if (body['detail'] is Map) {
      final detail = body['detail'] as Map<String, dynamic>;
      if (detail['fields'] is List) {
        for (final field in detail['fields'] as List) {
          if (field is Map<String, dynamic>) {
            final name = field['name']?.toString() ?? '';
            final msg = field['message']?.toString() ?? '';
            if (name.isNotEmpty && msg.isNotEmpty) {
              errors[name] = [msg];
            }
          }
        }
      }
    }

    return errors.isEmpty ? null : errors;
  }
}

/// API response model containing all response data and error information.
class ApiResponse {
  /// Whether the request was successful.
  final bool success;
  
  /// Response message from server or error description.
  final String message;
  
  /// Response data (null on error).
  final Map<String, dynamic>? data;
  
  /// HTTP status code.
  final int? statusCode;
  
  /// Validation errors by field name.
  final Map<String, List<String>>? errors;
  
  /// Type of error if request failed.
  final ErrorType? errorType;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.errors,
    this.errorType,
  });

  /// Returns all validation errors as a single formatted string.
  String get formattedErrors {
    if (errors == null || errors!.isEmpty) return message;

    final allErrors = <String>[];
    errors!.forEach((field, messages) {
      for (final msg in messages) {
        allErrors.add('$field: $msg');
      }
    });
    return allErrors.isEmpty ? message : allErrors.join('\n');
  }

  /// Returns true if this is a network-related error.
  bool get isNetworkError =>
      errorType == ErrorType.noConnection ||
      errorType == ErrorType.timeout ||
      errorType == ErrorType.connectionLost;

  /// Returns true if this is an authentication error.
  bool get isAuthError =>
      statusCode == 401 ||
      errorType == ErrorType.unauthorized ||
      errorType == ErrorType.sessionExpired;

  /// Returns true if this is a validation error.
  bool get isValidationError =>
      statusCode == 400 ||
      statusCode == 422 ||
      errorType == ErrorType.validation;

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode, errorType: $errorType)';
  }
}
