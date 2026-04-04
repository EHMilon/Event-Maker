import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'language_selection_controller.dart';
import '../../constants/app_colors.dart';
import '../../localization/app_localization.dart';
import '../../widgets/primary_text_button.dart';

/// Language selection screen shown to first-time users
///
/// Allows users to select their preferred language (English or Arabic)
/// Default and fallback language is English
class LanguageSelectionView extends GetView<LanguageSelectionController> {
  const LanguageSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 60.h),

              // App Icon/Logo
              Image.asset('assets/images/icon.png', height: 60.h),
              SizedBox(height: 24.h),

              // Title
              Text(
                'selectLanguage'.tr,
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              SizedBox(height: 8.h),

              // Subtitle
              Text(
                'selectLanguageSubtitle'.tr,
                style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              ),

              SizedBox(height: 48.h),

              // Language Options
              Expanded(
                child: Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _languageOption(
                        language: SupportedLanguage.english,
                        isSelected: controller.selectedLanguage.value == SupportedLanguage.english,
                        onTap: () => controller.selectLanguage(SupportedLanguage.english),
                      ),
                      SizedBox(height: 16.h),
                      _languageOption(
                        language: SupportedLanguage.arabic,
                        isSelected: controller.selectedLanguage.value == SupportedLanguage.arabic,
                        onTap: () => controller.selectLanguage(SupportedLanguage.arabic),
                      ),
                    ],
                  ),
                ),
              ),

              // Continue Button
              Padding(
                padding: EdgeInsets.only(bottom: 40.h),
                child: Obx(
                  () => PrimaryTextButton(
                    text: controller.isLoading.value ? 'loading'.tr : 'continueText'.tr,
                    onPressed: controller.isLoading.value ? () {} : controller.onContinue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Language option widget
  Widget _languageOption({required SupportedLanguage language, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3), width: isSelected ? 2.w : 1.w),
        ),
        child: Row(
          children: [
            // Flag
            Text(language.flag, style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 16.w),
            // Language name
            Expanded(
              child: Text(
                language.name,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            // Selection indicator
            if (isSelected) Icon(Icons.check_circle, color: AppColors.primary, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
