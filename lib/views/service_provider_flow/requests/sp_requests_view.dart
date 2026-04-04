import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/booking_request_model.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/widgets/request_card.dart';
import 'package:event_maker/views/service_provider_flow/requests/requests_controller.dart';
import 'package:event_maker/views/service_provider_flow/services_details/service_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SPRequestsView extends GetView<RequestsController> {
  const SPRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          titleSpacing: 24.w,
          title: Text(
            'requests'.tr,
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(40.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  dividerColor: Colors.transparent,
                  indicator: const BoxDecoration(),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  indicatorPadding: EdgeInsets.zero,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.only(right: 8.w),
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  onTap: (index) => controller.selectedTabIndex.value = index,
                  tabs: [
                    _buildTab('upcoming'.tr, 0),
                    _buildTab('pastEvents'.tr, 1),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [_UpcomingRequestsTab(), _PastRequestsTab()],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    return Obx(() {
      final isSelected = controller.selectedTabIndex.value == index;
      return Container(
        height: 32.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.lightGrey.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(text),
      );
    });
  }
}

/// Upcoming requests tab widget
class _UpcomingRequestsTab extends GetView<RequestsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingUpcoming.value &&
          controller.upcomingRequests.isEmpty) {
        return _buildSkeleton();
      }

      if (controller.upcomingError.isNotEmpty &&
          controller.upcomingRequests.isEmpty) {
        return _buildErrorState(controller.upcomingError.value);
      }

      if (controller.upcomingRequests.isEmpty) {
        return _buildEmptyState('upcoming');
      }

      return RefreshIndicator(
        onRefresh: controller.fetchUpcomingRequests,
        color: AppColors.primary,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          itemCount: controller.upcomingRequests.length,
          separatorBuilder: (_, __) => SizedBox(height: 16.h),
          itemBuilder: (_, index) {
            final request = controller.upcomingRequests[index];
            return _buildRequestCard(request);
          },
        ),
      );
    });
  }

  Widget _buildRequestCard(BookingRequestModel request) {
    final imageUrl = request.service.coverImage.isNotEmpty
        ? ApiConstant.getFullMediaUrl(request.service.coverImage)
        : '';

    return RequestCard(
      image: imageUrl,
      date: request.displayDateTime,
      title: request.title,
      subtitle: request.servicesDuration,
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

  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (_, __) => Container(
          height: 90.h,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              Container(width: 80.w, height: 80.h, color: AppColors.grey),
              SizedBox(width: 12.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100.w, height: 10.h, color: AppColors.grey),
                  SizedBox(height: 8.h),
                  Container(width: 150.w, height: 14.h, color: AppColors.grey),
                ],
              ),
            ],
          ),
        ),
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

  Widget _buildEmptyState(String type) {
    final message = type == 'upcoming'
        ? 'noUpcomingRequests'
        : 'noPastRequests';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64.r, color: AppColors.grey),
          SizedBox(height: 12.h),
          Text(
            message.tr,
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

/// Past requests tab widget
class _PastRequestsTab extends GetView<RequestsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPast.value && controller.pastRequests.isEmpty) {
        return _buildSkeleton();
      }

      if (controller.pastError.isNotEmpty && controller.pastRequests.isEmpty) {
        return _buildErrorState(controller.pastError.value);
      }

      if (controller.pastRequests.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.fetchPastRequests,
        color: AppColors.primary,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          itemCount: controller.pastRequests.length,
          separatorBuilder: (_, __) => SizedBox(height: 16.h),
          itemBuilder: (_, index) {
            final request = controller.pastRequests[index];
            return _buildRequestCard(request);
          },
        ),
      );
    });
  }

  Widget _buildRequestCard(BookingRequestModel request) {
    final imageUrl = request.service.coverImage.isNotEmpty
        ? ApiConstant.getFullMediaUrl(request.service.coverImage)
        : '';

    return RequestCard(
      image: imageUrl,
      date: request.displayDateTime,
      title: request.title,
      subtitle: request.servicesDuration,
      onTap: () {
        // Convert BookingRequestModel to ServiceModel for ServiceDetailView
        final service = _convertToServiceModel(request);
        Get.to(
          () => ServiceDetailView(
            service: service,
            isRequest: true,
            bookingId: request.id,
            isPastRequest: true,
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

  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (_, __) => Container(
          height: 90.h,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              Container(width: 80.w, height: 80.h, color: AppColors.grey),
              SizedBox(width: 12.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100.w, height: 10.h, color: AppColors.grey),
                  SizedBox(height: 8.h),
                  Container(width: 150.w, height: 14.h, color: AppColors.grey),
                ],
              ),
            ],
          ),
        ),
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
            onPressed: controller.fetchPastRequests,
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
          Icon(Icons.history, size: 64.r, color: AppColors.grey),
          SizedBox(height: 12.h),
          Text(
            'noPastRequests'.tr,
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
