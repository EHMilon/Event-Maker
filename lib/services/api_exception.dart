class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromStatusCode(int statusCode, [dynamic body]) {
    switch (statusCode) {
      case 400:
        return ApiException(message: 'Bad request', statusCode: statusCode, data: body);
      case 401:
        return ApiException(message: 'Unauthorized', statusCode: statusCode, data: body);
      case 403:
        return ApiException(message: 'Forbidden', statusCode: statusCode, data: body);
      case 404:
        return ApiException(message: 'Not found', statusCode: statusCode, data: body);
      case 408:
        return ApiException(message: 'Request timeout', statusCode: statusCode, data: body);
      case 422:
        return ApiException(message: 'Validation error', statusCode: statusCode, data: body);
      case 500:
        return ApiException(message: 'Internal server error', statusCode: statusCode, data: body);
      case 503:
        return ApiException(message: 'Service unavailable', statusCode: statusCode, data: body);
      default:
        return ApiException(message: 'Something went wrong', statusCode: statusCode, data: body);
    }
  }

  factory ApiException.noInternet() =>
      ApiException(message: 'No internet connection');

  factory ApiException.timeout() =>
      ApiException(message: 'Connection timed out');

  factory ApiException.unknown([Object? error]) =>
      ApiException(message: error?.toString() ?? 'An unexpected error occurred');

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
