import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/utils/logger.dart';
import '../../shared/utils/user_preferences.dart';

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
    final isLoggedIn = await UserPreferences.isLoggedIn();

    Log.i("First time: $isFirstTime, Logged in: $isLoggedIn");

    if (!await UserPreferences.hasCompletedOnboarding()) {
      Log.i("Navigating to Onboarding");
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }
    final shouldShowLanguageSelection = isFirstTime || !await UserPreferences.hasCompletedOnboarding();
    if (shouldShowLanguageSelection) {
      Log.i("Navigating to Language Selection");
      Get.offAllNamed(AppRoutes.languageSelection);
      return;
    }

    if (isLoggedIn) {
      final userType = await UserPreferences.getUserType();
      Log.i("User type: $userType, navigating to home");

      if (userType == UserPreferences.USER_TYPE_SERVICE_PROVIDER) {
        Get.offAllNamed(AppRoutes.serviceProviderHome);
      } else {
        Get.offAllNamed(AppRoutes.customerHome);
      }
      return;
    }

    Log.i("Navigating to Onboarding");
    Get.offAllNamed(AppRoutes.onboarding);
  }
}
