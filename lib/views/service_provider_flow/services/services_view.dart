import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/shared/widgets/add_options_bottom_sheet.dart';
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
      backgroundColor: AppColors.backgroundLight,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddOptionsBottomSheet.show(context),
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, size: 28.r),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 20.h),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'My Services',
          style: GoogleFonts.inter(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Obx(() => Text(
          '${controller.services.length} services',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        )),
      ],
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return ListView.separated(
          itemCount: 4,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            return Skeletonizer(
              enabled: true,
              child: Container(
                height: 100.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            );
          },
        );
      }

      final services = controller.services;
      if (services.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshServices,
        child: ListView.separated(
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64.r,
            color: AppColors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'No services yet',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the + button to add your first service',
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
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Service image - handles both network and asset images
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: imagePath.isNotEmpty
                    ? (isNetworkImage
                        ? Image.network(
                            imagePath,
                            width: 80.w,
                            height: 80.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          )
                        : Image.asset(
                            imagePath,
                            width: 80.w,
                            height: 80.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholderImage(),
                          ))
                    : _buildPlaceholderImage(),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service title
                    Text(
                      service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Service type badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _getServiceTypeColor(service.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        _getServiceTypeLabel(service.type),
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: _getServiceTypeColor(service.type),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.r,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            service.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    // Price
                    Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 14.r,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${service.basePrice?.toInt() ?? 0} ${service.priceUnit}',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow indicator
              Icon(
                Icons.arrow_forward_ios,
                size: 16.r,
                color: AppColors.grey,
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
      child: Icon(
        Icons.image_not_supported,
        color: AppColors.grey,
        size: 28.r,
      ),
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
      case ServiceType.music:
        return const Color(0xFFE91E63);
      case ServiceType.filming:
        return const Color(0xFF607D8B);
    }
  }

  String _getServiceTypeLabel(ServiceType type) {
    switch (type) {
      case ServiceType.event:
        return 'Event';
      case ServiceType.photography:
        return 'Photography';
      case ServiceType.training:
        return 'Training';
      case ServiceType.catering:
        return 'Catering';
      case ServiceType.cleaning:
        return 'Cleaning';
      case ServiceType.music:
        return 'Music';
      case ServiceType.filming:
        return 'Filming';
    }
  }
}
