import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constant.dart';

class UserPreferences {
  static const String _userTypeKey = 'user_type';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isFirstTimeKey = 'is_first_time';
  static const String _languageCodeKey = 'language_code';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  
  // JWT Token keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiresAtKey = 'token_expires_at';
  
  static const String USER_TYPE_CUSTOMER = 'customer';
  static const String USER_TYPE_SERVICE_PROVIDER = 'provider';
  
  // Default language is English
  static const String DEFAULT_LANGUAGE = 'en';
  
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
  
  /// Check if this is the user's first time opening the app
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }
  
  /// Mark that the user has opened the app
  static Future<bool> setFirstTimeComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_isFirstTimeKey, false);
  }
  
  /// Check if onboarding has been completed
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }
  
  /// Mark onboarding as complete
  static Future<bool> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_hasSeenOnboardingKey, true);
  }

  /// Reset onboarding flag (used when logging out)
  static Future<bool> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_hasSeenOnboardingKey, false);
  }
  
  /// Get the saved language code
  /// Returns 'en' (English) by default
  static Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey) ?? DEFAULT_LANGUAGE;
  }
  
  /// Save the selected language code
  static Future<bool> setLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_languageCodeKey, languageCode);
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
  
  // ===== JWT Token Management =====

  /// Attempt to refresh the access token if expired
  /// Returns true if token is valid (either not expired or successfully refreshed)
  static Future<bool> refreshTokenIfNeeded() async {
    final expired = await isTokenExpired();
    if (!expired) {
      return true;
    }

    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConstant.baseUrl}${ApiConstant.refreshToken}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final newAccessToken = body['access_token'] ?? body['accessToken'];
        final newRefreshToken = body['refresh_token'] ?? body['refreshToken'];
        final expiresIn = body['expires_in'] ?? body['expiresIn'] ?? 3600;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
            expiresIn: expiresIn is int ? expiresIn : int.tryParse(expiresIn.toString()) ?? 3600,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Save JWT tokens after login/signup
  static Future<bool> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    
    final results = await Future.wait([
      prefs.setString(_accessTokenKey, accessToken),
      prefs.setString(_refreshTokenKey, refreshToken),
      prefs.setString(_tokenExpiresAtKey, expiresAt.toIso8601String()),
    ]);
    
    return results.every((result) => result);
  }
  
  /// Get access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }
  
  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }
  
  /// Check if access token is expired
  static Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAtStr = prefs.getString(_tokenExpiresAtKey);
    
    if (expiresAtStr == null) return true;
    
    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null) return true;
    
    // Consider token expired 5 minutes before actual expiration
    return DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));
  }
  
  /// Check if user has valid tokens
  static Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }
  
  // ===== Cleanup =====
  
  /// Clear all user data (for logout) but keep language preference
  static Future<bool> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Save language preference before clearing
    final languageCode = prefs.getString(_languageCodeKey) ?? DEFAULT_LANGUAGE;
    
    final results = await Future.wait([
      prefs.remove(_userTypeKey),
      prefs.remove(_userIdKey),
      prefs.remove(_userNameKey),
      prefs.remove(_userEmailKey),
      prefs.remove(_isLoggedInKey),
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_tokenExpiresAtKey),
    ]);
    
    // Restore language preference
    await prefs.setString(_languageCodeKey, languageCode);
    await prefs.setBool(_isFirstTimeKey, true);
    await prefs.setBool(_hasSeenOnboardingKey, false);
    
    return results.every((result) => result);
  }
}
