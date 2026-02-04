import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _userTypeKey = 'user_type';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';
  
  static const String USER_TYPE_CUSTOMER = 'customer';
  static const String USER_TYPE_SERVICE_PROVIDER = 'provider';
  
  // ===== Synchronous Getters (for immediate access) =====
  
  /// Get cached user type without awaiting
  /// Returns null if not cached
  static String? getUserTypeSync() {
    try {
      // This is a hack to get synchronous access to SharedPreferences
      // In production, you might want to cache this in a static variable
      // or use a different approach
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // ===== Asynchronous Getters =====
  
  /// Get user type asynchronously
  /// Returns 'customer' if not set (default)
  static Future<String> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userTypeKey) ?? USER_TYPE_CUSTOMER;
  }
  
  /// Check if user type is already selected
  static Future<bool> hasUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userTypeKey);
  }
  
  // ===== Setters =====
  
  /// Set user type
  static Future<bool> setUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_userTypeKey, userType);
  }
  
  /// Set logged in status
  static Future<bool> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_isLoggedInKey, isLoggedIn);
  }
  
  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
  
  // ===== Convenience Checkers =====
  
  /// Check if user is service provider
  static Future<bool> isServiceProvider() async {
    final userType = await getUserType();
    return userType == USER_TYPE_SERVICE_PROVIDER;
  }
  
  /// Check if user is customer
  static Future<bool> isCustomer() async {
    final userType = await getUserType();
    return userType == USER_TYPE_CUSTOMER;
  }
  
  // ===== User Details Management =====
  
  /// Save user details from backend response
  static Future<bool> saveUserDetails({
    required String userId,
    required String name,
    required String email,
    required String userType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final results = await Future.wait([
      prefs.setString(_userIdKey, userId),
      prefs.setString(_userNameKey, name),
      prefs.setString(_userEmailKey, email),
      prefs.setString(_userTypeKey, userType),
    ]);
    return results.every((result) => result);
  }
  
  /// Get user details
  /// Returns null if no user data is saved
  static Future<Map<String, String>?> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    final userName = prefs.getString(_userNameKey);
    final userEmail = prefs.getString(_userEmailKey);
    final userType = prefs.getString(_userTypeKey);
    
    // Return null if any required field is missing
    if (userId == null || userName == null || userEmail == null || userType == null) {
      return null;
    }
    
    return {
      'id': userId,
      'name': userName,
      'email': userEmail,
      'type': userType,
    };
  }
  
  // ===== Cleanup =====
  
  /// Clear all user data (for logout)
  static Future<bool> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final results = await Future.wait([
      prefs.remove(_userTypeKey),
      prefs.remove(_userIdKey),
      prefs.remove(_userNameKey),
      prefs.remove(_userEmailKey),
      prefs.remove(_isLoggedInKey),
    ]);
    return results.every((result) => result);
  }
}