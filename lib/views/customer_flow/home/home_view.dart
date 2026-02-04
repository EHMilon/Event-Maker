import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/shared/widgets/services_card.dart';
import 'package:event_maker/views/customer_flow/home/home_controller.dart';
import 'package:event_maker/views/customer_flow/home/widgets/category_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Obx(
          () => Skeletonizer(
            enabled: controller.isLoading.value,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  // Location Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16.r,
                                color: AppColors.grey,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Location',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'New York, USA',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/notification.svg',
                          height: 20.h,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  // Search Bar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: AppColors.grey, size: 24.r),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: GoogleFonts.inter(
                                color: AppColors.grey,
                                fontSize: 14.sp,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Service Categories
                  _buildSectionHeader('Service Categories', () {}),
                  SizedBox(height: 16.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CategoryItem(
                          icon: 'assets/icons/event.png',
                          label: 'Event',
                          onTap: () {},
                        ),
                        SizedBox(width: 20.w),
                        CategoryItem(
                          icon: 'assets/icons/musical.png',
                          label: 'Musical',
                          onTap: () {},
                        ),
                        SizedBox(width: 20.w),
                        CategoryItem(
                          icon: 'assets/icons/filming.png',
                          label: 'Filming',
                          onTap: () {},
                        ),
                        SizedBox(width: 20.w),
                        CategoryItem(
                          icon: 'assets/icons/photography.png',
                          label: 'Photography',
                          onTap: () {},
                        ),
                        SizedBox(width: 20.w),
                        CategoryItem(
                          icon: 'assets/icons/catering.png',
                          label: 'Catering',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Catering Services
                  _buildSectionHeader('Catering Services', () {}),
                  SizedBox(height: 16.h),
                  _buildHorizontalList('catering'),
                  SizedBox(height: 24.h),
                  // Filming Events
                  _buildSectionHeader('Filming Events', () {}),
                  SizedBox(height: 16.h),
                  _buildHorizontalList('filming'),
                  SizedBox(height: 24.h),
                  // Cleaning Services
                  _buildSectionHeader('Cleaning Services', () {}),
                  SizedBox(height: 16.h),
                  _buildHorizontalList('cleaning'),
                  SizedBox(height: 24.h),
                  // Music Events
                  _buildSectionHeader('Music Events', () {}),
                  SizedBox(height: 16.h),
                  _buildHorizontalList('music'),
                  SizedBox(height: 80.h), // Extra space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Row(
            children: [
              Text(
                'See All',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColors.grey,
                ),
              ),
              Icon(Icons.chevron_right, size: 16.r, color: AppColors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalList(String type) {
    // Mock URLs for different types
    final Map<String, String> imageUrls = {
      'catering': 'assets/images/catering.jpg',
      'filming': 'assets/images/filming.jpg',
      'cleaning': 'assets/images/cleaning.jpg',
      'music': 'assets/images/music.jpg',
      'photography': 'assets/images/photography.jpg',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          3,
          (index) => ServicesCard(
            imagePath: imageUrls[type] ?? '',
            title: 'Rose garden wedding',
            location: 'AD, Louver Museum',
            price: '120 AED',
            rating: '4.5',
          ),
        ),
      ),
    );
  }
}
