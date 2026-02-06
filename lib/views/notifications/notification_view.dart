import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/notifications/notification_controller.dart';
import 'package:event_maker/views/services/services_controller.dart';
import 'package:event_maker/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Obx(
          () => ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return _buildNotificationCard(notification);
            },
          ),
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
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return GestureDetector(
      onTap: () async {
        if (notification.body.toLowerCase().contains('accepted')) {
          // Get service data for payment
          final servicesController = Get.find<ServicesController>();

          // Wait for services to load if they haven't yet
          if (servicesController.services.isEmpty) {
            await servicesController.loadServices();
          }

          // Check again after loading
          if (servicesController.services.isNotEmpty) {
            final mockService = servicesController.services.first;
            Get.toNamed(
              AppRoutes.payment,
              arguments: {
                'service': mockService,
                'package': mockService.packages?.first,
              },
            );
          } else {
            // Fallback: Show error if services still not loaded
            Get.snackbar(
              'Error',
              'Unable to load service data. Please try again.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.body,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              notification.timeAgo,
              style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      width: 48.w,
      height: 48.w,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.black,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          'assets/images/food_fresho_logo.png',
          width: 48.w,
          height: 48.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
  });
}
