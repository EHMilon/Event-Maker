import 'package:get/get.dart';
import '../../app_routes.dart';
import '../../utils/logger.dart';
import '../../utils/user_preferences.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Log.i("SplashView initialized");
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    final isFirstTime = await UserPreferences.isFirstTime();
    final hasCompletedOnboarding = await UserPreferences.hasCompletedOnboarding();
    final isLoggedIn = await UserPreferences.isLoggedIn();
    final hasValidTokens = await UserPreferences.hasValidTokens();
    final isTokenExpired = await UserPreferences.isTokenExpired();

    Log.i(
      "Splash navigation state -> firstTime: $isFirstTime, onboardingDone: $hasCompletedOnboarding, loggedIn: $isLoggedIn, hasValidTokens: $hasValidTokens, tokenExpired: $isTokenExpired",
    );

    if (!hasCompletedOnboarding) {
      Log.i("Navigating to Onboarding");
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    if (isFirstTime) {
      Log.i("Navigating to Language Selection");
      Get.offAllNamed(AppRoutes.languageSelection);
      return;
    }

    // Check if user is logged in AND has valid (non-expired) tokens
    if (isLoggedIn && hasValidTokens && !isTokenExpired) {
      final userType = await UserPreferences.getUserType();
      Log.i("User type: $userType, navigating to home");

      if (userType == UserPreferences.USER_TYPE_SERVICE_PROVIDER) {
        Get.offAllNamed(AppRoutes.serviceProviderHome);
      } else {
        Get.offAllNamed(AppRoutes.customerHome);
      }
      return;
    }

    // User was logged in but token is expired/invalid - try to refresh first
    if (isLoggedIn && (!hasValidTokens || isTokenExpired)) {
      Log.i("Token expired or invalid, attempting refresh...");

      // Try to refresh the token before logging out
      final refreshed = await UserPreferences.refreshTokenIfNeeded();

      if (refreshed) {
        Log.i("Token refreshed successfully, navigating to home");
        final userType = await UserPreferences.getUserType();
        if (userType == UserPreferences.USER_TYPE_SERVICE_PROVIDER) {
          Get.offAllNamed(AppRoutes.serviceProviderHome);
        } else {
          Get.offAllNamed(AppRoutes.customerHome);
        }
        return;
      }

      // Refresh failed - clear stale login state and redirect to login
      Log.i("Token refresh failed, redirecting to Login");
      await UserPreferences.setLoggedIn(false);
      final hasUserType = await UserPreferences.hasUserType();

      if (hasUserType) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }
    }

    final hasUserType = await UserPreferences.hasUserType();

    if (hasUserType) {
      Log.i("User type already selected; navigating to Login");
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    Log.i("Navigating to User Type selection");
    Get.offAllNamed(AppRoutes.userType);
  }
}
