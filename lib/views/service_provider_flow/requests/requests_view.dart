import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/shared/widgets/sp_service_card.dart';
import 'package:event_maker/views/service_provider_flow/requests/requests_controller.dart';
import 'package:event_maker/views/services/service_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RequestsView extends GetView<RequestsController> {
  const RequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Requests',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.requests.isEmpty) {
          return _buildSkeletonList();
        }

        if (controller.requests.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchRequests,
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            itemCount: controller.requests.length,
            itemBuilder: (context, index) {
              final request = controller.requests[index];
              return SpServiceCard(
                imagePath: request.images.first,
                title: request.title,
                dateTime: _formatDateTime(request.date),
                onTap: () {
                  Get.to(
                    () => ServiceDetailView(service: request, isRequest: true),
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        itemCount: 5,
        itemBuilder: (context, index) {
          return SpServiceCard(
            imagePath: 'https://via.placeholder.com/150',
            title: 'Loading request title...',
            dateTime: '10th Jan - Fri - 4:00 PM',
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64.r, color: AppColors.grey),
          SizedBox(height: 16.h),
          Text(
            'No requests yet',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final day = dateTime.day;
    final suffix = _getDaySuffix(day);
    final monthShort = _getMonthShort(dateTime.month);
    final weekdayShort = _getWeekdayShort(dateTime.weekday);
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '$day$suffix $monthShort - $weekdayShort - $hour:$minute $period';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _getMonthShort(int month) {
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

  String _getWeekdayShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
