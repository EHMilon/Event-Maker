import 'package:get/get.dart';
import '../../app_routes.dart';
import '../../utils/logger.dart';
import '../../services/storage_service.dart';

/// Controller for Splash screen navigation logic.
///
/// Determines the next screen based on:
/// - First time app usage
/// - Onboarding completion
/// - User login status
/// - Token validity (with automatic refresh)
class SplashController extends GetxController {
  final StorageService _storage = StorageService();

  @override
  void onInit() {
    super.onInit();
    Log.i("SplashView initialized");
    print("Milon: onInit started");
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    print("Milon: _navigateToNextScreen started, waiting 2 seconds");
    await Future.delayed(const Duration(seconds: 2));
    print("Milon: 2 seconds passed");

    try {
      final isFirstTime = await _storage.isFirstTime();
      final hasCompletedOnboarding = await _storage.hasCompletedOnboarding();
      final isLoggedIn = await _storage.isLoggedIn();
      final hasValidTokens = await _storage.hasValidTokens();
      final isTokenExpired = await _storage.isTokenExpired();

      Log.i(
        "Splash navigation state -> firstTime: $isFirstTime, onboardingDone: $hasCompletedOnboarding, loggedIn: $isLoggedIn, hasValidTokens: $hasValidTokens, tokenExpired: $isTokenExpired",
      );
      print("Milon: Splash navigation state -> firstTime: $isFirstTime");

      // Priority 1: Onboarding not completed
      if (!hasCompletedOnboarding) {
        Log.i("Navigating to Onboarding");
        Get.offAllNamed(AppRoutes.onboarding);
        return;
      }

      // Priority 2: First time after onboarding
      if (isFirstTime) {
        Log.i("Navigating to Language Selection");
        Get.offAllNamed(AppRoutes.languageSelection);
        return;
      }

      // Priority 3: Check if user has valid session
      if (isLoggedIn && hasValidTokens && !isTokenExpired) {
        final userType = await _storage.getUserType();
        Log.i("User type: $userType, navigating to home");

        if (userType == StorageService.USER_TYPE_SERVICE_PROVIDER) {
          Get.offAllNamed(AppRoutes.serviceProviderHome);
        } else {
          Get.offAllNamed(AppRoutes.customerHome);
        }
        return;
      }

      // Priority 4: User was logged in but token expired - try to refresh
      if (isLoggedIn && hasValidTokens && isTokenExpired) {
        Log.i("Token expired, attempting silent refresh on splash...");

        // Note: Actual token refresh will happen on first API call via ApiService
        // We just check here if tokens exist to potentially navigate to home
        // The real validation happens when making authenticated requests

        // For now, if we have a refresh token, assume we can refresh it
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final userType = await _storage.getUserType();
          Log.i("Refresh token exists, navigating to home for token refresh");

          if (userType == StorageService.USER_TYPE_SERVICE_PROVIDER) {
            Get.offAllNamed(AppRoutes.serviceProviderHome);
          } else {
            Get.offAllNamed(AppRoutes.customerHome);
          }
          return;
        }

        // Refresh token missing - clear auth and redirect to login
        Log.i("No refresh token available, redirecting to Login");
        await _storage.clearUserData();
      }

      // Priority 5: Has user type selected
      final hasUserType = await _storage.hasUserType();
      if (hasUserType) {
        Log.i("User type already selected; navigating to Login with UserType as base");
        // We navigate to UserType first, then Login to ensure back button works
        Get.offAllNamed(AppRoutes.userType);
        // Use a microtask to ensure UserType's binding is fully registered before pushing Login
        Future.microtask(() => Get.toNamed(AppRoutes.login));
        return;
      }

      // Priority 6: New user, select type
      Log.i("Navigating to User Type selection");
      Get.offAllNamed(AppRoutes.userType);
    } catch (e) {
      Log.e("Error in splash navigation", e);
      // On error, default to onboarding
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
