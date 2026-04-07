/// A sealed class hierarchy for representing API operation outcomes.
/// 
/// This pattern provides type-safe handling of success, error, and loading states
/// without relying on nullable values or exceptions for control flow.
/// 
/// Usage:
/// ```dart
/// final result = await authRepository.signIn(request);
/// switch (result) {
///   case Success(:final data):
///     // Handle success with data
///   case Error(:final message, :final statusCode):
///     // Handle error
///   case Loading():
///     // Show loading indicator
/// }
/// ```
sealed class Result<T> {
  const Result();
  
  /// Returns true if this is a Success result
  bool get isSuccess => this is Success<T>;
  
  /// Returns true if this is an Error result
  bool get isError => this is Error<T>;
  
  /// Returns true if this is a Loading result
  bool get isLoading => this is Loading<T>;
  
  /// Gets the data if Success, otherwise null
  T? get dataOrNull => switch (this) {
    Success<T>(data: final d) => d,
    _ => null,
  };
  
  /// Gets the error message if Error, otherwise null
  String? get messageOrNull => switch (this) {
    Error<T>(message: final m) => m,
    _ => null,
  };
  
  /// Maps the success data to a new type
  Result<R> map<R>(R Function(T data) mapper) => switch (this) {
    Success<T>(data: final d) => Success(mapper(d)),
    Error<T>(message: final m, statusCode: final c, validationErrors: final v, errorType: final e) =>
      Error(m, statusCode: c, validationErrors: v, errorType: e),
    Loading<T>() => const Loading(),
  };
  
  /// Executes callback on success, returns the same result
  Result<T> onSuccess(void Function(T data) callback) {
    if (this case Success<T>(data: final d)) {
      callback(d);
    }
    return this;
  }
  
  /// Executes callback on error, returns the same result
  Result<T> onError(void Function(String message, int? statusCode) callback) {
    if (this case Error<T>(message: final m, statusCode: final c)) {
      callback(m, c);
    }
    return this;
  }
}

/// Represents a successful API response with data
final class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  String toString() => 'Success(data: $data)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && data == other.data;
  
  @override
  int get hashCode => data.hashCode;
}

/// Represents a failed API response with error details
final class Error<T> extends Result<T> {
  final String message;
  final int? statusCode;
  final Map<String, List<String>>? validationErrors;
  final ErrorType errorType;
  
  const Error(
    this.message, {
    this.statusCode,
    this.validationErrors,
    this.errorType = ErrorType.unknown,
  });
  
  /// Returns all validation error messages as a single string
  String get validationMessage {
    if (validationErrors == null || validationErrors!.isEmpty) {
      return message;
    }
    
    final errors = <String>[];
    validationErrors!.forEach((field, messages) {
      for (final msg in messages) {
        errors.add('$field: $msg');
      }
    });
    return errors.isEmpty ? message : errors.join('\n');
  }
  
  /// Returns true if this is a network-related error
  bool get isNetworkError => 
      errorType == ErrorType.noConnection ||
      errorType == ErrorType.timeout ||
      errorType == ErrorType.connectionLost;
  
  /// Returns true if this is an authentication error
  bool get isAuthError => 
      statusCode == 401 || 
      errorType == ErrorType.unauthorized;
  
  /// Returns true if this is a validation error
  bool get isValidationError => 
      statusCode == 400 || 
      statusCode == 422 ||
      errorType == ErrorType.validation;
  
  @override
  String toString() => 'Error(message: $message, statusCode: $statusCode, errorType: $errorType)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error<T> &&
          message == other.message &&
          statusCode == other.statusCode &&
          errorType == other.errorType;
  
  @override
  int get hashCode => Object.hash(message, statusCode, errorType);
}

/// Represents a loading state during API operations
final class Loading<T> extends Result<T> {
  const Loading();
  
  @override
  String toString() => 'Loading()';
  
  @override
  bool operator ==(Object other) => other is Loading<T>;
  
  @override
  int get hashCode => 0;
}

/// Enumeration of error types for categorizing API failures
enum ErrorType {
  /// No internet connection available
  noConnection,
  
  /// Connection timeout occurred
  timeout,
  
  /// Connection was lost during request
  connectionLost,
  
  /// Server returned an error (5xx)
  serverError,
  
  /// Resource not found (404)
  notFound,
  
  /// Unauthorized access (401)
  unauthorized,
  
  /// Forbidden access (403)
  forbidden,
  
  /// Validation error (400, 422)
  validation,
  
  /// Rate limit exceeded (429)
  rateLimited,
  
  /// Service unavailable (503)
  serviceUnavailable,
  
  /// Failed to parse response
  parseError,
  
  /// Request was cancelled
  cancelled,
  
  /// Unknown error
  unknown,
  
  /// Session expired
  sessionExpired,
}