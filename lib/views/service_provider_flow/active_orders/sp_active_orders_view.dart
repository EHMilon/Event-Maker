import 'package:event_maker/models/provider_home_model.dart';
import 'package:event_maker/views/service_provider_flow/active_orders/active_orders_details_view.dart';
import 'package:event_maker/views/service_provider_flow/home/sp_home_controller.dart';
import 'package:event_maker/widgets/order_card.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Active Orders View for Service Provider
///
/// Displays all active orders grouped by service.
/// Navigates to booking details when a service card is tapped.
class SPActiveOrdersView extends GetView<SPHomeController> {
  const SPActiveOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFE),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          'activeOrders'.tr,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingView();
          }

          final orderGroups = controller.allActiveOrderGroups;

          if (orderGroups.isEmpty) {
            return _buildEmptyView();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                children: List.generate(
                  orderGroups.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: OrderCard(
                      title: orderGroups[index].serviceTitle,
                      imageUrl: orderGroups[index].serviceImage,
                      badgeCount: orderGroups[index].totalBookings,
                      onTap: () => _onOrderTap(orderGroups[index]),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Builds loading skeleton view
  Widget _buildLoadingView() {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          children: List.generate(
            4,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildSkeletonCard(),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds empty state view
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'noActiveOrdersFound'.tr,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds skeleton card for loading state
  Widget _buildSkeletonCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(height: 14.h, color: Colors.grey[300]),
          ),
          SizedBox(width: 16.w),
          Container(
            height: 24.h,
            width: 24.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  /// Handles order card tap
  /// Navigates to service orders detail view with real booking data
  void _onOrderTap(ServiceOrderGroup group) {
    Get.to(
      () => SPServiceOrdersView(
        serviceTitle: group.serviceTitle,
        orderCount: group.totalBookings,
        bookings: group.bookings,
      ),
    );
  }
}
