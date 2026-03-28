import 'dart:async';
import 'dart:io';
import '../models/api_result.dart';
import '../constants/api_constant.dart';
import 'logger.dart';

/// Utility class for mapping exceptions and HTTP responses to typed errors.
/// 
/// Provides consistent error handling across the application by converting
/// various exception types and HTTP status codes to [Error] results.
class NetworkExceptionMapper {
  NetworkExceptionMapper._();

  /// Maps an exception to an [Error] result with appropriate error type and message.
  static Error<T> mapException<T>(dynamic exception, [StackTrace? stackTrace]) {
    Log.e('Network Exception', exception, stackTrace);

    // Handle specific exception types
    if (exception is TimeoutException) {
      return Error<T>(
        'Connection timeout. Please check your connection and try again.',
        statusCode: 408,
        errorType: ErrorType.timeout,
      );
    }

    if (exception is SocketException) {
      return Error<T>(
        'No internet connection. Please check your network settings.',
        statusCode: 0,
        errorType: ErrorType.noConnection,
      );
    }

    if (exception is HttpException) {
      final message = _parseHttpExceptionMessage(exception.message);
      return Error<T>(
        message,
        statusCode: 0,
        errorType: ErrorType.connectionLost,
      );
    }

    if (exception is FormatException) {
      return Error<T>(
        'Failed to process server response. Please try again.',
        statusCode: 0,
        errorType: ErrorType.parseError,
      );
    }

    if (exception is ClientException) {
      return Error<T>(
        'Connection failed. Please check your internet connection.',
        statusCode: 0,
        errorType: ErrorType.connectionLost,
      );
    }

    if (exception is TlsException) {
      return Error<T>(
        'Secure connection failed. Please try again later.',
        statusCode: 0,
        errorType: ErrorType.connectionLost,
      );
    }

    if (exception is HandshakeException) {
      return Error<T>(
        'Could not establish secure connection. Please try again.',
        statusCode: 0,
        errorType: ErrorType.connectionLost,
      );
    }

    if (exception is ConnectionClosedException) {
      return Error<T>(
        'Connection was closed unexpectedly. Please try again.',
        statusCode: 0,
        errorType: ErrorType.connectionLost,
      );
    }

    // Handle cancellation
    if (exception.toString().contains('cancelled')) {
      return Error<T>(
        'Request was cancelled.',
        statusCode: 0,
        errorType: ErrorType.cancelled,
      );
    }

    // Default to unknown error
    return Error<T>(
      _getUserFriendlyMessage(exception),
      statusCode: 0,
      errorType: ErrorType.unknown,
    );
  }

  /// Maps an HTTP status code to an [Error] result.
  static Error<T> mapStatusCode<T>(
    int statusCode,
    String? serverMessage, {
    Map<String, dynamic>? responseBody,
  }) {
    final message = serverMessage ?? _getDefaultMessageForStatus(statusCode);
    final validationErrors = _extractValidationErrors(responseBody);

    return Error<T>(
      message,
      statusCode: statusCode,
      validationErrors: validationErrors,
      errorType: _getErrorTypeForStatus(statusCode),
    );
  }

  /// Returns the appropriate [ErrorType] for an HTTP status code.
  static ErrorType _getErrorTypeForStatus(int statusCode) {
    return switch (statusCode) {
      >= 200 && < 300 => ErrorType.unknown, // Should not happen
      400 => ErrorType.validation,
      401 => ErrorType.unauthorized,
      403 => ErrorType.forbidden,
      404 => ErrorType.notFound,
      422 => ErrorType.validation,
      429 => ErrorType.rateLimited,
      503 => ErrorType.serviceUnavailable,
      >= 500 && < 600 => ErrorType.serverError,
      _ => ErrorType.unknown,
    };
  }

  /// Returns a user-friendly message for an HTTP status code.
  static String _getDefaultMessageForStatus(int statusCode) {
    return switch (statusCode) {
      400 => 'Invalid request. Please check your input.',
      401 => 'Session expired. Please login again.',
      403 => 'Access denied. You do not have permission.',
      404 => 'The requested resource was not found.',
      408 => 'Request timeout. Please try again.',
      409 => 'A conflict occurred. Please refresh and try again.',
      422 => 'Validation failed. Please check your input.',
      429 => 'Too many requests. Please wait a moment and try again.',
      500 => 'Server error. Please try again later.',
      502 => 'Server is temporarily unavailable. Please try again.',
      503 => 'Service temporarily unavailable. Please try again later.',
      504 => 'Server is not responding. Please try again later.',
      _ => 'Something went wrong. Please try again.',
    };
  }

  /// Extracts validation errors from response body.
  static Map<String, List<String>>? _extractValidationErrors(
    Map<String, dynamic>? responseBody,
  ) {
    if (responseBody == null) return null;

    final errors = <String, List<String>>{};

    // Handle common API error formats
    // Format 1: { "errors": { "email": ["Invalid email"] } }
    if (responseBody['errors'] is Map) {
      final errorsMap = responseBody['errors'] as Map<String, dynamic>;
      errorsMap.forEach((field, value) {
        if (value is List) {
          errors[field] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          errors[field] = [value];
        }
      });
    }

    // Format 2: { "error": { "email": "Invalid email" } }
    if (responseBody['error'] is Map) {
      final errorMap = responseBody['error'] as Map<String, dynamic>;
      errorMap.forEach((field, value) {
        if (value is List) {
          errors[field] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          errors[field] = [value];
        }
      });
    }

    // Format 3: { "detail": { "fields": [...] } }
    if (responseBody['detail'] is Map) {
      final detail = responseBody['detail'] as Map<String, dynamic>;
      if (detail['fields'] is List) {
        final fields = detail['fields'] as List;
        for (final field in fields) {
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

  /// Parses HTTP exception message for user-friendly display.
  static String _parseHttpExceptionMessage(String message) {
    if (message.contains('Connection refused')) {
      return 'Unable to connect to server. Please try again later.';
    }
    if (message.contains('Connection reset')) {
      return 'Connection was reset. Please try again.';
    }
    if (message.contains('Network unreachable')) {
      return 'Network is unreachable. Please check your connection.';
    }
    return 'Connection error. Please try again.';
  }

  /// Returns a user-friendly message for unknown exceptions.
  static String _getUserFriendlyMessage(dynamic exception) {
    final message = exception?.toString() ?? '';
    
    if (message.contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    }
    if (message.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    if (message.contains('FormatException')) {
      return 'Invalid server response. Please try again.';
    }
    
    return 'Something went wrong. Please try again.';
  }
}

/// Custom exception classes for better error categorization

/// Exception thrown when a client-side error occurs.
class ClientException implements Exception {
  final String message;
  final Uri? uri;

  const ClientException(this.message, [this.uri]);

  @override
  String toString() => 'ClientException: $message';
}

/// Exception thrown when connection is closed unexpectedly.
class ConnectionClosedException implements Exception {
  final String message;

  const ConnectionClosedException([this.message = 'Connection closed unexpectedly']);

  @override
  String toString() => 'ConnectionClosedException: $message';
}

/// Exception thrown when rate limit is exceeded.
class RateLimitException implements Exception {
  final String message;
  final Duration? retryAfter;

  const RateLimitException(this.message, [this.retryAfter]);

  @override
  String toString() => 'RateLimitException: $message';
}
