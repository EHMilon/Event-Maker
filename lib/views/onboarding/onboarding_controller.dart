import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_routes.dart';
// import '../../core/constants/app_strings.dart';
import '../../utils/logger.dart';
import '../../utils/user_preferences.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "onboardingTitle1".tr,
      "subtitle": "onboardingSubtitle1".tr,
      "image": "assets/images/onbording_1.png",
    },
    {
      "title": "onboardingTitle2".tr,
      "subtitle": "onboardingSubtitle2".tr,
      "image": "assets/images/onbording_2.png",
    },
    {
      "title": "onboardingTitle3".tr,
      "subtitle": "onboardingSubtitle3".tr,
      "image": "assets/images/onboarding_3.png",
    },
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
    Log.d("Onboarding page changed to: $index");
  }

  Future<void> nextPage() async {
    if (currentPage.value < onboardingData.length - 1) {
      Log.i("Moving to next onboarding page");
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Log.i("Onboarding completed, navigating to Language Selection");
      await UserPreferences.setOnboardingComplete();
      Get.offAllNamed(AppRoutes.languageSelection);
    }
  }

  Future<void> skip() async {
    Log.i("Onboarding skipped");
    await UserPreferences.setOnboardingComplete();
    Get.offAllNamed(AppRoutes.languageSelection);
  }
}
