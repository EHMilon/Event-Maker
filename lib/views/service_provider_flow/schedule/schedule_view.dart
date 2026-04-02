import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/models/schedule_model.dart';
import 'package:event_maker/views/service_provider_flow/schedule/schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'schedule'.tr,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendarHeader(),
          SizedBox(height: 18.h),
          _buildWeekPicker(),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'services'.tr,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(child: _buildScheduleList()),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: () => controller.prevYear(),
            ),
            Obx(
              () => Text(
                controller.currentYear.value,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () => controller.nextYear(),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: () => controller.prevMonth(),
            ),
            Obx(
              () => Text(
                controller.currentMonth.value,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () => controller.nextMonth(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekPicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Obx(() {
        final days = controller.getDaysInWeek();
        return Row(
          children: days.map((date) {
            final isSelected = controller.isSelectedDate(date);
            return GestureDetector(
              onTap: () => controller.selectDate(date),
              child: Container(
                margin: EdgeInsets.only(right: 6.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey200,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(date),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: isSelected ? Colors.white : AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      DateFormat('d').format(date),
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildScheduleList() {
    return Obx(() {
      if (controller.hasError.value) {
        return _buildErrorState();
      }

      return RefreshIndicator(
        onRefresh: controller.refreshSchedules,
        child: Skeletonizer(
          enabled: controller.isLoading.value,
          child: controller.schedules.isEmpty && !controller.isLoading.value
              ? _buildEmptyState()
              : _buildScheduleListView(),
        ),
      );
    });
  }

  Widget _buildScheduleListView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: controller.isLoading.value ? 4 : controller.schedules.length,
      itemBuilder: (context, index) {
        // During loading, show skeleton with placeholder data
        final schedule = controller.isLoading.value
            ? _getSkeletonSchedule(index)
            : controller.schedules[index];
        return _buildServiceCard(schedule, index);
      },
    );
  }

  /// Returns a skeleton schedule for loading state.
  ScheduleModel _getSkeletonSchedule(int index) {
    return ScheduleModel(
      id: 0,
      serviceTitle: 'Service Title Here',
      serviceImage: null,
      startTime: '10:00 AM',
      endTime: '3:00 PM',
      timeRange: '10:00 am - 3:00 pm',
    );
  }

  Widget _buildServiceCard(ScheduleModel schedule, int index) {
    // Get the previous schedule to determine if we need a timeline
    // Only access schedules list when not loading (skeleton mode)
    final ScheduleModel? previousSchedule = !controller.isLoading.value && index > 0
        ? controller.schedules[index - 1]
        : null;
    final bool showTimeline = previousSchedule != null && !_shouldSkipTimeline(previousSchedule, schedule);

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time display - now uses string from API directly
          SizedBox(
            width: 80.w,
            child: Text(
              // Use startTimeString for display (e.g., "10:00 AM")
              schedule.startTime.isNotEmpty 
                  ? schedule.startTime 
                  : schedule.timeRange.split(' - ').first,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.darkGrey,
                height: 2.4.sp,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTimeline) _buildTimeLine(),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: _getCardColor(index).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: _getCardColor(index)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25.r),
                        child: schedule.imageUrl != null
                            ? Image.network(
                                schedule.imageUrl!,
                                width: 48.w,
                                height: 48.w,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderImage(),
                              )
                            : _buildPlaceholderImage(),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.timeRangeString,
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              schedule.title,
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 48.w,
      height: 48.w,
      color: AppColors.grey200,
      child: Icon(Icons.event, size: 24.sp, color: AppColors.grey400),
    );
  }

  Widget _buildTimeLine() {
    return Container(
      height: 40.h,
      margin: EdgeInsets.only(left: 0.w),
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Center(
        child: Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xFFF1F1F5),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64.sp, color: AppColors.grey300),
          SizedBox(height: 16.h),
          Text(
            'noSchedulesFound'.tr,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'noSchedulesForDate'.tr,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.grey400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
          SizedBox(height: 16.h),
          Text(
            'errorLoadingSchedules'.tr,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            controller.errorMessage.value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.grey400,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: controller.retry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'retry'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the card color based on index for visual variety.
  Color _getCardColor(int index) {
    final colors = [
      const Color(0xFFE9D5FF), // Light purple
      const Color(0xFFCCFBF1), // Light teal
      const Color(0xFFDBEAFE), // Light blue
      const Color(0xFFFEE2E2), // Light red
      const Color(0xFFFEF3C7), // Light amber
    ];
    return colors[index % colors.length];
  }

  /// Formats time in 12-hour format.
  /// Kept for backward compatibility but now uses string directly from API.
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Determines if timeline should be skipped between two schedules.
  /// Since we now use string times, we check if both times can be parsed.
  bool _shouldSkipTimeline(ScheduleModel previous, ScheduleModel current) {
    // For string-based times, we compare the time range strings
    // Skip timeline if the time ranges don't overlap or have significant gaps
    // This is a simplified check - in production you'd parse and compare times
    return false; // Show timeline for all schedules for now
  }
}
