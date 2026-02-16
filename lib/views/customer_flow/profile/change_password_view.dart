import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/themes/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_text_button.dart';
import 'profile_controller.dart';

class ChangePasswordView extends GetView<ProfileController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isLoading.value,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  'Current Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: controller.currentPasswordController,
                  hintText: '********',
                  obscureText: !controller.isCurrentPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isCurrentPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.grey,
                    ),
                    onPressed: controller.toggleCurrentPasswordVisibility,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'New Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: controller.newPasswordController,
                  hintText: '********',
                  obscureText: !controller.isNewPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isNewPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.grey,
                    ),
                    onPressed: controller.toggleNewPasswordVisibility,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Confirm New Password',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: controller.confirmPasswordController,
                  hintText: '********',
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isConfirmPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.grey,
                    ),
                    onPressed: controller.toggleConfirmPasswordVisibility,
                  ),
                ),
                SizedBox(height: 200.h),
                PrimaryTextButton(
                  onPressed: () => controller.changePassword(),
                  text: 'Update',
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
