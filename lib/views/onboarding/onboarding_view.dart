import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'onboarding_controller.dart';
import '../../constants/app_colors.dart';
// import '../../core/constants/app_strings.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  SystemUiOverlayStyle get _overlayStyle => SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _overlayStyle,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Background PageView
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.onboardingData.length,
              itemBuilder: (context, index) {
                final item = controller.onboardingData[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(item["image"]!, fit: BoxFit.cover),
                    // Gradient overlay for text readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.black.withOpacity(0.8),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            item["title"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            item["subtitle"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.8),
                              fontSize: 15.sp,
                            ),
                          ),
                          SizedBox(height: 160.h),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            // Skip Button
            Positioned(
              top: 50.h,
              right: 20.w,
              child: TextButton(
                onPressed: controller.skip,
                child: Text(
                  "skip".tr,
                  style: TextStyle(color: AppColors.white, fontSize: 16.sp),
                ),
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 50.h,
              left: 40.w,
              right: 40.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots Indicator
                  Obx(
                    () => Row(
                      children: List.generate(
                        controller.onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.only(right: 8.w),
                          height: 8.h,
                          width: controller.currentPage.value == index
                              ? 24.w
                              : 8.w,
                          decoration: BoxDecoration(
                            color: controller.currentPage.value == index
                                ? AppColors.white
                                : AppColors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Next Button
                  GestureDetector(
                    onTap: controller.nextPage,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "next".tr,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
