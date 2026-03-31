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

  // Async headers getter using UserPreferences (correct token source)
  Future<Map<String, String>> _getHeadersAsync() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await UserPreferences.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
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
