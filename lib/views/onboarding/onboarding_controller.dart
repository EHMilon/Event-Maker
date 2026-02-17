import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/utils/logger.dart';
import '../../shared/utils/user_preferences.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<Map<String, String>> onboardingData = [
    {
      "title": AppStrings.onboardingTitle1,
      "subtitle": AppStrings.onboardingSubtitle1,
      "image": "assets/images/onbording_1.png",
    },
    {
      "title": AppStrings.onboardingTitle2,
      "subtitle": AppStrings.onboardingSubtitle2,
      "image": "assets/images/onbording_2.png",
    },
    {
      "title": AppStrings.onboardingTitle3,
      "subtitle": AppStrings.onboardingSubtitle3,
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
