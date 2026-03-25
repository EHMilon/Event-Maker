import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// import '../../core/constants/app_strings.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_text_button.dart';
import 'auth_controller.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
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
                      "Register New Account",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Hey! welcome back to app",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              CustomTextField(
                controller: controller.signupNameController,
                labelText: "Full Name",
                hintText: "John Doe",
              ),
              SizedBox(height: 20.h),
              CustomTextField(
                controller: controller.signupEmailController,
                labelText: "email".tr,
                hintText: "emailPlaceholder".tr,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20.h),
              Obx(
                () => CustomTextField(
                  controller: controller.signupPasswordController,
                  labelText: "password".tr,
                  hintText: "passwordPlaceholder".tr,
                  obscureText: controller.obscureSignupPassword.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.obscureSignupPassword.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.grey,
                      size: 20.sp,
                    ),
                    onPressed: controller.toggleSignupPasswordVisibility,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: Checkbox(
                        value: controller.acceptedTerms.value,
                        onChanged: controller.toggleTerms,
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.toggleTerms(
                        !controller.acceptedTerms.value,
                      ),
                      child: RichText(
                        text: TextSpan(
                          text:
                              "By using the Event Maker app you agree to our ",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textPrimary,
                          ),
                          children: [
                            TextSpan(
                              text: "Terms of Use",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy-Notice",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              PrimaryTextButton(
                text: "Create Account",
                onPressed: controller.onSignup,
              ),
              SizedBox(height: 20.h),
              Center(
                child: GestureDetector(
                  onTap: controller.onLoginFromSignup,
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text:"login".tr,
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
    );
  }
}
