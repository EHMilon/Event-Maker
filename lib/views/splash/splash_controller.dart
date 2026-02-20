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
    final hasCompletedOnboarding = await UserPreferences.hasCompletedOnboarding();
    final isLoggedIn = await UserPreferences.isLoggedIn();

    Log.i(
      "Splash navigation state -> firstTime: $isFirstTime, onboardingDone: $hasCompletedOnboarding, loggedIn: $isLoggedIn",
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
