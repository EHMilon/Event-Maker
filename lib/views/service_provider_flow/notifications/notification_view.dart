import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/views/service_provider_flow/notifications/notification_controller.dart';
import 'package:event_maker/views/service_provider_flow/services/service_detail_view.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        titleSpacing: 0,
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
        () => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ListView.builder(
            padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
            itemCount: controller.serviceRequests.length,
            itemBuilder: (context, index) {
              final request = controller.serviceRequests[index];
              return _NotificationCard(
                request: request,
                onTap: () => _handleNotificationClick(request),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleNotificationClick(ServiceRequest request) {
    // Convert ServiceRequest to ServiceModel for ServiceDetailView
    final serviceModel = _convertToServiceModel(request);
    // Navigate to service detail view with accept/reject buttons (same as SP requests screen)
    Get.to(
      () => ServiceDetailView(service: serviceModel, isRequest: true),
    );
  }

  /// Convert ServiceRequest to ServiceModel for ServiceDetailView
  ServiceModel _convertToServiceModel(ServiceRequest request) {
    return ServiceModel(
      id: request.id,
      title: request.serviceTitle,
      description: request.serviceDescription,
      images: [],
      type: ServiceType.event,
      provider: ServiceProvider(
        name: request.customerName,
        role: 'Customer',
        imageUrl: request.customerImage,
        isVerified: false,
      ),
      location: request.location,
      rating: null,
      reviewCount: null,
      date: request.date,
      basePrice: request.price,
      priceUnit: request.priceUnit,
      packages: null,
      isBookmarked: false,
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String name = request.customerName;
    String action = 'sent you a request';

    // Adjust action based on status
    switch (request.status) {
      case RequestStatus.accepted:
        action = 'accepted your';
        break;
      case RequestStatus.rejected:
        action = 'rejected your';
        break;
      case RequestStatus.pending:
        action = 'sent you a';
        break;
    }

    // Capitalize name
    if (name.isNotEmpty) {
      name = name[0].toUpperCase() + name.substring(1);
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
                          '9 hr ago',
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
