import 'package:shared_preferences/shared_preferences.dart';

/// Storage keys for SharedPreferences.
class StorageKeys {
  StorageKeys._();

  // Token keys
  static const String token = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiresAt = 'token_expires_at';

  // User keys
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userType = 'user_type';

  // Auth state
  static const String isLoggedIn = 'is_logged_in';
  static const String isFirstTime = 'is_first_time';
  static const String hasSeenOnboarding = 'has_seen_onboarding';

  // App settings
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';

  // Legacy keys for migration (old keys used by StorageService)
  static const String legacyToken = 'token';
}

/// Unified storage service for all app data.
///
/// This service handles:
/// - JWT tokens (access token, refresh token, expiration)
/// - User details (id, name, email, type)
/// - Auth state (logged in status)
/// - App settings (theme, language)
class StorageService {
  // Constants for user types
  static const String USER_TYPE_CUSTOMER = 'customer';
  static const String USER_TYPE_SERVICE_PROVIDER = 'provider';
  static const String DEFAULT_LANGUAGE = 'en';

  static late StorageService _instance;
  static bool _initialized = false;

  late final SharedPreferences _prefs;

  StorageService._(this._prefs);

  factory StorageService() {
    assert(_initialized, 'StorageService.init() must be called first');
    return _instance;
  }

  static Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _instance = StorageService._(prefs);
    _initialized = true;

    // Migrate legacy token if exists
    await _instance._migrateLegacyToken();
  }

  /// Migrate old 'token' key to new 'access_token' key
  Future<void> _migrateLegacyToken() async {
    final legacyToken = _prefs.getString(StorageKeys.legacyToken);
    if (legacyToken != null && legacyToken.isNotEmpty) {
      final currentToken = _prefs.getString(StorageKeys.token);
      if (currentToken == null || currentToken.isEmpty) {
        await _prefs.setString(StorageKeys.token, legacyToken);
      }
      // Keep legacy token for backward compatibility
    }
  }

  // ==================== TOKEN MANAGEMENT ====================

  /// Get access token (async for consistency)
  Future<String?> getAccessToken() async => _prefs.getString(StorageKeys.token);

  /// Get access token (sync - for backward compatibility)
  String? getToken() => _prefs.getString(StorageKeys.token);

  /// Get refresh token
  /// Handles migration from old `_refreshToken` key
  Future<String?> getRefreshToken() async {
    // Try new key first
    var token = _prefs.getString(StorageKeys.refreshToken);

    // If not found, try old key format (from UserPreferences)
    if (token == null || token.isEmpty) {
      token = _prefs.getString('_refreshToken');
      if (token != null && token.isNotEmpty) {
        // Migrate to new key
        await _prefs.setString(StorageKeys.refreshToken, token);
      }
    }

    return token;
  }

  /// Get refresh token (sync)
  String? getRefreshTokenSync() => _prefs.getString(StorageKeys.refreshToken);

  /// Save both access and refresh tokens with expiration
  /// [expiresIn] is in SECONDS (standard JWT / OAuth format from backend)
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    // expiresIn is in SECONDS from backend - convert to milliseconds
    // Calculate expiration time (Unix timestamp in milliseconds)
    final expiresAt =
        DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);

    await Future.wait([
      _prefs.setString(StorageKeys.token, accessToken),
      _prefs.setString(StorageKeys.refreshToken, refreshToken),
      _prefs.setInt(StorageKeys.tokenExpiresAt, expiresAt),
      _prefs.setBool(StorageKeys.isLoggedIn, true),
    ]);
  }

  /// Save access token only (backward compatibility)
  Future<void> saveToken(String value) async {
    await _prefs.setString(StorageKeys.token, value);
  }

  /// Remove access token (backward compatibility)
  Future<void> removeToken() async {
    await _prefs.remove(StorageKeys.token);
  }

  /// Check if token is expired
  /// Returns true if expired or no token exists
  /// Handles both old String format (ISO 8601) and new int format (milliseconds)
  Future<bool> isTokenExpired() async {
    // Try to get as int first (new format)
    int? expiresAt = _prefs.getInt(StorageKeys.tokenExpiresAt);

    // If not found as int, try string (old format from UserPreferences)
    if (expiresAt == null) {
      final expiresAtString = _prefs.getString(StorageKeys.tokenExpiresAt);
      if (expiresAtString != null) {
        try {
          final parsedDate = DateTime.tryParse(expiresAtString);
          if (parsedDate != null) {
            expiresAt = parsedDate.millisecondsSinceEpoch;
            // Migrate to new format
            await _prefs.setInt(StorageKeys.tokenExpiresAt, expiresAt);
          }
        } catch (e) {
          // Invalid date format, treat as expired
          return true;
        }
      }
    }

    if (expiresAt == null) return true;

    // Consider token expired 5 minutes before actual expiration
    final buffer = const Duration(minutes: 5).inMilliseconds;
    return DateTime.now().millisecondsSinceEpoch > (expiresAt - buffer);
  }

  /// Check if valid tokens exist
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;
  }

  // ==================== USER DETAILS ====================

  /// Save user details
  Future<void> saveUserDetails({
    required String userId,
    required String name,
    required String email,
    required String userType,
  }) async {
    await Future.wait([
      _prefs.setString(StorageKeys.userId, userId),
      _prefs.setString(StorageKeys.userName, name),
      _prefs.setString(StorageKeys.userEmail, email),
      _prefs.setString(StorageKeys.userType, userType),
    ]);
  }

  /// Get user details as a map
  Future<Map<String, String>?> getUserDetails() async {
    final id = _prefs.getString(StorageKeys.userId);
    final name = _prefs.getString(StorageKeys.userName);
    final email = _prefs.getString(StorageKeys.userEmail);
    final type = _prefs.getString(StorageKeys.userType);

    if (id == null || name == null || email == null || type == null) {
      return null;
    }

    return {'id': id, 'name': name, 'email': email, 'type': type};
  }

  /// Get user type
  Future<String> getUserType() async {
    return _prefs.getString(StorageKeys.userType) ?? 'customer';
  }

  /// Set user type
  Future<void> setUserType(String userType) async {
    await _prefs.setString(StorageKeys.userType, userType);
  }

  /// Check if user type is set
  Future<bool> hasUserType() async {
    return _prefs.containsKey(StorageKeys.userType);
  }

  // ==================== AUTH STATE ====================

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final loggedIn = _prefs.getBool(StorageKeys.isLoggedIn) ?? false;
    return loggedIn && token != null && token.isNotEmpty;
  }

  /// Set logged in status
  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(StorageKeys.isLoggedIn, value);
  }

  /// Check login status synchronously (checks token only)
  bool get isLoggedInSync {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== ONBOARDING ====================

  /// Check if this is first time opening app
  Future<bool> isFirstTime() async {
    return _prefs.getBool(StorageKeys.isFirstTime) ?? true;
  }

  /// Set first time complete
  Future<void> setFirstTimeComplete() async {
    await _prefs.setBool(StorageKeys.isFirstTime, false);
  }

  /// Check if onboarding is completed
  Future<bool> hasCompletedOnboarding() async {
    return _prefs.getBool(StorageKeys.hasSeenOnboarding) ?? false;
  }

  /// Mark onboarding as complete
  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(StorageKeys.hasSeenOnboarding, true);
  }

  /// Reset onboarding flag (used on logout)
  Future<void> resetOnboarding() async {
    await _prefs.setBool(StorageKeys.hasSeenOnboarding, false);
  }

  // ==================== LANGUAGE ====================

  /// Get saved language code
  Future<String> getLanguageCode() async {
    return _prefs.getString(StorageKeys.locale) ?? 'en';
  }

  /// Save language code
  Future<void> saveLanguageCode(String code) async {
    await _prefs.setString(StorageKeys.locale, code);
  }

  // ==================== THEME ====================

  /// Get theme mode (true = dark)
  bool getThemeMode() {
    return _prefs.getBool(StorageKeys.themeMode) ?? false;
  }

  /// Save theme mode
  Future<void> saveThemeMode(bool isDark) async {
    await _prefs.setBool(StorageKeys.themeMode, isDark);
  }

  // ==================== CLEANUP ====================

  /// Clear all user data but preserve language preference
  Future<void> clearUserData() async {
    // Save language preference
    final languageCode = await getLanguageCode();

    // Remove all auth and user data
    await Future.wait([
      _prefs.remove(StorageKeys.token),
      _prefs.remove(StorageKeys.refreshToken),
      _prefs.remove(StorageKeys.tokenExpiresAt),
      _prefs.remove(StorageKeys.userId),
      _prefs.remove(StorageKeys.userName),
      _prefs.remove(StorageKeys.userEmail),
      _prefs.remove(StorageKeys.userType),
      _prefs.remove(StorageKeys.isLoggedIn),
      _prefs.remove(StorageKeys.hasSeenOnboarding),
    ]);

    // Restore language and reset first time
    await Future.wait([
      _prefs.setString(StorageKeys.locale, languageCode),
      _prefs.setBool(StorageKeys.isFirstTime, true),
    ]);
  }

  /// Clear everything (use with caution)
  Future<void> clear() async {
    await _prefs.clear();
  }
}
