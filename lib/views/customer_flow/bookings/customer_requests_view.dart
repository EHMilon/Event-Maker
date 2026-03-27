import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/widgets/customer_bookmark_card.dart';
import 'package:event_maker/views/customer_flow/bookings/customer_bookings_controller.dart';
import 'package:event_maker/views/customer_flow/bookings/customer_requests_model.dart';
import 'package:event_maker/views/customer_flow/services/service_detail_view.dart';
import 'package:event_maker/models/service_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerRequestsView extends GetView<CustomerBookingsController> {
  const CustomerRequestsView({super.key});

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
          return Skeletonizer(
            enabled: true,
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                return _RequestCard(
                  request: CustomerBookingModel(
                    image: 'assets/images/catering.jpg',
                    date: '10th Jan - Fri - 4:00 PM',
                    title: 'Skeleton Title Loading...',
                    subtitle: 'Loading Location...',
                  ),
                );
              },
            ),
          );
        }

        final list = controller.upcomingRequests;
        if (list.isEmpty) {
          return const _EmptyState(message: 'noUpcomingRequests');
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
          return Skeletonizer(
            enabled: true,
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (context, index) => SizedBox(height: 8.h),
              itemBuilder: (context, index) {
                return _RequestCard(
                  request: CustomerBookingModel(
                    image: 'assets/images/catering.jpg',
                    date: '10th Jan - Fri - 4:00 PM',
                    title: 'Skeleton Title Loading...',
                    subtitle: 'Loading Location...',
                  ),
                );
              },
            ),
          );
        }

        final list = controller.pastRequests;
        if (list.isEmpty) {
          return const _EmptyState(message: 'noHistoryRequests');
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
    return GestureDetector(
      onTap: () {
        // Navigate to service details with mock service data
        Get.to(
          () => ServiceDetailView(
            service: ServiceModel(
              id: 'mock_id_${request.title}',
              title: request.title,
              description:
                  'This is a detailed description for ${request.title}. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
              images: [request.image],
              type: ServiceType.event,
              provider: ServiceProvider(
                name: 'Professional Provider',
                role: 'Event Specialist',
                imageUrl: 'https://i.pravatar.cc/150?u=provider',
                isVerified: true,
              ),
              location: request.subtitle,
              rating: 4.8,
              reviewCount: 124,
              basePrice: 500,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: CustomerBookmarkCard(
          imagePath: request.image,
          title: request.title,
          subtitle: request.subtitle,
          location: request.subtitle,
          price: '500',
          priceUnit: 'AED',
          rating: '4.8',
          showBookmarkButton: false,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 48.r, color: AppColors.grey),
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
