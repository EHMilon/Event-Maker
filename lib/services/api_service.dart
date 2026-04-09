import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/constants/app_constants.dart';
import 'package:event_maker/utils/logger.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/services/connectivity_service.dart';
import 'package:event_maker/services/storage_service.dart';
import 'package:event_maker/utils/user_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  final StorageService _storage = StorageService();
  final ConnectivityService _connectivity = ConnectivityService();

  // Flag to prevent concurrent refresh attempts
  bool _isRefreshing = false;
  // Completer to queue requests waiting for token refresh
  Completer<bool>? _refreshCompleter;

  // Synchronous headers getter - uses StorageService for backward compatibility
  // For multipart requests, use _getAuthHeader() instead
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = _storage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Ensures the token is valid, refreshing if necessary.
  /// Returns true if a valid token is available, false otherwise.
  Future<bool> _ensureValidToken() async {
    // Check if token is expired
    final isExpired = await UserPreferences.isTokenExpired();
    if (!isExpired) {
      return true;
    }

    Log.d('=======> Token expired, attempting refresh...');

    // If already refreshing, wait for it to complete
    if (_isRefreshing) {
      Log.d('=======> Token refresh already in progress, waiting...');
      return _refreshCompleter?.future ?? Future.value(false);
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshed = await _refreshToken();
      _refreshCompleter?.complete(refreshed);
      return refreshed;
    } catch (e) {
      Log.e('=======> Token refresh failed', e);
      _refreshCompleter?.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// Attempts to refresh the access token using the refresh token.
  /// Returns true if successful, false otherwise.
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await UserPreferences.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        Log.e('=======> No refresh token available');
        await _handleAuthFailure();
        return false;
      }

      Log.d('=======> Calling refresh token endpoint...');

      final response = await _client
          .post(
            _buildUri(ApiConstant.refreshToken),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      Log.d(
        '=======> Refresh token response: ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final newAccessToken = body['access_token'] ?? body['accessToken'];
        final newRefreshToken = body['refresh_token'] ?? body['refreshToken'];
        final expiresIn = body['expires_in'] ?? body['expiresIn'] ?? 3600;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await UserPreferences.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
            expiresIn: expiresIn is int ? expiresIn : int.tryParse(expiresIn.toString()) ?? 3600,
          );
          Log.d('=======> Token refreshed successfully');
          return true;
        }
      }

      // Refresh failed - clear user data
      Log.e('=======> Token refresh failed with status ${response.statusCode}');
      await _handleAuthFailure();
      return false;
    } on TimeoutException {
      Log.e('=======> Token refresh timed out');
      await _handleAuthFailure();
      return false;
    } on SocketException {
      Log.e('=======> Token refresh network error');
      // Don't clear auth on network errors - user might be offline temporarily
      return false;
    } catch (e) {
      Log.e('=======> Token refresh error', e);
      await _handleAuthFailure();
      return false;
    }
  }

  /// Handles authentication failure by clearing user data.
  /// Subclasses or listeners can override this behavior.
  Future<void> _handleAuthFailure() async {
    Log.e('=======> Authentication failed - clearing user data');
    await UserPreferences.clearUserData();
    await _storage.removeToken();
  }

  // Async headers getter using UserPreferences (correct token source)
  Future<Map<String, String>> _getHeadersAsync() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await UserPreferences.getAccessToken();
    Log.d(
      '=======> _getHeadersAsync - Token retrieved: ${token != null ? "exists (${token.length} chars)" : "NULL"}',
    );
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      Log.d(
        '=======> _getHeadersAsync - Authorization header set: Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
      );
    } else {
      Log.e('=======> _getHeadersAsync - WARNING: No token available for authenticated request!');
    }
    return headers;
  }

  // Multipart এ Content-Type দেওয়া যাবে না — http নিজেই set করে
  Future<Map<String, String>> _getAuthHeader() async {
    final headers = <String, String>{};
    final token = await UserPreferences.getAccessToken();
    Log.d(
      '=======> Auth Header - Token retrieved: ${token != null ? "exists (${token.length} chars)" : "NULL"}',
    );
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      Log.d(
        '=======> Authorization header set: Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
      );
    } else {
      Log.e('=======> WARNING: No token available for authenticated request!');
    }
    return headers;
  }

  Uri _buildUri(String endpoint, {Map<String, dynamic>? queryParams}) {
    final uri = Uri.parse('${ApiConstant.baseUrl}$endpoint');
    if (queryParams != null) {
      return uri.replace(
        queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
    }
    return uri;
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? extraHeaders,
  }) async {
    // Ensure token is valid before making request
    await _ensureValidToken();
    final headers = await _getHeadersAsync();
    return _request(
      () => _client.get(
        _buildUri(endpoint, queryParams: queryParams),
        headers: {...headers, ...?extraHeaders},
      ),
    );
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) async {
    // Ensure token is valid before making request
    await _ensureValidToken();
    final headers = await _getHeadersAsync();
    debugPrint(
      "POST Request to ${_buildUri(endpoint)} with body: ${jsonEncode(body)} and headers: ${{...headers, ...?extraHeaders}}",
    );
    return _request(
      () => _client.post(
        _buildUri(endpoint),
        headers: {...headers, ...?extraHeaders},
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) async {
    // Ensure token is valid before making request
    await _ensureValidToken();
    final headers = await _getHeadersAsync();
    return _request(
      () => _client.put(
        _buildUri(endpoint),
        headers: {...headers, ...?extraHeaders},
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) async {
    // Ensure token is valid before making request
    await _ensureValidToken();
    final headers = await _getHeadersAsync();
    return _request(
      () => _client.patch(
        _buildUri(endpoint),
        headers: {...headers, ...?extraHeaders},
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? extraHeaders,
  }) async {
    // Ensure token is valid before making request
    await _ensureValidToken();
    final headers = await _getHeadersAsync();
    return _request(
      () => _client.delete(
        _buildUri(endpoint),
        headers: {...headers, ...?extraHeaders},
      ),
    );
  }

  Future<dynamic> multipart(
    String method,
    String endpoint, {
    Map<String, String> fields = const {},
    Map<String, File> files = const {},
  }) async {
    if (!await _connectivity.hasConnection) {
      throw ApiException.noInternet();
    }

    // Ensure token is valid before making request
    await _ensureValidToken();

    try {
      final request = http.MultipartRequest(method, _buildUri(endpoint));
      // Add headers (async token retrieval)
      request.headers.addAll(await _getAuthHeader());

      // Add normal fields
      request.fields.addAll(fields);

      // Add files (image, PDF, etc.)
      for (final entry in files.entries) {
        final file = entry.value;

        if (!file.existsSync()) {
          throw ApiException(message: "${entry.key} file not found");
        }

        // Detect mime type dynamically
        final mimeType = lookupMimeType(file.path)?.split('/');
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            file.path,
            contentType: mimeType != null
                ? MediaType(mimeType[0], mimeType[1])
                : MediaType('application', 'octet-stream'), // fallback
          ),
        );
      }
      // Send request
      final streamed = await request.send().timeout(
        Duration(seconds: AppConstants.connectTimeout),
      );
      final response = await http.Response.fromStream(streamed);
      // Log network
      Log.d(
        '=======> MULTIPART $method ${request.url} → ${response.statusCode}\n${response.body}',
      );
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException.timeout();
    } on SocketException {
      throw ApiException(message: 'Could not connect to server');
    } on ApiException {
      rethrow;
    } catch (e) {
      Log.e('Multipart error', e);
      throw ApiException.unknown(e);
    }
  }

  Future<dynamic> _request(Future<http.Response> Function() request) async {
    if (!await _connectivity.hasConnection) {
      throw ApiException.noInternet();
    }

    try {
      final response = await request().timeout(
        Duration(seconds: AppConstants.connectTimeout),
      );

      Log.d(
        '=======>  Method: ${response.request?.method} URL: ${response.request?.url} Status: ${response.statusCode} Body: ${response.body}',
      );
      Log.d(
        '=======>  Request Headers: ${response.request?.headers}',
      );

      // If we get a 401, try to refresh the token and retry once
      if (response.statusCode == 401) {
        Log.d('=======> Received 401, attempting token refresh...');
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the request with the new token
          Log.d('=======> Token refreshed, retrying request...');
          final retryResponse = await request().timeout(
            Duration(seconds: AppConstants.connectTimeout),
          );
          Log.d(
            '=======>  Retry Method: ${retryResponse.request?.method} URL: ${retryResponse.request?.url} Status: ${retryResponse.statusCode} Body: ${retryResponse.body}',
          );
          return _processResponse(retryResponse);
        }
      }

      return _processResponse(response);
    } on TimeoutException {
      throw ApiException.timeout();
    } on SocketException {
      throw ApiException(message: 'Could not connect to server');
    } on ApiException {
      rethrow;
    } catch (e) {
      Log.e('Network error', e);
      throw ApiException.unknown(e);
    }
  }

  /// Submit provider report to backend
  /// POST /api/providers/submit-report
  Future<dynamic> submitProviderReport({
    required int providerId,
    required String issue,
    required String tellUsMore,
  }) async {
    return post(
      ApiConstant.submitProviderReport,
      body: {
        'provider_id': providerId,
        'issue': issue,
        'tell_us_more': tellUsMore,
      },
    );
  }

  dynamic _processResponse(http.Response response) {
    dynamic body;

    // Log the raw response for debugging
    Log.d('=======> Response Status: ${response.statusCode}');
    Log.d('=======> Response Body: ${response.body}');
    Log.d('=======> Response Headers: ${response.headers}');

    // Handle empty response body
    if (response.body.isEmpty) {
      // For successful requests with empty body, return empty map
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Log.d('=======> Empty response body for successful request');
        return {};
      }
      // For error responses with empty body
      throw ApiException.fromStatusCode(response.statusCode, {'message': 'Empty response from server'});
    }

    try {
      body = jsonDecode(response.body);
    } catch (e) {
      // Log raw body for debugging
      Log.e('=======> Failed to parse JSON response: ${response.body}');
      // Check if it's an HTML error page
      if (response.body.contains('<!DOCTYPE') || response.body.contains('<html')) {
        throw ApiException(message: "Server returned HTML error page (status ${response.statusCode})");
      }
      throw ApiException(message: "Invalid JSON response: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}");
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic> || body is List) {
        return body;
      }
      // Handle primitive responses (string, number, etc.)
      if (body is String || body is num || body is bool) {
        return {'data': body};
      }
      Log.d('=======> Unexpected response format: ${body.runtimeType}');
      return body;
    }

    // Log error details for debugging
    Log.e('=======> HTTP ${response.statusCode} Error: ${response.body}');

    throw ApiException.fromStatusCode(response.statusCode, body);
  }
}
