import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/service_provider_flow/notifications/notification_controller.dart';
import 'package:event_maker/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationView extends StatelessWidget {
  NotificationView({super.key}) : controller = Get.find<NotificationController>();

  final NotificationController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Text(
                'Service Requests',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  itemCount: controller.serviceRequests.length,
                  itemBuilder: (context, index) {
                    final request = controller.serviceRequests[index];
                    return _buildServiceRequestCard(request);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Notification',
        style: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.black),
          onPressed: () {
            // TODO: Add options menu
          },
        ),
      ],
    );
  }

  Widget _buildServiceRequestCard(ServiceRequest request) {
    return GestureDetector(
      onTap: () {
        // Navigate to service detail view with accept/reject buttons
        Get.toNamed(
          AppRoutes.serviceDetailWithDecision,
          arguments: {'request': request},
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.lightGrey),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer info row
            Row(
              children: [
                _buildCustomerAvatar(request.customerImage),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.customerName,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'has sent you a request',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  _formatTimeAgo(request.date),
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Service info
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Icon(
                      Icons.request_quote,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.serviceTitle,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${request.price.toInt()} ${request.priceUnit}',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.status),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _getStatusText(request.status),
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerAvatar(String imageUrl) {
    return Container(
      width: 48.w,
      height: 48.w,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.r)),
      child: Image.network(
        imageUrl,
        width: 48.w,
        height: 48.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 48.w,
            height: 48.h,
            decoration: const BoxDecoration(
              color: AppColors.lightGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.grey),
          );
        },
      ),
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return AppColors.primary;
      case RequestStatus.accepted:
        return const Color(0xFF00C566); // Green
      case RequestStatus.rejected:
        return AppColors.error;
    }
  }

  String _getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.rejected:
        return 'Rejected';
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
