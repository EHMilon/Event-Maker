import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/user_preferences.dart';
import '../utils/logger.dart';
import '../constants/api_constant.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<bool> hasConnectivity() async {
    final status = await Connectivity().checkConnectivity();
    return !status.contains(ConnectivityResult.none);
  }

  Map<String, String> _getHeaders({String? token}) {
    final headers = Map<String, String>.from(ApiConstant.defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

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

  Future<ApiResponse> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    return _handleRequest(
      endpoint,
      () => _postRequest(endpoint, data: data),
    );
  }

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

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final uri = Uri.parse('${ApiConstant.baseUrl}$endpoint');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: queryParameters.map(
      (key, value) => MapEntry(key, value.toString()),
    ));
  }

  Future<String?> _getAuthToken(String endpoint) async {
    if (_isPublicEndpoint(endpoint)) {
      return null;
    }
    return UserPreferences.getAccessToken();
  }

  Future<ApiResponse> _handleRequest(
    String endpoint,
    Future<http.Response> Function() request,
  ) async {
    if (!await hasConnectivity()) {
      return ApiResponse(
        success: false,
        message: 'No internet connection',
        statusCode: 0,
      );
    }

    try {
      final response = await request();

      // Parse the response body
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final message = responseBody['message']?.toString() ?? '';

      // Handle 401 - check if user was logged in or not
      if (response.statusCode == 401) {
        final hasToken = await UserPreferences.hasValidTokens();
        if (hasToken) {
          // Try to refresh token
          final refreshed = await _refreshToken();
          if (refreshed) {
            final retryResponse = await request();
            return _parseResponse(retryResponse);
          } else {
            await UserPreferences.clearUserData();
            return ApiResponse(
              success: false,
              message: 'Session expired. Please login again.',
              statusCode: 401,
            );
          }
        } else {
          // Not logged in - return the actual error from API
          return ApiResponse(
            success: false,
            message: message.isNotEmpty ? message : 'Invalid credentials',
            statusCode: 401,
          );
        }
      }

      // Handle 400 (validation errors)
      if (response.statusCode == 400) {
        return ApiResponse(
          success: false,
          message: message.isNotEmpty ? message : 'Invalid request',
          statusCode: 400,
        );
      }

      return _parseResponse(response);
    } on TimeoutException catch (e) {
      Log.e('Request Timeout', e);
      return ApiResponse(
        success: false,
        message: 'Connection timeout',
        statusCode: 408,
      );
    } catch (e) {
      Log.e('API Request Error', e);
      return ApiResponse(
        success: false,
        message: 'Something went wrong',
        statusCode: 500,
      );
    }
  }

  ApiResponse _parseResponse(http.Response response) {
    try {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final success = response.statusCode >= 200 && response.statusCode < 300;
      final message = responseData['message']?.toString() ?? '';

      // Always include the full response data on success
      if (success) {
        return ApiResponse(
          success: true,
          message: message,
          data: responseData,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse(
        success: false,
        message: message.isNotEmpty ? message : 'Request failed',
        statusCode: response.statusCode,
      );
    } catch (e) {
      Log.e('Response Parse Error', e);
      return ApiResponse(
        success: false,
        message: 'Failed to parse response',
        statusCode: response.statusCode,
      );
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final storedRefreshToken = await UserPreferences.getRefreshToken();
      if (storedRefreshToken == null) return false;

      final uri = _buildUri(ApiConstant.refreshToken);
      final response = await http.post(
        uri,
        headers: ApiConstant.defaultHeaders,
        body: jsonEncode({'refresh_token': storedRefreshToken}),
      );

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
          return true;
        }
      }
    } catch (e) {
      Log.e('Token Refresh Error', e);
    }
    return false;
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });
}
