import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/constants/app_constants.dart';
import 'package:event_maker/utils/logger.dart';
import 'package:event_maker/services/api_exception.dart';
import 'package:event_maker/services/connectivity_service.dart';
import 'package:event_maker/services/storage_service.dart';
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

  // Multipart এ Content-Type দেওয়া যাবে না — http নিজেই set করে
  Map<String, String> get _authHeader {
    final headers = <String, String>{};
    final token = _storage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
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
    return _request(
      () => _client.get(
        _buildUri(endpoint, queryParams: queryParams),
        headers: {..._headers, ...?extraHeaders},
      ),
    );
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) async {
    debugPrint(
      "POST Request to ${_buildUri(endpoint)} with body: ${jsonEncode(body)} and headers: ${{..._headers, ...?extraHeaders}}",
    );
    return _request(
      () => _client.post(
        _buildUri(endpoint),
        headers: {..._headers, ...?extraHeaders},
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) async {
    return _request(
      () => _client.put(
        _buildUri(endpoint),
        headers: {..._headers, ...?extraHeaders},
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    Map<String, String>? extraHeaders,
  }) async {
    return _request(
      () => _client.patch(
        _buildUri(endpoint),
        headers: {..._headers, ...?extraHeaders},
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? extraHeaders,
  }) async {
    return _request(
      () => _client.delete(
        _buildUri(endpoint),
        headers: {..._headers, ...?extraHeaders},
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
      // Add headers
      request.headers.addAll(_authHeader);

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

    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (e) {
      // Log raw body for debugging
      Log.e('Failed to parse response: ${response.body}');
      throw ApiException(message: "Invalid JSON response");
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic> || body is List) {
        return body;
      }
      throw ApiException(message: "Unexpected response format");
    }

    // Log error details for debugging
    Log.e('HTTP ${response.statusCode} Error: ${response.body}');
    
    throw ApiException.fromStatusCode(response.statusCode, body);
  }
}
