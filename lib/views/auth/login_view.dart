import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_strings.dart';
import '../../core/themes/app_colors.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/primary_text_button.dart';
import 'auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/images/icon.png', height: 40.h),
                      SizedBox(height: 20.h),
                      Text(
                        'login'.tr,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'welcomeBack'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                CustomTextField(
                  labelText: 'email'.tr,
                  hintText: 'emailPlaceholder'.tr,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                Obx(
                  () => CustomTextField(
                    labelText: 'password'.tr,
                    hintText: 'passwordPlaceholder'.tr,
                    obscureText: controller.obscurePassword.value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.obscurePassword.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.grey,
                        size: 20.sp,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Obx(
                      () => SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: Checkbox(
                          value: controller.rememberMe.value,
                          onChanged: controller.toggleRememberMe,
                          activeColor: AppColors.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => controller.toggleRememberMe(
                        !controller.rememberMe.value,
                      ),
                      child: Text(
                        'rememberMe'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: controller.onForgotPassword,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'forgotPassword'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30.h),
                PrimaryTextButton(
                  text: AppStrings.login,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      controller.onLogin();
                    }
                  },
                ),
                SizedBox(height: 20.h),
                Center(
                  child: GestureDetector(
                    onTap: controller.onSignUp,
                    child: RichText(
                      text: TextSpan(
                        text: AppStrings.dontHaveAccount,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: AppStrings.signUp,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
