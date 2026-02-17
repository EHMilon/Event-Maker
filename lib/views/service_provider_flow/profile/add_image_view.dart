import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/themes/app_colors.dart';
import '../../../shared/widgets/primary_text_button.dart';
import 'profile_controller.dart';

class AddImageView extends GetView<ProfileController> {
  const AddImageView({super.key});

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
          'addImage'.tr,
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
                // Image Upload Area
                Container(
                  width: double.infinity,
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.lightGrey,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48.sp,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'upload'.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'JPG, PNG or JPEG',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  'addCaption'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: TextField(
                    controller: controller.captionController,
                    maxLines: 5,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'enterCaption'.tr,
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.4),
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16.sp),
                    ),
                  ),
                ),
                SizedBox(height: 100.h),
                PrimaryTextButton(
                  onPressed: () {
                    // TODO: Implement image picking and upload logic with backend
                    Get.back();
                  },
                  text: 'upload'.tr,
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
