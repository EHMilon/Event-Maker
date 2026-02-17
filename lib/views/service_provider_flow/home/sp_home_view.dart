import 'package:event_maker/core/routes/app_routes.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/shared/widgets/add_options_bottom_sheet.dart';
import 'package:event_maker/views/service_provider_flow/home/sp_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:google_fonts/google_fonts.dart';

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
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.wb_sunny_outlined,
                  size: 16,
                  color: Colors.orange,
                ),
                SizedBox(width: 8.w),
                Text(
                  'goodMorning'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(
                  'Fresh Food L.L.C',
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ],
            ),
          ],
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
                  height: 22.h,
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

  Widget _buildAnalyticsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.95,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildStatCard(
                  icon: Icons.currency_exchange,
                  iconColor: const Color(0xFF3B82F6),
                  label: 'totalEarnings'.tr,
                  value: controller.stats.value.totalEarnings,
                  change: controller.stats.value.earningsChange,
                  isUp: controller.stats.value.isEarningsUp,
                );
              } else if (index == 1) {
                return _buildStatCard(
                  icon: Icons.inventory_2_outlined,
                  iconColor: const Color(0xFFA855F7),
                  label: 'totalRequests'.tr,
                  value: '${controller.stats.value.totalRequests}',
                  change: controller.stats.value.requestsChange,
                  isUp: controller.stats.value.isRequestsUp,
                );
              } else if (index == 2) {
                return _buildStatCard(
                  icon: Icons.check_circle_outline,
                  iconColor: const Color(0xFF10B981),
                  label: 'completed'.tr,
                  value: '${controller.stats.value.completedOrders}',
                  change: controller.stats.value.completedChange,
                  isUp: controller.stats.value.isCompletedUp,
                );
              } else {
                return _buildStatCard(
                  icon: Icons.schedule_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  label: 'pending'.tr,
                  value: '${controller.stats.value.pendingOrders}',
                  change: controller.stats.value.pendingChange,
                  isUp: controller.stats.value.isPendingUp,
                );
              }
            },
          ),
          SizedBox(height: 24.h),
          _buildTotalBalanceCard(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String change,
    required bool isUp,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF1F1F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 14),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: label,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
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
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFF1F1F5)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F5),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: SvgPicture.asset(
                'assets/icons/wallet.svg',
                height: 20.h,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'totalBalance'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  _buildBalanceText(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceText() {
    return Text(
      controller.stats.value.totalBalance,
      style: GoogleFonts.inter(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          Icons.add_circle,
          'addService'.tr,
          const Color(0xFF22C55E),
          onTap: () => AddOptionsBottomSheet.show(context),
        ),
        _buildActionItem(
          Icons.calendar_today,
          'schedule'.tr,
          const Color(0xFF3B82F6),
          onTap: () => Get.toNamed(AppRoutes.spSchedule),
        ),
        _buildActionItem(
          Icons.account_balance_wallet,
          'earnings'.tr,
          const Color(0xFFF59E0B),
          onTap: () => Get.toNamed(AppRoutes.spWallet),
        ),
        _buildActionItem(
          Icons.description,
          'documents'.tr,
          const Color(0xFF14B8A6),
          onTap: () => Get.toNamed(AppRoutes.spDocuments),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String label,
    Color color, {
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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
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
          child: _buildOrderCard(index),
        ),
      ),
    );
  }

  Widget _buildOrderCard(int index) {
    if (controller.isLoading.value) {
      return _buildSkeletonCard();
    }

    final order = controller.activeOrders[index];

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network(
              order.imageUrl,
              width: 64.w,
              height: 64.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 64.w,
                height: 64.h,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              order.title,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          if (order.badgeCount > 0)
            Container(
              height: 24.h,
              width: 24.h,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFB485FF),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${order.badgeCount}',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
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
