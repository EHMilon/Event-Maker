import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'customer_notification_controller.dart';
import '../../shared/widgets/notification_card.dart';

class CustomerNotificationView extends GetView<CustomerNotificationController> {
  const CustomerNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        titleSpacing: (Navigator.of(context).canPop()) ? 0 : 24.w,
        title: Text(
          'Notification',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isLoading.value,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
              itemCount: controller.isLoading.value
                  ? 6
                  : controller.notifications.length,
              itemBuilder: (context, index) {
                if (controller.isLoading.value) {
                  return const _NotificationCardPlaceholder();
                }
                final notification = controller.notifications[index];
                return _CustomerNotificationCard(
                  notification: notification,
                  onTap: () => controller.handleNotificationClick(notification),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerNotificationCard extends StatelessWidget {
  final CustomerNotificationModel notification;
  final VoidCallback onTap;

  const _CustomerNotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = _formatName(notification.title);
    final action = _formatAction(notification.body);
    final detail = 'booking request'.tr;

    return NotificationCard(
      name: name,
      action: action,
      detail: detail,
      timeAgo: notification.timeAgo,
      onTap: onTap,
    );
  }

  static String _formatName(String rawName) {
    final localized = rawName.tr;
    if (localized.length <= 2) return localized;
    return localized[0].toUpperCase() + localized.substring(1);
  }

  static String _formatAction(String body) {
    switch (body) {
      case 'acceptedBookingBody':
        return 'Accepted your';
      case 'rejectedBookingBody':
        return 'rejected your';
      case 'confirmedBookingBody':
        return 'confirmed your';
      default:
        return body.tr;
    }
  }
}

class _NotificationCardPlaceholder extends StatelessWidget {
  const _NotificationCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            height: 52.h,
            width: 52.h,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14.h,
                  width: double.infinity,
                  color: const Color(0xFFE0E0E0),
                ),
                SizedBox(height: 6.h),
                Container(
                  height: 12.h,
                  width: 120.w,
                  color: const Color(0xFFE0E0E0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
