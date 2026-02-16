import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/service_provider_flow/services/category_services_controller.dart';
import 'package:event_maker/views/service_provider_flow/services/service_detail_view.dart';
import 'package:event_maker/shared/widgets/services_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// View for displaying all services in a specific category
/// Shows services in a list view with full-width cards
class CategoryServicesView extends GetView<CategoryServicesController> {
  final String categoryType;
  final String categoryName;

  const CategoryServicesView({
    super.key,
    required this.categoryType,
    required this.categoryName,
  });

  @override
  String get tag => '${categoryType}_$categoryName';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          categoryName,
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingSkeleton();
        }

        if (controller.services.isEmpty) {
          return _buildEmptyState();
        }

        return _buildServicesList();
      }),
    );
  }

  /// Build loading skeleton for services
  Widget _buildLoadingSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: 5,
        itemBuilder: (context, index) {
          return ServicesCard(
            imagePath: 'assets/images/catering.jpg',
            title: 'Service Title',
            location: 'Location',
            price: '100 AED',
            rating: '4.5',
            useFullWidth: true,
            onTap: () {},
          );
        },
      ),
    );
  }

  /// Build empty state when no services found
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64.r,
            color: AppColors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'No services found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'There are no services available in this category yet.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build list of services
  Widget _buildServicesList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: controller.services.length,
      itemBuilder: (context, index) {
        final service = controller.services[index];
        final imageUrl = service.images.isNotEmpty ? service.images.first : '';

        return ServicesCard(
          imagePath: imageUrl,
          title: service.title,
          location: service.location,
          price: '${service.basePrice?.toInt() ?? 0} ${service.priceUnit}',
          rating: service.rating?.toString() ?? 'N/A',
          isBookmarked: service.isBookmarked,
          useFullWidth: true,
          onTap: () {
            Get.to(
              () => ServiceDetailView(service: service),
            );
          },
        );
      },
    );
  }
}
