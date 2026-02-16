import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/themes/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_text_button.dart';
import '../../../core/routes/app_routes.dart';
import 'profile_controller.dart';

class ProfileSettingsView extends GetView<ProfileController> {
  const ProfileSettingsView({super.key});

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
          'Profile Settings',
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
                // Profile Picture with Edit Icon
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2.w,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50.r,
                          backgroundImage: AssetImage(
                            controller.profileImage.value,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.addImage),
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 20.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: controller.nameController,
                  hintText: 'Full Name',
                ),

                SizedBox(height: 20.h),
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: controller.emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 20.h),
                Text(
                  'Phone',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: controller.phoneController,
                  hintText: 'Phone',
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 20.h),
                Text(
                  'Nationality',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: controller.nationalityController,
                  hintText: 'Nationality',
                ),

                SizedBox(height: 48.h),
                PrimaryTextButton(
                  onPressed: () => controller.updateProfile(),
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
