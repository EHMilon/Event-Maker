import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'notification_controller.dart';

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
          style: GoogleFonts.inter(
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
                  return NotificationCard(
                    notification: CustomerNotificationModel(
                      id: '',
                      title: 'Clara Tolson',
                      body: 'Accepted your booking request',
                      timeAgo: '9 hr ago',
                      type: NotificationType.booking,
                    ),
                    onTap: () {},
                  );
                }
                final notification = controller.notifications[index];
                return NotificationCard(
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
    // Helper to format body text based on type if needed, but here we follow the image logic
    String name = notification.title.tr;
    String action = notification.body.tr;

    // Adjusting for the specific design in the image
    if (notification.body == 'acceptedBookingBody') {
      action = 'Accepted your';
    } else if (notification.body == 'rejectedBookingBody') {
      action = 'rejected your';
    } else if (notification.body == 'confirmedBookingBody') {
      action = 'confirmed your';
    }

    // Capitalize name if it's a mock category for better demo
    if (name.length > 2) {
      name = name[0].toUpperCase() + name.substring(1);
    }

    // If it's the specific mock data from controller, we might want to make it look like the image name
    if (name.toLowerCase() == 'photography' ||
        name.toLowerCase() == 'catering') {
      name = 'Clara Tolson';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFF0F0F0), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Logo with Black Background
            Container(
              height: 52.h,
              width: 52.h,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Image.asset(
                    'assets/images/food_fresho_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$name ',
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: action,
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF8A8A8A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Text(
                          notification.timeAgo,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8A8A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'booking request',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8A8A8A),
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
}
