import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/views/service_provider_flow/notifications/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceDetailDecisionView extends StatelessWidget {
  final dynamic request;

  const ServiceDetailDecisionView({super.key, this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250.h,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.primary.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.request_quote,
                  size: 80.r,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: 200.h,
                  leading: IconButton(
                    icon: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20.r,
                      ),
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 24.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request?.serviceTitle ?? 'Service Request',
                          style: GoogleFonts.inter(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Customer Info
                        _buildCustomerInfo(request),
                        SizedBox(height: 24.h),

                        // Description
                        Text(
                          'Description',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          request?.serviceDescription ??
                              'Service request description',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Date & Time
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          _formatDate(request?.date ?? DateTime.now()),
                        ),
                        SizedBox(height: 12.h),

                        // Location
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          request?.location ?? 'Location',
                        ),
                        SizedBox(height: 12.h),

                        // Price
                        _buildInfoRow(
                          Icons.payments_outlined,
                          '${request?.price ?? 0} ${request?.priceUnit ?? 'AED'}',
                        ),

                        SizedBox(height: 24.h),

                        // Accept and Reject Buttons
                        _buildDecisionButtons(context, request),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // ignore: unreachable_code
  }

  Widget _buildCustomerInfo(dynamic request) {
    return Row(
      children: [
        Container(
          width: 45.w,
          height: 45.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            image: DecorationImage(
              image: NetworkImage(request?.customerImage ?? ''),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  request?.customerName ?? 'Customer',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              'Customer',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: AppColors.textSecondary),
        SizedBox(width: 12.w),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionButtons(BuildContext context, dynamic request) {
    return Row(
      children: [
        // Reject Button
        Expanded(
          child: Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            child: InkWell(
              onTap: () => _showRejectDialog(context, request),
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.error, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    'Reject',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        // Accept Button
        Expanded(
          child: Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16.r),
            child: InkWell(
              onTap: () => _showAcceptDialog(context, request),
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    'Accept',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(BuildContext context, dynamic request) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close, size: 60.r, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Are you sure you want to reject\nthis service request?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Material(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      onTap: () {
                        // Reject the request
                        if (request?.id != null) {
                          final controller = Get.find<NotificationController>();
                          controller.rejectRequest(request.id);
                        }
                        Navigator.of(dialogContext).pop(); // Close dialog
                        Get.back(); // Go back to notification screen
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            'Reject',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, dynamic request) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 60.r,
              color: const Color(0xFF00C566),
            ),
            SizedBox(height: 16.h),
            Text(
              'Your service request\nhas been accepted',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      onTap: () {
                        // Accept the request
                        if (request?.id != null) {
                          final controller = Get.find<NotificationController>();
                          controller.acceptRequest(request.id);
                        }
                        Navigator.of(dialogContext).pop(); // Close dialog
                        Get.back(); // Go back to notification screen
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            'Done',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  ServiceModel _createServiceModelFromRequest(dynamic request) {
    if (request == null) {
      return ServiceModel(
        id: '',
        title: 'Service Request',
        description: '',
        images: [],
        type: ServiceType.event,
        provider: ServiceProvider(name: 'Customer', role: '', imageUrl: ''),
        location: '',
        basePrice: 0,
        priceUnit: 'AED',
      );
    }

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
      ),
      location: request.location,
      basePrice: request.price,
      priceUnit: request.priceUnit,
      date: request.date,
    );
  }
}
