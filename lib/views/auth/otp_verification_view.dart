import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../core/constants/app_strings.dart';
import '../../core/themes/app_colors.dart';
import '../../shared/widgets/primary_text_button.dart';
import 'auth_controller.dart';

class OtpVerificationView extends GetView<AuthController> {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56.w,
      height: 56.w,
      textStyle: TextStyle(
        fontSize: 20.sp,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12.r),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/images/icon.png', height: 40.h),
                      SizedBox(height: 20.h),
                      Text(
                        AppStrings.verifyEmail,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppStrings.verifyEmailSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                Center(
                  child: Pinput(
                    length: 4,
                    separatorBuilder: (index) => SizedBox(width: 12.w),
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyDecorationWith(
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    submittedPinTheme: defaultPinTheme.copyDecorationWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.didntGetOtp,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.onResend,
                        child: Text(
                          AppStrings.resend,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                PrimaryTextButton(
                  text: AppStrings.verify,
                  onPressed: controller.onVerify,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
