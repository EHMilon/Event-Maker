import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../constants/app_colors.dart';
import '../../widgets/primary_text_button.dart';
import 'auth_controller.dart';

class SignupStepTwoView extends GetView<AuthController> {
  const SignupStepTwoView({super.key});

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
                    Center(
                      child: Text(
                        "Personal Information",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        "Almost there! add your phone number & nationality.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                "Nationality",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: controller.selectedNationality.value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  items:
                      [
                            'Emirati',
                            'American',
                            'British',
                            'Indian',
                            'Bangladeshi',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: controller.updateNationality,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Phone",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(
                () => IntlPhoneField(
                  key: ValueKey(controller.selectedCountryCode.value),
                  style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.grey.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  initialCountryCode: controller.selectedCountryCode.value,
                  onChanged: (phone) {
                    controller.updatePhoneNumber(phone.completeNumber);
                  },
                ),
              ),
              SizedBox(height: 100.h), // Space for button

            ],
          ),
        ),
        
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(
                  () => PrimaryTextButton(
                    text: "Continue",
                    onPressed: controller.onContinueSignup,
                    isLoading: controller.isLoading.value,
                  ),
                ),
      ),
    );
  }
}
