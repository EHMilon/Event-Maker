import 'package:event_maker/app_routes.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/views/customer_flow/services/service_detail_view.dart';
import 'package:event_maker/widgets/services_card.dart';
import 'package:event_maker/views/customer_flow/home/customer_home_controller.dart';
import 'package:event_maker/views/customer_flow/home/widgets/category_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomerHomeView extends StatefulWidget {
  const CustomerHomeView({super.key});

  @override
  State<CustomerHomeView> createState() => _CustomerHomeViewState();
}

class _CustomerHomeViewState extends State<CustomerHomeView> {
  final ServiceRepository _serviceRepository = const ServiceRepository();

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Obx(
          () => Skeletonizer(
            enabled: controller.isLoading.value && controller.allServices.isEmpty,
            child: RefreshIndicator(
              onRefresh: controller.refreshHomeData,
              color: Get.theme.colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                  // Home Screen Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            // Avatar - uses API endpoint: GET /settings/personal-info/me -> avatar field
                            _buildAvatar(controller.userAvatar),
                            SizedBox(width: 12.w),
                            // Location and greeting section
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi, ${controller.userName}!',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
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
                                      Flexible(
                                        child: Text(
                                          controller.userLocation,
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                            controller.setMainCategory(newValue);
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
                  _buildCategories(),
                  SizedBox(height: 24.h),
                  ...controller.displayServiceGroups.expand(
                    (group) => [
                      _buildSectionHeader(
                        group.serviceAsName,
                        controller.selectedMainCategory.value,
                        group.serviceAsName,
                      ),
                      SizedBox(height: 16.h),
                      _buildServiceGroupList(group),
                      SizedBox(height: 24.h),
                    ],
                  ),
                  SizedBox(height: 80.h),
                ],
              ),
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
      final selectedSubCategory = controller.selectedSubCategory.value;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: subCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isSelected = selectedSubCategory == category;

            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: CategoryItem(
                label: category,
                isSelected: isSelected,
                onTap: () {
                  controller.selectSubCategory(category);
                },
                index: index,
              ),
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
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
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

  /// Build avatar widget using API data from /settings/personal-info/me
  /// Uses NetworkImage for remote URLs when avatar is available
  Widget _buildAvatar(String avatarUrl) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2.w,
        ),
        color: AppColors.lightGrey,
      ),
      child: ClipOval(
        child: avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Show initials fallback if image fails to load
                  return const Center(
                    child: Icon(
                      Icons.person,
                      color: AppColors.grey,
                      size: 20,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              )
            : const Center(
                child: Icon(
                  Icons.person,
                  color: AppColors.grey,
                  size: 20,
                ),
              ),
      ),
    );
  }

  /// Build horizontal list for service group from backend API
  Widget _buildServiceGroupList(ServiceGroup group) {
    final HomeController controller = Get.find<HomeController>();
    final List<ServiceModel> services = group.services;

    // Use services or show placeholder if empty
    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: services.map((service) {
          return Padding(
            padding: EdgeInsets.only(right: 6.w),
            child: ServicesCard(
              imagePath: service.coverImage,
              title: service.title,
              location: service.location,
              price:
                  '${service.basePrice?.toStringAsFixed(0) ?? 'N/A'} ${service.currency}',
              rating: service.ratingValue.toStringAsFixed(1),
              isBookmarked: service.isBookmarked,
              onTap: () async {
                // Show loading indicator while fetching service detail
                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );

                try {
                  // Fetch full service details from API
                  final detailService = await _serviceRepository
                      .fetchCustomerServiceDetail(service.apiId);
                  Get.back(); // Close loading dialog
                  Get.to(() => ServiceDetailView(service: detailService));
                } catch (e) {
                  Get.back(); // Close loading dialog
                  // If API fails, use the current service data
                  Get.to(() => ServiceDetailView(service: service));
                }
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
