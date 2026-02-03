import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../shared/utils/logger.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Log.i("SplashView initialized");
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() async {
    // 2s delay as requested in user rules
    await Future.delayed(const Duration(seconds: 2));
    Log.i("Navigating to Onboarding");
    Get.offAllNamed(AppRoutes.onboarding);
  }
}
