import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/views/service_provider_flow/services/add_service_view.dart';
import 'package:event_maker/views/service_provider_flow/services/add_screens_binding.dart';
import 'package:event_maker/views/service_provider_flow/services/service_detail_view.dart';
import 'package:event_maker/views/service_provider_flow/services/sp_services_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Services view for Service Provider to manage their services
/// Shows list of services with ability to add, edit, and view details
class ServicesView extends GetView<SPServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'myServices'.tr,
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchAndAddBar(context),
              SizedBox(height: 20.h),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndAddBar(BuildContext context) {
    return Row(
      children: [
        // Search TextField
        Expanded(
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: TextField(
              controller: controller.searchTextController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'searchServices'.tr,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary.withOpacity(0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.primary,
                  size: 20.r,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Add Button (Icon + Text)
        InkWell(
          onTap: () => Get.to(
            () => const AddServiceView(),
            binding: AddScreensBinding(),
          ),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: AppColors.white, size: 20.r),
                SizedBox(width: 4.w),
                Text(
                  'add'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildShimmerLoading();
      }

      final services = controller.filteredServices;
      if (services.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshServices,
        color: AppColors.primary,
        child: ListView.separated(
          padding: EdgeInsets.only(bottom: 20.h),
          itemCount: services.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final service = services[index];
            return ServiceProviderServiceTile(
              service: service,
              onTap: () => Get.to(
                () => ServiceDetailView(
                  service: service,
                  showEditButton: true, // Show edit button for service provider
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      itemCount: 4,
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return Skeletonizer(
          enabled: true,
          child: Container(
            height: 110.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: ListTile(
              leading: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              title: Container(
                height: 16.h,
                width: 100.w,
                color: AppColors.lightGrey,
              ),
              subtitle: Container(
                height: 12.h,
                width: 150.w,
                color: AppColors.lightGrey,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final isSearching = controller.searchQuery.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.inventory_2_outlined,
            size: 64.r,
            color: AppColors.grey.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            isSearching ? 'noServicesFound'.tr : 'noServicesYet'.tr,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isSearching ? '' : 'tapToAddService'.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceProviderServiceTile extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceProviderServiceTile({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = service.images.isNotEmpty ? service.images.first : '';
    final isNetworkImage = imagePath.startsWith('http');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.lightGrey),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Service image
              Hero(
                tag: 'service_${service.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: imagePath.isNotEmpty
                      ? (isNetworkImage
                            ? Image.network(
                                imagePath,
                                width: 85.w,
                                height: 85.w,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderImage(),
                              )
                            : Image.asset(
                                imagePath,
                                width: 85.w,
                                height: 85.w,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderImage(),
                              ))
                      : _buildPlaceholderImage(),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service title
                    Text(
                      service.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Service type badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getServiceTypeColor(
                          service.type,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        _getServiceTypeLabel(service.type),
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: _getServiceTypeColor(service.type),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Location and Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14.r,
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              service.location,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ).maxWidth,
                          ],
                        ),
                        Text(
                          '${service.basePrice?.toInt() ?? 0} ${service.priceUnit}',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios,
                size: 14.r,
                color: AppColors.grey.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80.w,
      height: 80.w,
      color: AppColors.lightGrey,
      child: Icon(Icons.image_not_supported, color: AppColors.grey, size: 28.r),
    );
  }

  Color _getServiceTypeColor(ServiceType type) {
    switch (type) {
      case ServiceType.event:
        return AppColors.primary;
      case ServiceType.photography:
        return const Color(0xFF9C27B0);
      case ServiceType.training:
        return const Color(0xFF2196F3);
      case ServiceType.catering:
        return const Color(0xFFFF9800);
      case ServiceType.cleaning:
        return const Color(0xFF4CAF50);
      case ServiceType.filming:
        return const Color(0xFF607D8B);
    }
  }

  String _getServiceTypeLabel(ServiceType type) {
    switch (type) {
      case ServiceType.event:
        return 'event'.tr;
      case ServiceType.photography:
        return 'photography'.tr;
      case ServiceType.training:
        return 'training'.tr;
      case ServiceType.catering:
        return 'catering'.tr;
      case ServiceType.cleaning:
        return 'cleaning'.tr;
      case ServiceType.filming:
        return 'filming'.tr;
    }
  }
}

extension on Text {
  Widget get maxWidth => Container(
    constraints: BoxConstraints(maxWidth: 80.w),
    child: this,
  );
}
