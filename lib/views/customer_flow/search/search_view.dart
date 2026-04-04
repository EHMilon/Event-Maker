import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/views/customer_flow/services/service_detail_view.dart';
import 'package:event_maker/widgets/services_card.dart';
import 'package:event_maker/views/customer_flow/search/search_controller.dart'
    as search;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<search.ServiceSearchController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Header
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.1),
                            blurRadius: 10.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18.r,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Search Input
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.lightGrey),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.05),
                            blurRadius: 10.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: AppColors.grey, size: 24.r),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextField(
                              controller: controller.searchController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'searchServices'.tr,
                                hintStyle: GoogleFonts.inter(
                                  color: AppColors.grey,
                                  fontSize: 14.sp,
                                ),
                                border: InputBorder.none,
                                suffixIcon: Obx(
                                  () => controller.searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            size: 20.r,
                                            color: AppColors.grey,
                                          ),
                                          onPressed: () {
                                            controller.clearSearch();
                                          },
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                              onChanged: (value) =>
                                  controller.searchServices(value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Search Results
            Expanded(
              child: Obx(() {
                // Show initial state (empty search)
                if (controller.searchQuery.isEmpty) {
                  return _buildEmptyState();
                }

                // Show no results found
                if (controller.searchResults.isEmpty &&
                    controller.searchQuery.isNotEmpty) {
                  return _buildNoResults();
                }

                // Show search results
                return _buildSearchResults();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/search.svg',
            height: 80.h,
            colorFilter: ColorFilter.mode(
              AppColors.grey.withOpacity(0.5),
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'searchForServices'.tr,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'searchDescription'.tr,
            style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.r, color: AppColors.grey),
          SizedBox(height: 16.h),
          Text(
            'noServicesFound'.tr,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'tryDifferentKeywords'.tr,
            style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final controller = Get.find<search.ServiceSearchController>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'resultsFoundCount'.trParams({
              'count': controller.searchResults.length.toString(),
            }),
            style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.grey),
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: controller.searchResults.length,
            itemBuilder: (context, index) {
              final service = controller.searchResults[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: ServicesCard(
                  imagePath: service.images.isNotEmpty ? service.images[0] : '',
                  title: service.title,
                  location: service.location,
                  price:
                      '${service.basePrice?.toStringAsFixed(0) ?? 'N/A'} ${service.priceUnit}',
                  rating: service.rating?.toString() ?? 'N/A',
                  isBookmarked: service.isBookmarked,
                  useFullWidth: true,
                  onTap: () {
                    Get.to(() => ServiceDetailView(service: service));
                  },
                  onBookmarkTap: () {
                    controller.toggleBookmark(service.id);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
