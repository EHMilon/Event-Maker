import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../widgets/app_custom_dialog.dart';
import '../../../widgets/language_bottom_sheet.dart';
import '../../../widgets/user_avatar.dart';
import '../../../constants/app_colors.dart';
import '../../../app_routes.dart';
import '../../profile/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 24.w,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'settings'.tr,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          child: UserAvatar(
                            imageUrl: controller.profileImage.value,
                            localFile: controller.selectedProfileImage.value,
                            radius: 50,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          controller.userName.value,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2.h,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                // Menu Items
                _buildMenuItem(
                  icon: 'assets/icons/profile_outline.svg',
                  title: 'profileSettings'.tr,
                  onTap: () => Get.toNamed(AppRoutes.profileSettings),
                ),
                _buildMenuItem(
                  icon: 'assets/icons/security.svg',
                  title: 'security'.tr,
                  onTap: () => Get.toNamed(AppRoutes.changePassword),
                ),
                if (controller.isServiceProvider.value) ...[
                  _buildMenuItem(
                    icon: 'assets/icons/scroll-text.svg',
                    title: 'certifications'.tr,
                    onTap: () => Get.toNamed(AppRoutes.spCertifications),
                  ),
                  _buildMenuItem(
                    icon: 'assets/icons/calendar-check-2.svg',
                    title: 'myAvailability'.tr,
                    onTap: () {},
                    trailing: Switch(
                      value: controller.isAvailable.value,
                      onChanged: (value) =>
                          controller.toggleAvailability(value),
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  _buildMenuItem(
                    icon: 'assets/icons/wallet.svg',
                    title: 'myWallet'.tr,
                    onTap: () => Get.toNamed(AppRoutes.spWallet),
                    trailing: Text(
                      '${controller.walletBalance.value} AED',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ] else ...[
                  _buildMenuItem(
                    icon: 'assets/icons/wallet.svg',
                    title: 'myTransactions'.tr,
                    onTap: () => Get.toNamed(AppRoutes.transactions),
                  ),
                  _buildMenuItem(
                    icon: 'assets/icons/saved.svg',
                    title: 'myBookmarks'.tr,
                    onTap: () => Get.toNamed(AppRoutes.bookmarks),
                  ),
                ],
                _buildMenuItem(
                  icon: 'assets/icons/languages.svg',
                  title: 'language'.tr,
                  onTap: () => _showLanguageBottomSheet(context),
                ),
                _buildMenuItem(
                  icon: 'assets/icons/mail.svg',
                  title: 'contactUs'.tr,
                  onTap: () => Get.toNamed(AppRoutes.contactUs),
                ),
                _buildMenuItem(
                  icon: 'assets/icons/question-mark.svg',
                  title: 'faq'.tr,
                  onTap: () => Get.toNamed(AppRoutes.faq),
                ),
                _buildMenuItem(
                  icon: 'assets/icons/trash.svg',
                  title: 'deleteAccount'.tr,
                  titleColor: AppColors.error,
                  onTap: () => _showDeleteAccountDialog(context),
                ),
                _buildMenuItem(
                  icon: 'assets/icons/logout.svg',
                  title: 'logout'.tr,
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
    Widget? trailing,
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
      // trailing: trailing ?? Icon(Icons.chevron_right, size: 20.sp, color: AppColors.textSecondary),
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 0.h),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AppCustomDialog(
        iconPath: 'assets/icons/logout.svg',
        iconColor: AppColors.error,
        iconHeight: 80.h,
        title: 'logout'.tr.isEmpty ? 'Log Out' : 'logout'.tr,
        subTitle: 'logoutConfirmation'.tr.isEmpty
            ? 'Are you sure you want to log out?'
            : 'logoutConfirmation'.tr,
        mainButtonText: 'logout'.tr.isEmpty ? 'Log Out' : 'logout'.tr,
        mainButtonColor: AppColors.error,
        mainButtonCallback: () => controller.logOut(),
        secondaryButtonText: 'cancel'.tr.isEmpty ? 'Cancel' : 'cancel'.tr,
        secondaryButtonCallback: () => Get.back(),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    Get.bottomSheet(
      LanguageBottomSheet(
        selectedLanguage: controller.selectedLanguage.value,
        onLanguageSelected: (language) => controller.changeLanguage(language),
      ),
      isScrollControlled: true,
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    Get.dialog(
      AppCustomDialog(
        iconPath: 'assets/icons/security.svg',
        iconColor: AppColors.error,
        iconHeight: 80.h,
        title: 'accountDeletionTitle'.tr,
        subTitle: 'accountDeletionSubtitle'.tr,
        mainButtonText: 'deleteAccount'.tr,
        mainButtonColor: AppColors.error,
        mainButtonCallback: () {
          Get.back();
          controller.deleteAccount();
        },
        secondaryButtonText: 'cancel'.tr,
        secondaryButtonCallback: () => Get.back(),
      ),
    );
  }
}
