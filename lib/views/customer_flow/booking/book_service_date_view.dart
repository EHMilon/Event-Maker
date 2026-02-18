import 'package:event_maker/views/customer_flow/booking/booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/shared/widgets/primary_text_button.dart';
import 'package:event_maker/core/routes/app_routes.dart';

class BookServiceDateView extends StatelessWidget {
  const BookServiceDateView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'bookService'.tr,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'selectDateTime'.tr,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),

            // Month / Year Selector (Interactive)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month Selector
                GestureDetector(
                  onTap: () => _showMonthPicker(context, controller),
                  child: Row(
                    children: [
                      Obx(
                        () => Text(
                          controller.selectedMonth.value,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                // Year Selector
                GestureDetector(
                  onTap: () => _showYearPicker(context, controller),
                  child: Row(
                    children: [
                      Obx(
                        () => Text(
                          controller.selectedYear.value,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            SizedBox(
              height: 80.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  return Obx(() {
                    final isSelected =
                        controller.selectedDateIndex.value == index;
                    final day = 15 + index;
                    final weekDays = [
                      'mon'.tr,
                      'tue'.tr,
                      'wed'.tr,
                      'thu'.tr,
                      'fri'.tr,
                      'sat'.tr,
                      'sun'.tr,
                    ];
                    return GestureDetector(
                      onTap: () => controller.setSelectedDate(index),
                      child: Container(
                        width: 60.w,
                        margin: EdgeInsets.only(right: 12.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.lightGrey,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              weekDays[index % 7],
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '$day',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            SizedBox(height: 24.h),

            Text(
              'availableTimes'.tr,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),

            // Time Slots Grid
            Obx(
              () => Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: List.generate(controller.times.length, (index) {
                  final isSelected =
                      controller.selectedTimeIndex.value == index;
                  return GestureDetector(
                    onTap: () => controller.setSelectedTime(index),
                    child: Container(
                      width: (Get.width - 72.w) / 3, // 3 columns
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.lightGrey,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        controller.times[index],
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 24.h),

            Text(
              'serviceDuration'.tr,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => _showDurationPicker(context, controller),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppColors.textSecondary,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Obx(
                          () => Text(
                            controller.selectedDuration.value,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            Text(
              'location'.tr,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => _showLocationPicker(context, controller),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.textSecondary,
                          size: 20.r,
                        ),
                        SizedBox(width: 8.w),
                        Obx(
                          () => Text(
                            controller.selectedLocation.value,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40.h),

            PrimaryTextButton(
              onPressed: () {
                Get.toNamed(
                  AppRoutes.bookServiceRequest,
                  arguments: Get.arguments,
                );
              },
              text: 'continueText'.tr,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // Picker methods
  void _showMonthPicker(BuildContext context, BookingController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'selectMonth'.tr,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  itemCount: controller.months.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final isSelected =
                          controller.months[index] ==
                          controller.selectedMonth.value;
                      return ListTile(
                        title: Text(
                          controller.months[index],
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          controller.setSelectedMonth(controller.months[index]);
                          Get.back();
                        },
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showYearPicker(BuildContext context, BookingController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'selectYear'.tr,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  itemCount: controller.years.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final isSelected =
                          controller.years[index] ==
                          controller.selectedYear.value;
                      return ListTile(
                        title: Text(
                          controller.years[index],
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          controller.setSelectedYear(controller.years[index]);
                          Get.back();
                        },
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDurationPicker(BuildContext context, BookingController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'selectDuration'.tr,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  itemCount: controller.durations.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final isSelected =
                          controller.durations[index] ==
                          controller.selectedDuration.value;
                      return ListTile(
                        leading: Icon(
                          Icons.access_time,
                          color: AppColors.textSecondary,
                        ),
                        title: Text(
                          controller.durations[index],
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          controller.setSelectedDuration(
                            controller.durations[index],
                          );
                          Get.back();
                        },
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationPicker(BuildContext context, BookingController controller) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'selectLocationTitle'.tr,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  itemCount: controller.locations.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final isSelected =
                          controller.locations[index] ==
                          controller.selectedLocation.value;
                      return ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: AppColors.textSecondary,
                        ),
                        title: Text(
                          controller.locations[index],
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          controller.setSelectedLocation(
                            controller.locations[index],
                          );
                          Get.back();
                        },
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
