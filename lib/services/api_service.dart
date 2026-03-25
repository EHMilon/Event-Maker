import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/user_preferences.dart';
import '../utils/logger.dart';
import 'api_constant.dart';

/// API Service for handling all HTTP requests.
///
/// Features:
/// - HTTP-based client with interceptors
/// - Automatic token injection and refresh
/// - Network connectivity check
/// - Error handling and parsing
/// - Request/Response logging
class ApiService {
  /// Singleton instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ===== NETWORK CONNECTIVITY =====

  /// Check if device has network connectivity
  Future<bool> hasConnectivity() async {
    final status = await Connectivity().checkConnectivity();
    return !status.contains(ConnectivityResult.none);
  }

  // ===== HEADERS =====

  /// Get default headers
  Map<String, String> _getHeaders({String? token}) {
    final headers = Map<String, String>.from(ApiConstant.defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Check if endpoint is public (doesn't require auth)
  bool _isPublicEndpoint(String endpoint) {
    const publicEndpoints = [
      ApiConstant.login,
      ApiConstant.register,
      ApiConstant.forgotPassword,
      ApiConstant.verifyOtp,
      ApiConstant.resendOtp,
      ApiConstant.resetPassword,
      ApiConstant.refreshToken,
    ];
    return publicEndpoints.any((e) => endpoint.contains(e));
  }

  // ===== HTTP METHODS =====

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _handleRequest<T>(
      () => _getRequest(endpoint, queryParameters: queryParameters),
      fromJson,
    );
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _handleRequest<T>(
      () => _postRequest(endpoint, data: data),
      fromJson,
    );
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _handleRequest<T>(
      () => _putRequest(endpoint, data: data),
      fromJson,
    );
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _handleRequest<T>(
      () => _patchRequest(endpoint, data: data),
      fromJson,
    );
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _handleRequest<T>(
      () => _deleteRequest(endpoint, data: data),
      fromJson,
    );
  }

  // ===== REQUEST IMPLEMENTATIONS =====

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

    _logResponse(response);
    return response;
  }

  Future<http.Response> _postRequest(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    final token = await _getAuthToken(endpoint);
    final uri = _buildUri(endpoint);
    final body = data != null ? jsonEncode(data) : null;

    Log.d('API POST: $uri');
    Log.d('Body: $body');

    final response = await http
        .post(uri, headers: _getHeaders(token: token), body: body)
        .timeout(const Duration(milliseconds: ApiConstant.connectionTimeout));

    _logResponse(response);
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
    Log.d('Body: $body');

    final response = await http
        .put(uri, headers: _getHeaders(token: token), body: body)
        .timeout(const Duration(milliseconds: ApiConstant.connectionTimeout));

    _logResponse(response);
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
    Log.d('Body: $body');

    final response = await http
        .patch(uri, headers: _getHeaders(token: token), body: body)
        .timeout(const Duration(milliseconds: ApiConstant.connectionTimeout));

    _logResponse(response);
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
    Log.d('Body: $body');

    final response = await http
        .delete(uri, headers: _getHeaders(token: token), body: body)
        .timeout(const Duration(milliseconds: ApiConstant.connectionTimeout));

    _logResponse(response);
    return response;
  }

  // ===== HELPER METHODS =====

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final uri = Uri.parse('${ApiConstant.baseUrl}$endpoint');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(queryParameters: queryParameters.map(
      (key, value) => MapEntry(key, value.toString()),
    ));
  }

  /// Get auth token for request
  Future<String?> _getAuthToken(String endpoint) async {
    if (_isPublicEndpoint(endpoint)) {
      return null;
    }
    return UserPreferences.getAccessToken();
  }

  /// Log response for debugging
  void _logResponse(http.Response response) {
    Log.d('Response Status: ${response.statusCode}');
    Log.d('Response Body: ${response.body}');
  }

  // ===== REQUEST HANDLER =====

  /// Handle API request with error handling
  Future<ApiResponse<T>> _handleRequest<T>(
    Future<http.Response> Function() request,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    // Check connectivity first
    if (!await hasConnectivity()) {
      return ApiResponse<T>(
        success: false,
        message: 'noInternetConnection',
        statusCode: 0,
      );
    }

    try {
      final response = await request();

      // Handle 401 - try token refresh
      if (response.statusCode == ApiConstant.codeUnauthorized) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry request
          final retryResponse = await request();
          return _parseResponse<T>(retryResponse, fromJson);
        } else {
          // Clear session
          await UserPreferences.clearUserData();
          return ApiResponse<T>(
            success: false,
            message: 'sessionExpired',
            statusCode: response.statusCode,
          );
        }
      }

      return _parseResponse<T>(response, fromJson);
    } on TimeoutException catch (e) {
      Log.e('Request Timeout', e);
      return ApiResponse<T>(
        success: false,
        message: 'connectionTimeout',
        statusCode: 408,
      );
    } catch (e) {
      Log.e('API Request Error', e);
      return ApiResponse<T>(
        success: false,
        message: 'somethingWentWrong',
        statusCode: 500,
      );
    }
  }

  /// Parse HTTP response
  ApiResponse<T> _parseResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    try {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      final success = responseData[ApiConstant.keySuccess] as bool? ??
          response.statusCode == ApiConstant.codeSuccess;
      final message = responseData[ApiConstant.keyMessage]?.toString() ??
          _getStatusMessage(response.statusCode);
      final data = responseData[ApiConstant.keyData];
      final errors =
          responseData[ApiConstant.keyErrors] as Map<String, dynamic>?;

      if (success && data != null && fromJson != null) {
        if (data is List) {
          return ApiResponse<T>(
            success: true,
            message: message,
            data: null,
            dataList: data
                .map((e) => fromJson(e as Map<String, dynamic>))
                .toList(),
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse<T>(
            success: true,
            message: message,
            data: fromJson(data as Map<String, dynamic>),
            statusCode: response.statusCode,
          );
        }
      }

      return ApiResponse<T>(
        success: success,
        message: message,
        errors: _parseErrors(errors),
        statusCode: response.statusCode,
      );
    } catch (e) {
      Log.e('Response Parse Error', e);
      return ApiResponse<T>(
        success: false,
        message: 'parseError',
        statusCode: response.statusCode,
      );
    }
  }

  /// Refresh access token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await UserPreferences.getRefreshToken();
      if (refreshToken == null) return false;

      final uri = _buildUri(ApiConstant.refreshToken);
      final response = await http.post(
        uri,
        headers: ApiConstant.defaultHeaders,
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == ApiConstant.codeSuccess) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tokenData = data[ApiConstant.keyData] as Map<String, dynamic>;

        await UserPreferences.saveTokens(
          accessToken: tokenData[ApiConstant.keyAccessToken] as String,
          refreshToken: tokenData[ApiConstant.keyRefreshToken] as String,
          expiresIn: tokenData[ApiConstant.keyExpiresIn] as int,
        );

        return true;
      }
    } catch (e) {
      Log.e('Token Refresh Error', e);
    }
    return false;
  }

  /// Get status message from code
  String _getStatusMessage(int statusCode) {
    switch (statusCode) {
      case ApiConstant.codeSuccess:
      case ApiConstant.codeCreated:
        return 'success';
      case ApiConstant.codeBadRequest:
        return 'badRequest';
      case ApiConstant.codeUnauthorized:
        return 'unauthorized';
      case ApiConstant.codeForbidden:
        return 'forbidden';
      case ApiConstant.codeNotFound:
        return 'notFound';
      case ApiConstant.codeValidationError:
        return 'validationError';
      case ApiConstant.codeServerError:
        return 'serverError';
      case ApiConstant.codeServiceUnavailable:
        return 'serviceUnavailable';
      default:
        return 'somethingWentWrong';
    }
  }

  /// Parse validation errors
  Map<String, String>? _parseErrors(Map<String, dynamic>? errors) {
    if (errors == null) return null;

    final result = <String, String>{};
    errors.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        result[key] = value.first.toString();
      } else if (value is String) {
        result[key] = value;
      }
    });

    return result.isNotEmpty ? result : null;
  }

  // ===== MULTIPART UPLOAD =====

  /// Upload file with multipart request
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required String fieldName,
    required String filePath,
    Map<String, dynamic>? fields,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    if (!await hasConnectivity()) {
      return ApiResponse<T>(
        success: false,
        message: 'noInternetConnection',
        statusCode: 0,
      );
    }

    try {
      final token = await _getAuthToken(endpoint);
      final uri = _buildUri(endpoint);

      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(_getHeaders(token: token))
        ..files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      if (fields != null) {
        fields.forEach((key, value) {
          request.fields[key] = value.toString();
        });
      }

      final streamedResponse = await request.send().timeout(
        const Duration(milliseconds: ApiConstant.connectionTimeout),
      );

      final response = await http.Response.fromStream(streamedResponse);
      return _parseResponse<T>(response, fromJson);
    } catch (e) {
      Log.e('Upload Error', e);
      return ApiResponse<T>(
        success: false,
        message: 'uploadFailed',
        statusCode: 500,
      );
    }
  }
}

/// Generic API Response wrapper
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<dynamic>? dataList;
  final Map<String, String>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.dataList,
    this.errors,
    this.statusCode,
  });

  bool get hasErrors => errors != null && errors!.isNotEmpty;
  bool get hasData => data != null || dataList != null;
}
