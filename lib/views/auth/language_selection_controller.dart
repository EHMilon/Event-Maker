import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/user_preferences.dart';
import '../../app_routes.dart';
import '../../localization/app_localization.dart';

/// Controller for language selection screen
/// 
/// Handles language selection and navigation to user type screen
class LanguageSelectionController extends GetxController {
  // Observable state for selected language
  final Rx<SupportedLanguage> selectedLanguage = SupportedLanguage.english.obs;
  
  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  /// Load previously saved language preference
  Future<void> _loadSavedLanguage() async {
    try {
      final savedLanguageCode = await UserPreferences.getLanguageCode();
      selectedLanguage.value = SupportedLanguage.values.firstWhere(
        (lang) => lang.code == savedLanguageCode,
        orElse: () => SupportedLanguage.english,
      );
    } catch (e) {
      // Use default if there's an error
      selectedLanguage.value = SupportedLanguage.english;
    }
  }

  /// Select a language
  void selectLanguage(SupportedLanguage language) {
    selectedLanguage.value = language;
  }

  /// Continue to user type selection
  /// 
  /// TODO: Save language preference to backend when API is ready
  Future<void> onContinue() async {
    isLoading.value = true;
    
    try {
      // Save language preference locally
      await UserPreferences.setLanguageCode(selectedLanguage.value.code);
      
      // Update app locale
      Get.updateLocale(Locale(selectedLanguage.value.code));
      
      // TODO: Send language preference to backend API
      // Example API call:
      // await ApiService.updateUserLanguage(selectedLanguage.value.code);
      
      // Mark first time as complete
      await UserPreferences.setFirstTimeComplete();
      
      // Navigate to user type selection
      Get.offAllNamed(AppRoutes.userType);
    } catch (e) {
      // TODO: Handle error properly - show error snackbar
      Get.snackbar(
        'error'.tr,
        'somethingWentWrong'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Skip language selection and use default (English)
  Future<void> onSkip() async {
    isLoading.value = true;
    
    try {
      // Use default English
      await UserPreferences.setLanguageCode(SupportedLanguage.english.code);
      Get.updateLocale(Locale(AppLocalization.defaultLanguage));
      
      // Mark first time as complete
      await UserPreferences.setFirstTimeComplete();
      
      // Navigate to onboarding
      Get.offAllNamed(AppRoutes.userType);
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'somethingWentWrong'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
