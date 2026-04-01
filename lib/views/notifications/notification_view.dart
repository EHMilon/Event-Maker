import 'package:event_maker/models/service_model.dart';
import 'package:event_maker/views/service_provider_flow/services_details/service_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widgets/notification_card.dart';
import 'notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

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
        () => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ListView.builder(
            padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
            itemCount: controller.serviceRequests.length,
            itemBuilder: (context, index) {
              final request = controller.serviceRequests[index];
              return NotificationCard(
                name: _formatName(request.customerName),
                action: _formatAction(request.status),
                detail: 'booking request'.tr,
                timeAgo: request.createdAt,
                onTap: () => _handleNotificationClick(request),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleNotificationClick(ServiceRequest request) {
    // Navigate with booking ID to fetch real data from API
    final bookingId = int.tryParse(request.id);
    if (bookingId != null) {
      Get.to(() => ServiceDetailView(
        service: _convertToServiceModel(request),
        isRequest: true,
        bookingId: bookingId,
      ));
    } else {
      Get.to(() => ServiceDetailView(service: _convertToServiceModel(request), isRequest: true));
    }
  }

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
          packages: [],
      isBookmarked: false,
    );
  }

  static String _formatName(String rawName) {
    if (rawName.isEmpty) return rawName;
    return rawName[0].toUpperCase() + rawName.substring(1);
  }

  static String _formatAction(RequestStatus status) {
    switch (status) {
      case RequestStatus.accepted:
        return 'accepted your';
      case RequestStatus.rejected:
        return 'rejected your';
      case RequestStatus.pending:
      default:
        return 'sent you a request';
    }
  }
}
