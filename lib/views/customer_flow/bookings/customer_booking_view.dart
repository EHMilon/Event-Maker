import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/widgets/customer_bookmark_card.dart';
import 'package:event_maker/widgets/empty_widget.dart';
import 'package:event_maker/views/customer_flow/bookings/customer_bookings_controller.dart';
import 'package:event_maker/views/customer_flow/bookings/customer_booking_model.dart';
import 'package:event_maker/views/customer_flow/services/service_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerBookingView extends GetView<CustomerBookingsController> {
  const CustomerBookingView({super.key});

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
            'bookings'.tr,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
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
          children: [_UpcomingRequestsTab(), _HistoryRequestsTab()],
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
class _UpcomingRequestsTab extends GetView<CustomerBookingsController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Obx(() => Skeletonizer(
            enabled: true,
            child: ListView.separated(
              itemCount: controller.skeletonRequests.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final item = controller.skeletonRequests[index];
                return _RequestCard(request: item);
              },
            ),
          ));
        }

        final list = controller.upcomingRequests;
        if (list.isEmpty) {
          return EmptyWidget(
            message: 'noUpcomingRequests'.tr,
            icon: Icons.event_available,
          );
        }
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final item = list[index];
            return _RequestCard(request: item);
          },
        );
      }),
    );
  }
}

/// History requests tab widget
class _HistoryRequestsTab extends GetView<CustomerBookingsController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Obx(() => Skeletonizer(
            enabled: true,
            child: ListView.separated(
              itemCount: controller.skeletonRequests.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                final item = controller.skeletonRequests[index];
                return _RequestCard(request: item);
              },
            ),
          ));
        }

        final list = controller.pastRequests;
        if (list.isEmpty) {
          return EmptyWidget(
            message: 'noHistoryRequests'.tr,
            icon: Icons.event_available,
          );
        }
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final item = list[index];
            return _RequestCard(request: item);
          },
        );
      }),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final CustomerBookingModel request;

  @override
  Widget build(BuildContext context) {
    final service = request.service;
    return GestureDetector(
      onTap: () {
        if (service != null) {
          Get.to(() => ServiceDetailView(service: service));
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: CustomerBookmarkCard(
          imagePath: request.image,
          title: request.title,
          subtitle: request.subtitle,
          location: request.subtitle,
          price: service?.basePrice?.toString() ?? '',
          priceUnit: service?.priceUnit ?? 'AED',
          rating: service?.rating?.toString() ?? '',
          showBookmarkButton: false,
        ),
      ),
    );
  }
}


