import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/shared/widgets/primary_text_button.dart';
import 'package:event_maker/core/routes/app_routes.dart';

class BookServiceDateView extends StatefulWidget {
  const BookServiceDateView({super.key});

  @override
  State<BookServiceDateView> createState() => _BookServiceDateViewState();
}

class _BookServiceDateViewState extends State<BookServiceDateView> {
  int selectedDateIndex = 1; // Mock selection
  int selectedTimeIndex = 1; // Mock selection 10:00 AM

  // Changeable fields
  String selectedMonth = 'December';
  String selectedYear = '2025';
  String selectedDuration = '4 Hour';
  String selectedLocation = 'Sharjah, UAE';

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> years = ['2025', '2026', '2027', '2028', '2029'];

  final List<String> durations = [
    '1 Hour',
    '2 Hours',
    '3 Hours',
    '4 Hours',
    '5 Hours',
    '6 Hours',
    'Full Day',
  ];

  final List<String> locations = [
    'Sharjah, UAE',
    'Dubai, UAE',
    'Abu Dhabi, UAE',
    'Ajman, UAE',
    ' Fujairah, UAE',
    'Ras Al Khaimah, UAE',
  ];

  final List<String> times = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Book Service',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date & Time',
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
                  onTap: () => _showMonthPicker(),
                  child: Row(
                    children: [
                      Text(
                        selectedMonth,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
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
                  onTap: () => _showYearPicker(),
                  child: Row(
                    children: [
                      Text(
                        selectedYear,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
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

            // Horizontal Date Picker
            SizedBox(
              height: 80.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final isSelected = selectedDateIndex == index;
                  final day = 15 + index;
                  final weekDays = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDateIndex = index;
                      });
                    },
                    child: Container(
                      width: 60.w,
                      margin: EdgeInsets.only(right: 12.w),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
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
                                  ? Colors.white
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
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),

            Text(
              'Available Times',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),

            // Time Slots Grid
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: List.generate(times.length, (index) {
                final isSelected = selectedTimeIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTimeIndex = index;
                    });
                  },
                  child: Container(
                    width:
                        (MediaQuery.of(context).size.width - 72.w) /
                        3, // 3 columns
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.lightGrey,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      times[index],
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 24.h),

            Text(
              'Service Duration',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => _showDurationPicker(),
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
                        Text(
                          selectedDuration,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
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
              'Location',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => _showLocationPicker(),
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
                        Text(
                          selectedLocation,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
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
              text: 'Continue',
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // Picker methods
  void _showMonthPicker() {
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
                'Select Month',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final isSelected = months[index] == selectedMonth;
                    return ListTile(
                      title: Text(
                        months[index],
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
                        setState(() => selectedMonth = months[index]);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showYearPicker() {
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
                'Select Year',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final isSelected = years[index] == selectedYear;
                    return ListTile(
                      title: Text(
                        years[index],
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
                        setState(() => selectedYear = years[index]);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDurationPicker() {
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
                'Select Duration',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  itemCount: durations.length,
                  itemBuilder: (context, index) {
                    final isSelected = durations[index] == selectedDuration;
                    return ListTile(
                      leading: Icon(
                        Icons.access_time,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(
                        durations[index],
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
                        setState(() => selectedDuration = durations[index]);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationPicker() {
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
                'Select Location',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final isSelected = locations[index] == selectedLocation;
                    return ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(
                        locations[index],
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
                        setState(() => selectedLocation = locations[index]);
                        Get.back();
                      },
                    );
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
