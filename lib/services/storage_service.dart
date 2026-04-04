import 'package:shared_preferences/shared_preferences.dart';

class StorageKeys {
  StorageKeys._();

  static const String token = 'token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String isFirstTime = 'is_first_time';
}

class StorageService {
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
  }

  // Token
  String? getToken() => _prefs.getString(StorageKeys.token);

  Future<void> saveToken(String value) =>
      _prefs.setString(StorageKeys.token, value);

  Future<void> removeToken() => _prefs.remove(StorageKeys.token);

  // Theme
  bool getThemeMode() => _prefs.getBool(StorageKeys.themeMode) ?? false;

  Future<void> saveThemeMode(bool isDark) =>
      _prefs.setBool(StorageKeys.themeMode, isDark);

  // Locale
  String? getLanguageCode() => _prefs.getString(StorageKeys.locale);

  Future<void> saveLanguageCode(String code) =>
      _prefs.setString(StorageKeys.locale, code);

  // Auth
  bool get isLoggedIn {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clear() => _prefs.clear();
}
