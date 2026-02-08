import 'package:event_maker/core/routes/app_routes.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/profile/profile_controller.dart';
import 'package:event_maker/shared/widgets/services_card.dart';
import 'package:event_maker/shared/widgets/review_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceProviderProfileView extends GetView<ProfileController> {
  const ServiceProviderProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,

          title: Text(
            'My Profile',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
              onSelected: (value) {
                if (value == 'settings') {
                  Get.toNamed(AppRoutes.profile);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'settings', child: Text('Settings')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 16.h),
            // Profile Image
            Center(
              child: Container(
                padding: EdgeInsets.all(3.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2.w),
                ),
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundImage: const AssetImage('assets/images/person.jpg'),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Name
            Text(
              'Fresh Food L.L.C',
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20.r),
                SizedBox(width: 4.w),
                Text(
                  '4.9',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '(3,657)',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Tab Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Center(
                child: TabBar(
                  isScrollable: true,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  tabs: const [
                    Tab(text: 'ABOUT'),
                    Tab(text: 'REVIEWS'),
                  ],
                ),
              ),
            ),
            // Tab Bar View
            Expanded(
              child: TabBarView(
                children: [_buildAboutTab(), _buildReviewsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Certifications
          _buildSectionTitle('Certifications'),
          SizedBox(height: 16.h),
          _buildCertificationItem(
            'Professional Chef',
            'July, 2025',
            'Sonargaon Cooking School',
          ),
          SizedBox(height: 16.h),
          _buildCertificationItem(
            'Pizza Artisan',
            'August, 2025',
            'Lorenzo\'s Pizza',
          ),
          SizedBox(height: 32.h),

          // Bio
          _buildSectionTitle('Bio'),
          SizedBox(height: 12.h),
          Text(
            'Amazing service! The team made our wedding day stress-free and truly magical. Everything was perfectly organized from the décor to the timeline. Highly recommend them.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 32.h),

          // Services
          _buildSectionTitle('Services'),
          SizedBox(height: 16.h),
          SizedBox(
            height: 250.h,
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.providerServices.length,
                itemBuilder: (context, index) {
                  final service = controller.providerServices[index];
                  return ServicesCard(
                    imagePath: service.images.first,
                    title: service.title,
                    location: service.location,
                    price: service.basePrice?.toString() ?? '0',
                    rating: service.rating?.toString() ?? '0',
                    isBookmarked: service.isBookmarked,
                    onTap: () {},
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Obx(
      () => ListView.builder(
        padding: EdgeInsets.all(24.w),
        itemCount: controller.providerReviews.length,
        itemBuilder: (context, index) {
          final review = controller.providerReviews[index];
          return ReviewCard(review: review, useFullWidth: true);
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildCertificationItem(String title, String date, String school) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          date,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          school,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
