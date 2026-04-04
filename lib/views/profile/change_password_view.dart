import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_text_button.dart';
import '../auth/auth_controller.dart';

class ChangePasswordView extends GetView<AuthController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        titleSpacing: (ModalRoute.of(context)?.canPop ?? false) ? 0 : 24.w,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'changePassword'.tr,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isLoading.value,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  'currentPassword'.tr,
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
                  obscureText: controller.obscureCurrentPassword.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureCurrentPassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grey,
                    ),
                    onPressed: controller.toggleCurrentPasswordVisibility,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'newPassword'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: controller.changeNewPasswordController,
                  hintText: '********',
                  obscureText: controller.obscureChangeNewPassword.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureChangeNewPassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grey,
                    ),
                    onPressed: controller.toggleChangeNewPasswordVisibility,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'confirmPassword'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: controller.changeConfirmPasswordController,
                  hintText: '********',
                  obscureText: controller.obscureChangeConfirmPassword.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureChangeConfirmPassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grey,
                    ),
                    onPressed: controller.toggleChangeConfirmPasswordVisibility,
                  ),
                ),
                Spacer(),
                PrimaryTextButton(
                  onPressed: controller.onChangePassword,
                  text: 'update'.tr,
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
