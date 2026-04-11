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
      String message = 'Something went wrong';

      // First set default message based on status code
      switch (statusCode) {
        case 400:
          message = 'Bad request';
          break;
        case 401:
          message = 'Unauthorized';
          break;
        case 403:
          message = 'Forbidden';
          break;
        case 404:
          message = 'Not found';
          break;
        case 408:
          message = 'Request timeout';
          break;
        case 422:
          message = 'Validation error';
          break;
        case 500:
          message = 'Internal server error';
          break;
        case 503:
          message = 'Service unavailable';
          break;
      }

      // OVERRIDE with server message if available - ALWAYS prefer server provided message
      if (body != null && body is Map && body.containsKey('message')) {
        message = body['message'].toString();
      }

      return ApiException(message: message, statusCode: statusCode, data: body);
    }

  factory ApiException.noInternet() =>
      ApiException(message: 'No internet connection');

  factory ApiException.timeout() =>
      ApiException(message: 'Connection timed out');

  factory ApiException.unknown([Object? error]) =>
      ApiException(message: error?.toString() ?? 'An unexpected error occurred');

  factory ApiException.unauthorized([String? message]) =>
      ApiException(message: message ?? 'Unauthorized', statusCode: 401);

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
