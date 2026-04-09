import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_colors.dart';
import 'contact_us_controller.dart';

/// Contact Us view that displays contact information from the API.
class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Find controller
    final controller = Get.find<ContactUsController>();
    
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshContactInfo(),
        child: Obx(() {
          final contact = controller.contactInfo.value;
          final isLoading = controller.isLoading.value;
          
          final phone = contact?.supportPhone ?? '';
          final email = contact?.supportEmail ?? '';
          final instagram = contact?.socialMedia.instagram ?? '';
          final twitter = contact?.socialMedia.twitter ?? '';
          final facebook = contact?.socialMedia.facebook ?? '';
          
          final hasPhone = phone.isNotEmpty;
          final hasEmail = email.isNotEmpty;
          final hasSupport = hasPhone || hasEmail;
          final hasSocial = instagram.isNotEmpty || twitter.isNotEmpty || facebook.isNotEmpty;
          
          return Skeletonizer(
            enabled: isLoading,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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

                  // Empty state
                  if (!isLoading && !hasSupport && !hasSocial)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.contact_support_outlined,
                            size: 64.sp,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No contact information available',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Customer Support Section
                  if (hasSupport) ...[
                    _buildSection(
                      title: 'customerSupport'.tr,
                      children: [
                        if (hasPhone)
                          _buildItem(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: phone,
                            onTap: () => _launchPhone(phone),
                          ),
                        if (hasEmail)
                          _buildItem(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: email,
                            onTap: () => _launchEmail(email),
                          ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // Social Media Section
                  if (hasSocial)
                    _buildSection(
                      title: 'socialMedia'.tr,
                      children: [
                        if (instagram.isNotEmpty)
                          _buildItem(
                            icon: Icons.camera_alt_outlined,
                            label: 'Instagram',
                            value: _extractUsername(instagram),
                            onTap: () => _launchUrl(instagram),
                          ),
                        if (twitter.isNotEmpty)
                          _buildItem(
                            icon: Icons.alternate_email,
                            label: 'Twitter',
                            value: _extractUsername(twitter),
                            onTap: () => _launchUrl(twitter),
                          ),
                        if (facebook.isNotEmpty)
                          _buildItem(
                            icon: Icons.facebook,
                            label: 'Facebook',
                            value: _extractUsername(facebook),
                            onTap: () => _launchUrl(facebook),
                          ),
                      ],
                    ),
                    
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.09),
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18.sp, color: AppColors.black),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
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
                      color: onTap != null ? AppColors.primary : AppColors.black,
                      decoration: onTap != null ? TextDecoration.underline : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _extractUsername(String url) {
    try {
      final parts = url.split('/');
      final last = parts.last;
      return last.isNotEmpty && !last.contains('.') ? '@$last' : url;
    } catch (e) {
      return url;
    }
  }
}
