import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/themes/app_colors.dart';
import 'notification_controller.dart';

class CustomerNotificationView extends GetView<CustomerNotificationController> {
  const CustomerNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'notifications'.tr,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: controller.clearAllNotifications,
            child: Text(
              'clearAll'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              'today'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Obx(
                () => Skeletonizer(
                  enabled: controller.isLoading.value,
                  child: ListView.builder(
                    itemCount: controller.isLoading.value
                        ? 5
                        : controller.notifications.length,
                    itemBuilder: (context, index) {
                      if (controller.isLoading.value) {
                        return NotificationCard(
                          notification: CustomerNotificationModel(
                            id: '',
                            title: 'Skeleton Title',
                            body: 'Skeleton body for loading state',
                            timeAgo: '2 hr ago',
                            type: NotificationType.booking,
                          ),
                          onTap: () {},
                        );
                      }
                      final notification = controller.notifications[index];
                      return NotificationCard(
                        notification: notification,
                        onTap: () =>
                            controller.handleNotificationClick(notification),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final CustomerNotificationModel notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: notification.isRead
              ? AppColors.borderLight
              : AppColors.primary.withOpacity(0.2),
          width: notification.isRead ? 1 : 2,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        leading: Container(
          height: 48.h,
          width: 48.h,
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(child: _getNotificationIcon(notification.type)),
        ),
        title: Text(
          notification.title.tr,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            notification.body.tr,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              notification.timeAgo,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            if (!notification.isRead)
              Container(
                height: 8.h,
                width: 8.h,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return AppColors.primary.withOpacity(0.1);
      case NotificationType.reminder:
        return const Color(0xFFFEF3F2).withOpacity(0.5);
      case NotificationType.payment:
        return const Color(0xFFF0FDF4).withOpacity(0.5);
      case NotificationType.promotion:
        return const Color(0xFFEFF6FF).withOpacity(0.5);
    }
  }

  Widget _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return Icon(Icons.check_circle, color: AppColors.primary, size: 20.h);
      case NotificationType.reminder:
        return Icon(Icons.alarm, color: const Color(0xFFFB7171), size: 20.h);
      case NotificationType.payment:
        return Icon(Icons.payment, color: const Color(0xFF10B981), size: 20.h);
      case NotificationType.promotion:
        return Icon(Icons.discount, color: const Color(0xFF3B82F6), size: 20.h);
    }
  }
}
