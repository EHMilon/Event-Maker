import 'package:event_maker/app_routes.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/views/service_provider_flow/home/sp_home_controller.dart';
import 'package:event_maker/views/service_provider_flow/add_service/add_service_view.dart';
import 'package:event_maker/views/service_provider_flow/add_service/add_screens_binding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/widgets/order_card.dart';
import 'package:event_maker/views/service_provider_flow/active_orders/active_orders_details_view.dart';

class SPHomeView extends GetView<SPHomeController> {
  const SPHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      body: SafeArea(
        child: Obx(() {
          if (controller.hasError.value) {
            return _buildErrorView();
          }
          return Skeletonizer(
            enabled: controller.isLoading.value,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 20.h),
                  _buildPromoImage(),
                  SizedBox(height: 25.h),
                  _buildAnalyticsSection(),
                  SizedBox(height: 30.h),
                  _buildQuickActions(context),
                  SizedBox(height: 30.h),
                  _buildActiveOrdersHeader(),
                  SizedBox(height: 15.h),
                  _buildActiveOrdersList(),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'somethingWentWrong'.tr,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => controller.retry(),
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  // Returns the appropriate greeting key and icon based on current time
  ({String greetingKey, IconData icon, Color iconColor}) _getGreetingData() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      // Morning: 5 AM - 11:59 AM
      return (
        greetingKey: 'goodMorning',
        icon: Icons.wb_sunny_outlined,
        iconColor: Colors.orange,
      );
    } else if (hour >= 12 && hour < 17) {
      // Afternoon: 12 PM - 4:59 PM
      return (
        greetingKey: 'goodAfternoon',
        icon: Icons.wb_sunny,
        iconColor: Colors.orange.shade700,
      );
    } else {
      // Evening: 5 PM - 4:59 AM
      return (
        greetingKey: 'goodEvening',
        icon: Icons.nights_stay_outlined,
        iconColor: Colors.indigo,
      );
    }
  }

  Widget _buildHeader() {
    final greetingData = _getGreetingData();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    greetingData.icon,
                    size: 19,
                    color: greetingData.iconColor,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    greetingData.greetingKey.tr,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      controller.businessName.value.isEmpty 
                        ? (controller.userName.value.isEmpty 
                            ? 'Good morning' 
                            : controller.userName.value)
                        : controller.businessName.value,
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: const EdgeInsets.all(2),

                    child: Image.asset(
                      'assets/icons/completed.png',
                      height: 24.h,
                      width: 24.w,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Get.toNamed(AppRoutes.serviceProviderNotifications),
          borderRadius: BorderRadius.circular(50.r),
          child: Container(
            height: 44.h,
            width: 44.h,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEFFF),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/notification.svg',
                  height: 20.h,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    height: 4.h,
                    width: 4.h,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Image.asset(
        'assets/images/promo.png',
        width: double.infinity,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        // color: const Color.fromARGB(38, 24, 35, 190),
        color: Colors.white,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'analytics'.tr,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'basedOnLast30Days'.tr,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 24.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 16.w;
              final itemWidth = (constraints.maxWidth - spacing) / 2;
              return Wrap(
                spacing: spacing,
                runSpacing: 16.h,
                children: List.generate(4, (index) {
                  Widget child;
                  if (index == 0) {
                    child = _buildStatCard(
                      icon: 'assets/icons/doller.svg',
                      backgroundColor: const Color(0xFFE2EDFF),
                      label: 'totalEarnings'.tr,
                      value: controller.stats.value.totalEarnings,
                      change: controller.stats.value.earningsChange,
                      isUp: controller.stats.value.isEarningsUp,
                    );
                  } else if (index == 1) {
                    child = _buildStatCard(
                      icon: 'assets/icons/fl_box.svg',
                      backgroundColor: const Color(0xFFF5E8FF),
                      label: 'totalRequests'.tr,
                      value: '${controller.stats.value.totalRequests}',
                      change: controller.stats.value.requestsChange,
                      isUp: controller.stats.value.isRequestsUp,
                    );
                  } else if (index == 2) {
                    child = _buildStatCard(
                      icon: 'assets/icons/completed_outline.svg',
                      backgroundColor: const Color(0xFFD9FFF2),
                      label: 'completed'.tr,
                      value: '${controller.stats.value.completedOrders}',
                      change: controller.stats.value.completedChange,
                      isUp: controller.stats.value.isCompletedUp,
                    );
                  } else {
                    child = _buildStatCard(
                      icon: 'assets/icons/time.svg',
                      backgroundColor: const Color(0xFFFFEFD3),
                      label: 'pending'.tr,
                      value: '${controller.stats.value.pendingOrders}',
                      change: controller.stats.value.pendingChange,
                      isUp: controller.stats.value.isPendingUp,
                    );
                  }

                  return SizedBox(width: itemWidth, child: child);
                }),
              );
            },
          ),
          SizedBox(height: 24.h),
          _buildTotalBalanceCard(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required Color backgroundColor,
    required String label,
    required String value,
    required String change,
    required bool isUp,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                // padding: EdgeInsets.all(8.w),
                // decoration: BoxDecoration(
                //   color: Colors.white.withOpacity(0.7),
                //   shape: BoxShape.circle,
                // ),
                child: SvgPicture.asset(icon, height: 20.h, width: 20.w),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: label,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          Row(
            children: [
              Icon(
                isUp ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: '$change ',
                        style: TextStyle(
                          color: isUp
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: 'fromLastMonth'.tr),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.spWallet),
      child: Container(
        width: double.infinity, // Ensures the card stretches across the screen
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white, // Match background if needed
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligns all children to the left
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/wallet.svg',
                  height: 20.h, // Slightly larger icon to match the image scale
                  colorFilter: const ColorFilter.mode(
                    AppColors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'totalBalance'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp, // Increased size for better hierarchy
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h), // Spacing between header and amount
            Text(
              controller.stats.value.totalBalance, // Use dynamic balance from controller
              style: GoogleFonts.inter(
                fontSize: 26.sp, // Large, bold balance text
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          icon: 'assets/icons/add.svg',
          label: 'addService'.tr,
          backgroundColor: const Color(0xFFE9FBF4),
          onTap: () => Get.to(
            () => const AddServiceView(),
            binding: AddScreensBinding(),
          ),
        ),
        _buildActionItem(
          icon: 'assets/icons/calender.svg',
          label: 'schedule'.tr,
          backgroundColor: const Color(0xFFF0FBFE),
          onTap: () => Get.toNamed(AppRoutes.spSchedule),
        ),
        _buildActionItem(
          icon: 'assets/icons/earning.svg',
          label: 'earnings'.tr,
          backgroundColor: const Color(0xFFEFF1FF),
          onTap: () => Get.toNamed(AppRoutes.spWallet),
        ),
        _buildActionItem(
          icon: 'assets/icons/document.svg',
          label: 'documents'.tr,
          backgroundColor: const Color(0xFFE9FBF4),
          onTap: () => Get.toNamed(AppRoutes.spDocuments),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required String icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 64.h,
            width: 64.h,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(icon, height: 28.h, width: 28.w),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'activeOrders'.tr,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.spActiveOrders),
          child: Row(
            children: [
              Text(
                'seeAll'.tr,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 4.w),
              const Icon(
                Icons.arrow_forward_ios,
                size: 10,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveOrdersList() {
    if (controller.activeOrders.isEmpty && !controller.isLoading.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Text(
            'noActiveOrdersFound'.tr,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        controller.isLoading.value ? 4 : controller.activeOrders.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: controller.isLoading.value
              ? _buildSkeletonCard()
              : OrderCard(
                  title: controller.activeOrders[index].title,
                  imageUrl: controller.activeOrders[index].imageUrl,
                  badgeCount: controller.activeOrders[index].badgeCount,
                  titleColor: AppColors.grey500,
                  onTap: () => Get.to(
                    () => SPServiceOrdersView(
                      serviceTitle: controller.activeOrders[index].title,
                      orderCount: controller.activeOrders[index].badgeCount,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
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
}
