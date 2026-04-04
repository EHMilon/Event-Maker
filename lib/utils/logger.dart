import 'package:logger/logger.dart';

class Log {
  static final Logger _logger = Logger(
    filter: DevelopmentFilter(),
    printer: SimplePrinter(printTime: false, colors: true),
  );

  static void d(String message) => _logger.d(message);
  static void i(String message) => _logger.i(message);
  static void w(String message) => _logger.w(message);
  static void e(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  static void success(String message) => _logger.i("✅ SUCCESS: $message");
}
