import 'package:event_maker/core/routes/app_routes.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/views/customer_flow/services/service_detail_view.dart';
import 'package:event_maker/shared/widgets/services_card.dart';
import 'package:event_maker/views/customer_flow/home/home_controller.dart';
import 'package:event_maker/views/customer_flow/home/widgets/category_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

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
                  // Home Screen Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 2.w,
                              ),
                              image: DecorationImage(
                                image: AssetImage('assets/images/person.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Location and greeting section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, Shareena!',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                              // SizedBox(height: 4.h),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/location.svg',
                                    height: 16.h,
                                    width: 16.w,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'New York, USA', // TODO: Fetch from location service
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      // color: AppColors.grey,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Search Icon
                          GestureDetector(
                            onTap: () {
                              try {
                                Get.toNamed(AppRoutes.search);
                              } catch (e) {
                                debugPrint('Navigation error: $e');
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/search.svg',
                                height: 20.h,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Notification Icon
                          GestureDetector(
                            onTap: () =>
                                Get.toNamed(AppRoutes.customerNotifications),
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
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Banner Image
                  Container(
                    width: double.infinity,
                    height: 140.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      image: DecorationImage(
                        image: AssetImage('assets/images/customer_banner.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Select Main Category
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedMainCategory.value,
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.grey,
                        ),
                        items: controller.mainCategories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: GoogleFonts.inter(
                                color: AppColors.black,
                                fontSize: 14.sp,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.selectedMainCategory.value = newValue;
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // Service Categories
                  _buildSectionHeader(
                    'subCategoriesLabel'.tr,
                    'all',
                    'allCategories'.tr,
                    navigateToCategories: true,
                  ),
                  // SizedBox(height: 16.h),
                  _buildCategories(),
                  SizedBox(height: 24.h),
                  // Catering Services
                  _buildSectionHeader(
                    'cateringServices'.tr,
                    'catering',
                    'cateringServices'.tr,
                  ),
                  SizedBox(height: 16.h),
                  _buildHorizontalList('catering'),
                  SizedBox(height: 24.h),
                  // Filming Events
                  _buildSectionHeader(
                    'filmingEvents'.tr,
                    'filming',
                    'filmingEvents'.tr,
                  ),
                  SizedBox(height: 16.h),
                  _buildHorizontalList('filming'),
                  SizedBox(height: 24.h),
                  // Cleaning Services
                  _buildSectionHeader(
                    'cleaningServices'.tr,
                    'cleaning',
                    'cleaningServices'.tr,
                  ),
                  SizedBox(height: 16.h),
                  _buildHorizontalList('cleaning'),
                  SizedBox(height: 80.h), // Extra space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build service categories horizontally based on selected main category
  Widget _buildCategories() {
    final HomeController controller = Get.find<HomeController>();
    return Obx(() {
      final subCategories = controller.currentSubCategories;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: subCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: CategoryItem(label: category, onTap: () {}, index: index),
            );
          }).toList(),
        ),
      );
    });
  }

  /// Build section header with "See All" button
  /// [title] - The section title
  /// [categoryType] - The category type for filtering services
  /// [categoryName] - The display name for the app bar in the next screen
  /// [navigateToCategories] - Whether to navigate to Categories screen or category services
  Widget _buildSectionHeader(
    String title,
    String categoryType,
    String categoryName, {
    bool navigateToCategories = false,
  }) {
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
            if (navigateToCategories) {
              // Navigate to Categories screen
              Get.toNamed(AppRoutes.categories);
            } else {
              // Navigate to CategoryServicesView with the category type and name
              Get.toNamed(
                AppRoutes.categoryServices,
                arguments: {
                  'categoryType': categoryType,
                  'categoryName': categoryName,
                },
              );
            }
          },
          child: Row(
            children: [
              Text(
                'seeAll'.tr,
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
    final HomeController controller = Get.find<HomeController>();

    // Filter services by type from controller's allServices
    final List<ServiceModel> services = controller.allServices.where((service) {
      switch (type) {
        case 'catering':
          return service.type == ServiceType.catering;
        case 'cleaning':
          return service.type == ServiceType.cleaning;
        case 'filming':
          return service.type == ServiceType.filming;
        default:
          return false;
      }
    }).toList();

    // Use filtered services or show placeholder if empty
    if (services.isEmpty) {
      // Return empty container if no services match
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: services.map((service) {
          return Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: ServicesCard(
              imagePath: service.images.isNotEmpty ? service.images[0] : '',
              title: service.title,
              location: service.location,
              price:
                  '${service.basePrice?.toStringAsFixed(0) ?? 'N/A'} ${service.priceUnit}',
              rating: service.rating?.toString() ?? 'N/A',
              isBookmarked: service.isBookmarked,
              onTap: () {
                Get.to(() => ServiceDetailView(service: service));
              },
              onBookmarkTap: () {
                controller.toggleBookmark(service.id);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
