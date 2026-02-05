import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/themes/app_colors.dart';
import '../../core/routes/app_routes.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isLoading.value,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                // Profile Picture 
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
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
                        SizedBox(height: 12.h),
                        Text(
                          controller.userName.value,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                // Menu Items
                _buildMenuItem(
                  icon: 'assets/icons/profile_outline.svg',
                  title: 'My Profile',
                  onTap: () => Get.toNamed(AppRoutes.profileSettings),
                ),
                _buildMenuItem(
                  icon: 'assets/icons/security.svg',
                  title: 'Security',
                  onTap: () => Get.toNamed(AppRoutes.changePassword),
                ),
                _buildMenuItem(
                  icon: 'assets/icons/wallet.svg',
                  title: 'My Transactions',
                  onTap: () => Get.toNamed(AppRoutes.transactions),
                ),
                _buildMenuItem(
                  icon: 'assets/icons/saved.svg',
                  title: 'My Bookmarks',
                  onTap: () => Get.toNamed(AppRoutes.bookmarks),
                ),
                _buildMenuItem(
                  icon: 'assets/icons/mail.svg',
                  title: 'Contact Us',
                  onTap: () => Get.toNamed(AppRoutes.contactUs),
                ),
                _buildMenuItem(
                  icon: 'assets/icons/question-mark.svg',
                  title: 'FAQ',
                  onTap: () => Get.toNamed(AppRoutes.faq),
                ),
                SizedBox(height: 16.h),
                _buildMenuItem(
                  icon: 'assets/icons/logout.svg',
                  title: 'Log Out',
                  titleColor: AppColors.error,
                  onTap: () => _showLogoutDialog(context),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: SvgPicture.asset(
        icon,
        width: 24.w,
        height: 24.h,
        colorFilter: titleColor != null
            ? ColorFilter.mode(titleColor, BlendMode.srcIn)
            : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => controller.logOut(),
            child: const Text(
              'Log Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
