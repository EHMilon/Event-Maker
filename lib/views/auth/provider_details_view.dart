import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/themes/app_colors.dart';
import '../../shared/widgets/primary_text_button.dart';
import 'auth_controller.dart';

class ProviderDetailsView extends GetView<AuthController> {
  const ProviderDetailsView({super.key});

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
                      "Get Started",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        "Welcome! Let’s set up your service provider account. Tell us what you do!",
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
              _dropdownLabel("What type of service do you offer?"),
              SizedBox(height: 8.h),
              Obx(
                () => _buildDropdown(
                  value: controller.selectedServiceType.value.isEmpty
                      ? null
                      : controller.selectedServiceType.value,
                  hint: "Select",
                  items: ['Hospitality', 'Event Maker', 'Professional Trainer'],
                  onChanged: controller.updateServiceType,
                ),
              ),
              SizedBox(height: 20.h),
              _dropdownLabel("What’s your role?"),
              SizedBox(height: 8.h),
              Obx(
                () => _buildDropdown(
                  value: controller.selectedRole.value.isEmpty
                      ? null
                      : controller.selectedRole.value,
                  hint: "Select",
                  items: ['Freelancer', 'Business', 'Productive Family'],
                  onChanged: controller.updateRole,
                ),
              ),
              SizedBox(height: 20.h),
              _dropdownLabel("Service Category"),
              SizedBox(height: 8.h),
              Obx(
                () => _buildDropdown(
                  value: controller.selectedServiceCategory.value.isEmpty
                      ? null
                      : controller.selectedServiceCategory.value,
                  hint: "Select",
                  items: ['Cleaning', 'Catering', 'Lighting', 'Music'],
                  onChanged: controller.updateServiceCategory,
                ),
              ),
              SizedBox(height: 60.h),
              PrimaryTextButton(
                text: "Continue",
                onPressed: controller.onContinueProviderDetails,
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdownLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(
        hint,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.grey.withOpacity(0.5),
        ),
      ),
      style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
