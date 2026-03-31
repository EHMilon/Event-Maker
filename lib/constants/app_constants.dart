/// Application constants used throughout the app.
class AppConstants {
  AppConstants._();

  // Timeout in seconds for API calls
  static const int connectTimeout = 30;
  
  // App name
  static const String appName = 'Event Maker';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

}
enum UserType {
  customer,
  provider,
} 
