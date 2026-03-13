import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/service_model.dart';
import 'package:event_maker/shared/widgets/request_card.dart';
import 'package:event_maker/views/service_provider_flow/add_service/add_service_view.dart';
import 'package:event_maker/views/service_provider_flow/add_service/add_screens_binding.dart';
import 'package:event_maker/views/service_provider_flow/services_details/service_detail_view.dart';
import 'package:event_maker/views/service_provider_flow/services/sp_services_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Services view for Service Provider to manage their services
/// Shows list of services with ability to add, edit, and view details
class ServicesView extends GetView<SPServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        titleSpacing: 24.w,
        title: Text(
          'myServices'.tr,
          style: GoogleFonts.inter(fontSize: 24.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchAndAddBar(context),
              SizedBox(height: 20.h),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndAddBar(BuildContext context) {
    return Row(
      children: [
        // Search TextField
        Expanded(
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: TextField(
              controller: controller.searchTextController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'searchServices'.tr,
                hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textSecondary.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20.r),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Add Button (Icon + Text)
        InkWell(
          onTap: () => Get.to(() => const AddServiceView(), binding: AddScreensBinding()),
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: AppColors.white, size: 20.r),
                SizedBox(width: 4.w),
                Text(
                  'add'.tr,
                  style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildShimmerLoading();
      }

      final services = controller.filteredServices;
      if (services.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshServices,
        color: AppColors.primary,
        child: ListView.separated(
          padding: EdgeInsets.only(bottom: 20.h),
          itemCount: services.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final service = services[index];
            return RequestCard(
              image: service.images.isNotEmpty ? service.images.first : '',
              date: _formatDateTime(service.date),
              title: service.title,
              subtitle: service.location,
              onTap: () => Get.to(
                () => ServiceDetailView(
                  service: service,
                  showEditButton: true, // Show edit button for service provider
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildShimmerLoading() {
    return ListView.separated(
      itemCount: 4,
      padding: EdgeInsets.zero,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return Skeletonizer(
          enabled: true,
          child: Container(
            height: 110.h,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20.r)),
            child: ListTile(
              leading: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(14.r)),
              ),
              title: Container(height: 16.h, width: 100.w, color: AppColors.lightGrey),
              subtitle: Container(height: 12.h, width: 150.w, color: AppColors.lightGrey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final isSearching = controller.searchQuery.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isSearching ? Icons.search_off : Icons.inventory_2_outlined, size: 64.r, color: AppColors.grey.withOpacity(0.5)),
          SizedBox(height: 16.h),
          Text(
            isSearching ? 'noServicesFound'.tr : 'noServicesYet'.tr,
            style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8.h),
          Text(
            isSearching ? '' : 'tapToAddService'.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Formats DateTime to display format (e.g., "15th Mar - Mon - 2:30 PM")
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final day = dateTime.day;
    final suffix = _getDaySuffix(day);
    final month = _getMonthShort(dateTime.month);
    final weekday = _getWeekdayShort(dateTime.weekday);
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$day$suffix $month - $weekday - $hour:$minute $period';
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _getWeekdayShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
