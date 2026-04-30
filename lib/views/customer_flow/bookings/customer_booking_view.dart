import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/constants/api_constant.dart';
import 'package:event_maker/services/service_repository.dart';
import 'package:event_maker/widgets/customer_bookmark_card.dart';
import 'package:event_maker/widgets/empty_widget.dart';
import 'package:event_maker/views/customer_flow/bookings/customer_bookings_controller.dart';
import 'package:event_maker/models/customer_booking_model.dart';
import 'package:event_maker/views/customer_flow/services/service_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:google_fonts/google_fonts.dart';

class _TabListener extends StatefulWidget {
  final Widget child;
  final CustomerBookingsController controller;

  const _TabListener({required this.child, required this.controller});

  @override
  State<_TabListener> createState() => _TabListenerState();
}

class _TabListenerState extends State<_TabListener> {
  int _previousIndex = 0;
  TabController? _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = DefaultTabController.of(context);
    if (_tabController != controller) {
      _tabController?.removeListener(_onTabChanged);
      _tabController = controller;
      _previousIndex = _tabController!.index;
      _tabController!.addListener(_onTabChanged);
    }
  }

  void _onTabChanged() {
    if (_tabController != null && _tabController!.index != _previousIndex) {
      _previousIndex = _tabController!.index;
      widget.controller.selectedTabIndex.value = _tabController!.index;
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class CustomerBookingView extends GetView<CustomerBookingsController> {
  const CustomerBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: _TabListener(
        controller: controller,
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            titleSpacing: 24.w,
            title: Text(
              'bookings'.tr,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
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
                      _buildTab('requested'.tr, 1),
                      _buildTab('history'.tr, 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _UpcomingRequestsTab(),
              _RequestedRequestsTab(),
              _HistoryRequestsTab(),
            ],
          ),
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
    return RefreshIndicator(
      onRefresh: () => controller.refreshBookings(),
      color: AppColors.primary,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Skeletonizer(
              enabled: true,
              child: ListView.separated(
                itemCount: controller.skeletonRequests.length,
                separatorBuilder: (context, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final item = controller.skeletonRequests[index];
                  return _RequestCard(request: item);
                },
              ),
            );
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
      ),
    );
  }
}

/// Requested requests tab widget
class _RequestedRequestsTab extends GetView<CustomerBookingsController> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshBookings(),
      color: AppColors.primary,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Skeletonizer(
              enabled: true,
              child: ListView.separated(
                itemCount: controller.skeletonRequests.length,
                separatorBuilder: (context, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final item = controller.skeletonRequests[index];
                  return _RequestCard(request: item);
                },
              ),
            );
          }

          final list = controller.requestedRequests;
          if (list.isEmpty) {
            return EmptyWidget(
              message: 'No requested bookings',
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
      ),
    );
  }
}

/// History requests tab widget
class _HistoryRequestsTab extends GetView<CustomerBookingsController> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshBookings(),
      color: AppColors.primary,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Skeletonizer(
              enabled: true,
              child: ListView.separated(
                itemCount: controller.skeletonRequests.length,
                separatorBuilder: (context, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final item = controller.skeletonRequests[index];
                  return _RequestCard(request: item);
                },
              ),
            );
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
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final CustomerBookingItem request;

  /// Navigate to service detail
  Future<void> _navigateToServiceDetail(BuildContext context) async {
    final serviceId = request.service.id;
    if (serviceId <= 0) return;

    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Fetch service detail from API
      final repository = ServiceRepository();
      final service = await repository.fetchCustomerServiceDetail(serviceId);

      // Close loading dialog
      Get.back();

      // Navigate to service detail view with booking info
      // User already booked this service, so hide Book Now button
      if (context.mounted) {
        Get.to(
          () => ServiceDetailView(
            service: service,
            isAlreadyBooked: true, // Hide Book Now button
            bookedPackage: request.selectedPackage, // Pre-selected package
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Get.back();

      // Show error snackbar
      Get.snackbar(
        'Error',
        'Failed to load service details',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build image URL from cover image path
    final imageUrl = request.service.coverImage.isNotEmpty
        ? ApiConstant.getFullMediaUrl(request.service.coverImage)
        : 'assets/images/catering.jpg';

    return GestureDetector(
      onTap: () => _navigateToServiceDetail(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: CustomerBookmarkCard(
          imagePath: imageUrl,
          title: request.title,
          subtitle: request.displayDateTime,
          location: request.location,
          price: request.totalAmount,
          priceUnit: request.currency,
          rating: '',
          showBookmarkButton: false,
        ),
      ),
    );
  }
}
