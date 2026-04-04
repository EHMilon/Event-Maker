import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/booking_request_model.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/widgets/sp_service_card.dart';
import 'package:event_maker/views/service_provider_flow/requests/requests_controller.dart';
import 'package:event_maker/views/service_provider_flow/services_details/service_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Simple requests view without tabs (uses upcoming requests)
class RequestsView extends GetView<RequestsController> {
  const RequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'requests'.tr,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoadingUpcoming.value &&
            controller.upcomingRequests.isEmpty) {
          return _buildSkeletonList();
        }

        if (controller.upcomingError.isNotEmpty &&
            controller.upcomingRequests.isEmpty) {
          return _buildErrorState(controller.upcomingError.value);
        }

        if (controller.upcomingRequests.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchUpcomingRequests,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            itemCount: controller.upcomingRequests.length,
            itemBuilder: (context, index) {
              final request = controller.upcomingRequests[index];
              return _buildRequestCard(request);
            },
          ),
        );
      }),
    );
  }

  Widget _buildRequestCard(BookingRequestModel request) {
    final imageUrl = request.service.coverImage.isNotEmpty
        ? ApiConstant.getFullMediaUrl(request.service.coverImage)
        : '';

    return SpServiceCard(
      imagePath: imageUrl,
      title: request.title,
      dateTime: request.displayDateTime,
      onTap: () {
        // Convert BookingRequestModel to ServiceModel for ServiceDetailView
        final service = _convertToServiceModel(request);
        Get.to(
          () => ServiceDetailView(
            service: service,
            isRequest: true,
            bookingId: request.id,
          ),
        );
      },
    );
  }

  /// Convert BookingRequestModel to ServiceModel for display
  ServiceModel _convertToServiceModel(BookingRequestModel request) {
    return ServiceModel(
      id: request.service.id,
      title: request.title,
      description: '',
      type: ServiceType.event,
      provider: const ServiceProvider(name: '', role: '', imageUrl: ''),
      images: [request.service.coverImage],
      packages: [],
    );
  }

  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        itemCount: 5,
        itemBuilder: (context, index) {
          return SpServiceCard(
            imagePath: 'https://via.placeholder.com/150',
            title: 'Loading request title...',
            dateTime: '10th Jan - Fri - 4:00 PM',
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.r, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            error,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: controller.fetchUpcomingRequests,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64.r, color: AppColors.grey),
          SizedBox(height: 16.h),
          Text(
            'noUpcomingRequests'.tr,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
