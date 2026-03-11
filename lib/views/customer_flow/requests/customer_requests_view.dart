import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/customer_flow/requests/customer_requests_controller.dart';
import 'package:event_maker/views/customer_flow/requests/customer_requests_model.dart';
import 'package:event_maker/views/customer_flow/services/service_detail_view.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerRequestsView extends GetView<CustomerRequestsController> {
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
            style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500),
            tabs: [
              Tab(text: 'upcoming'.tr),
              Tab(text: 'history'.tr),
            ],
          ),
        ),
        body: TabBarView(children: [_UpcomingRequestsTab(), _HistoryRequestsTab()]),
      ),
    );
  }
}

/// Upcoming requests tab widget
class _UpcomingRequestsTab extends GetView<CustomerRequestsController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Skeletonizer(
            enabled: true,
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return _RequestCard(
                  request: CustomerRequestModel(
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
        return ListView.builder(
          itemCount: list.length,
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
class _HistoryRequestsTab extends GetView<CustomerRequestsController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Skeletonizer(
            enabled: true,
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return _RequestCard(
                  request: CustomerRequestModel(
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
        return ListView.builder(
          itemCount: list.length,
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

  final CustomerRequestModel request;

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
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.lightGrey),
          boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Image.asset(request.image, width: 80.w, height: 80.h, fit: BoxFit.cover),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.date,
                      style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      request.title,
                      style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      request.subtitle,
                      style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
            style: GoogleFonts.inter(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
