import 'package:event_maker/core/routes/app_routes.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/views/services/service_detail_view.dart';
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
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.notifications),
                        child: Container(
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
                  _buildSectionHeader('Service Categories', 'all', 'All Categories'),
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
                  _buildSectionHeader('Catering Services', 'catering', 'Catering Services'),
                  SizedBox(height: 16.h),
                  _buildHorizontalList('catering'),
                  SizedBox(height: 24.h),
                  // Filming Events
                  _buildSectionHeader('Filming Events', 'filming', 'Filming Events'),
                  SizedBox(height: 16.h),
                  _buildHorizontalList('filming'),
                  SizedBox(height: 24.h),
                  // Cleaning Services
                  _buildSectionHeader('Cleaning Services', 'cleaning', 'Cleaning Services'),
                  SizedBox(height: 16.h),
                  _buildHorizontalList('cleaning'),
                  SizedBox(height: 24.h),
                  // Music Events
                  _buildSectionHeader('Music Events', 'music', 'Music Events'),
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

  /// Build section header with "See All" button
  /// [title] - The section title
  /// [categoryType] - The category type for filtering services
  /// [categoryName] - The display name for the app bar in the next screen
  Widget _buildSectionHeader(String title, String categoryType, String categoryName) {
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
          onPressed: () {
            // Navigate to CategoryServicesView with the category type and name
            Get.toNamed(
              AppRoutes.categoryServices,
              arguments: {
                'categoryType': categoryType,
                'categoryName': categoryName,
              },
            );
          },
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
        children: List.generate(3, (index) {
          final imageUrl = imageUrls[type] ?? '';
          final title = '${type.capitalizeFirst} Service ${index + 1}';

          ServiceType serviceType = ServiceType.event;
          switch (type) {
            case 'photography':
              serviceType = ServiceType.photography;
              break;
            case 'catering':
              serviceType = ServiceType.catering;
              break;
            case 'cleaning':
              serviceType = ServiceType.cleaning;
              break;
            case 'music':
              serviceType = ServiceType.music;
              break;
            case 'filming':
              serviceType = ServiceType.filming;
              break;
          }

          return ServicesCard(
            imagePath: imageUrl,
            title: title,
            location: 'AD, Louver Museum',
            price: '120 AED',
            rating: '4.5',
            onTap: () {
              Get.to(
                () => ServiceDetailView(
                  service: ServiceModel(
                    id: '$type-$index',
                    title: title,
                    description:
                        'This is a premium $type service offering the best quality experiences for your events. We ensure professional handling and top-tier equipment/ingredients to make your special day memorable.',
                    images: [imageUrl],
                    type: serviceType,
                    provider: ServiceProvider(
                      name: 'Premium $type Provider',
                      role: 'Professional',
                      imageUrl:
                          'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=1000&auto=format&fit=crop',
                      isVerified: true,
                    ),
                    location: 'AD, Louver Museum',
                    rating: 4.5,
                    reviewCount: 50 + index * 10,
                    basePrice: 120,
                    priceUnit: 'AED',
                    date: DateTime.now().add(Duration(days: index + 1)),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
