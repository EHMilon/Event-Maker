import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import '../../core/constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_text_button.dart';
import 'auth_controller.dart';

class ResetPasswordView extends GetView<AuthController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
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
                        "resetPassword".tr,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "pleaseResetPassword".tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                Obx(
                  () => CustomTextField(
                    labelText: "newPassword".tr,
                    hintText: "passwordPlaceholder".tr,
                    obscureText: controller.obscureNewPassword.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureNewPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.grey,
                        size: 20.sp,
                      ),
                      onPressed: controller.toggleNewPasswordVisibility,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Obx(
                  () => CustomTextField(
                    labelText: "confirmPassword".tr,
                    hintText: "passwordPlaceholder".tr,
                    obscureText: controller.obscureConfirmPassword.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscureConfirmPassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.grey,
                        size: 20.sp,
                      ),
                      onPressed: controller.toggleConfirmPasswordVisibility,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                PrimaryTextButton(
                  text: "confirm".tr,
                  onPressed: controller.onConfirmReset,
                ),
                SizedBox(height: 20.h), // Add some bottom spacing
              ],
            ),
          ),
        ),
      ),
    );
  }
}
