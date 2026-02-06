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

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search services...',
                              hintStyle: GoogleFonts.inter(
                                color: AppColors.grey,
                                fontSize: 14.sp,
                              ),
                              border: InputBorder.none,
                              // Clear button when text is entered
                              suffixIcon: controller.searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, size: 20.r, color: AppColors.grey),
                                      onPressed: () {
                                        _searchController.clear();
                                        controller.clearSearch();
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) => controller.searchServices(value),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Search Results or Categories/Services
                  Obx(() {
                    // Show search results if searching
                    if (controller.isSearching) {
                      return _buildSearchResults(controller);
                    }
                    
                    // Show default home content
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Categories
                        _buildSectionHeader('Service Categories', 'all', 'All Categories'),
                        SizedBox(height: 16.h),
                        _buildCategories(),
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
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build search results section
  Widget _buildSearchResults(HomeController controller) {
    if (controller.searchResults.isEmpty && controller.searchQuery.isNotEmpty) {
      // No results found
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 60.h),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 64.r,
                color: AppColors.grey,
              ),
              SizedBox(height: 16.h),
              Text(
                'No services found',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Try different keywords',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show search results as a full-width list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            '${controller.searchResults.length} results found',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.grey,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 80.h),
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            final service = controller.searchResults[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: ServicesCard(
                imagePath: service.images.isNotEmpty ? service.images[0] : '',
                title: service.title,
                location: service.location,
                price: '${service.basePrice?.toStringAsFixed(0) ?? 'N/A'} ${service.priceUnit}',
                rating: service.rating?.toString() ?? 'N/A',
                isBookmarked: service.isBookmarked,
                useFullWidth: true,
                onTap: () {
                  Get.to(
                    () => ServiceDetailView(service: service),
                  );
                },
                onBookmarkTap: () {
                  controller.toggleBookmark(service.id);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build service categories horizontally
  Widget _buildCategories() {
    return SingleChildScrollView(
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
    final HomeController controller = Get.find<HomeController>();
    
    // Filter services by type from controller's allServices
    final List<ServiceModel> services = controller.allServices.where((service) {
      switch (type) {
        case 'photography': return service.type == ServiceType.photography;
        case 'catering': return service.type == ServiceType.catering;
        case 'cleaning': return service.type == ServiceType.cleaning;
        case 'music': return service.type == ServiceType.music;
        case 'filming': return service.type == ServiceType.filming;
        default: return false;
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
              price: '${service.basePrice?.toStringAsFixed(0) ?? 'N/A'} ${service.priceUnit}',
              rating: service.rating?.toString() ?? 'N/A',
              isBookmarked: service.isBookmarked,
              onTap: () {
                Get.to(
                  () => ServiceDetailView(service: service),
                );
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
