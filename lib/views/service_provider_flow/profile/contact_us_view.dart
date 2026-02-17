import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/themes/app_colors.dart';
import 'profile_controller.dart';

class ContactUsView extends GetView<ProfileController> {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'contactUs'.tr,
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
                  'contactUsSubtitle'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),

                _buildContactSection(
                  title: 'customerSupport'.tr,
                  items: [
                    _buildContactItem(
                      icon: Icons.phone_outlined,
                      label: 'contactUs'.tr,
                      value: '000-0000-000',
                    ),
                    _buildContactItem(
                      icon: Icons.email_outlined,
                      label: 'email'.tr,
                      value: 'example@gmail.com',
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                _buildContactSection(
                  title: 'socialMedia'.tr,
                  items: [
                    _buildContactItem(
                      icon: Icons.language,
                      label: 'Instagram',
                      value: '@event_maker',
                    ),
                    _buildContactItem(
                      icon: Icons.close, // X icon surrogate
                      label: 'Twitter',
                      value: '@event_maker',
                    ),
                    _buildContactItem(
                      icon: Icons.facebook,
                      label: 'Facebook',
                      value: '@event_maker',
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSection({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...items,
        ],
      ),
    );
  }

  Widget _buildContactItem({
    IconData? icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: icon != null
                ? Icon(icon, size: 18.sp, color: AppColors.primary)
                : Icon(
                    Icons.phone,
                    size: 18.sp,
                    color: AppColors.primary,
                  ), // Fallback
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
