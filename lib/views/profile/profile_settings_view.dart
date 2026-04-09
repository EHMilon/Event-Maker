import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_text_button.dart';
import '../../widgets/user_avatar.dart';
import 'profile_controller.dart';

class ProfileSettingsView extends GetView<ProfileController> {
  const ProfileSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'profileSettings'.tr,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isPersonalInfoLoading.value,
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
                        child: Obx(
                          () => UserAvatar(
                            imageUrl: controller.profileImage.value,
                            localFile: controller.selectedProfileImage.value,
                            radius: 50,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => controller.pickProfileImage(),
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/camera.svg',
                              width: 20.w,
                              height: 20.h,
                              colorFilter: ColorFilter.mode(
                                AppColors.textPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),

                Text(
                  'fullName'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: controller.nameController,
                  hintText: 'fullNamePlaceholder'.tr,
                ),

                SizedBox(height: 20.h),
                Text(
                  'email'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                // Email field is read-only (cannot be changed)
                CustomTextField(
                  controller: controller.emailController,
                  hintText: 'emailPlaceholder'.tr,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                  enabled: false,
                ),
                SizedBox(height: 4.h),
                Text(
                  'emailCannotBeChanged'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                SizedBox(height: 16.h),
                Text(
                  'phoneNumber'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: controller.phoneController,
                  hintText: 'phoneNumber'.tr,
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 20.h),
                Text(
                  'nationality'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: controller.nationalityController,
                  hintText: 'selectNationality'.tr,
                ),

                // Bio field - only shown for service providers
                Obx(() {
                  if (controller.isServiceProvider.value) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Text(
                          'bio'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CustomTextField(
                          controller: controller.bioController,
                          hintText: 'bioPlaceholder'.tr,
                          maxLines: 4,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),

                SizedBox(height: 48.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: PrimaryTextButton(
          onPressed: () => controller.updatePersonalInfo(),
          text: 'update'.tr,
        ),
      ),
    );
  }
}
