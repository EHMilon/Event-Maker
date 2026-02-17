import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_colors.dart';
import '../../../shared/widgets/primary_text_button.dart';
import 'add_service_controller.dart';

/// View for setting availability date and time for services
class DateAndTimeView extends StatefulWidget {
  const DateAndTimeView({super.key});

  @override
  State<DateAndTimeView> createState() => _DateAndTimeViewState();
}

class _DateAndTimeViewState extends State<DateAndTimeView> {
  final AddServiceController controller = Get.find<AddServiceController>();
  
  final List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  
  // Time slots for each day
  final Map<String, TimeOfDay> _startTimes = {};
  final Map<String, TimeOfDay> _endTimes = {};

  @override
  void initState() {
    super.initState();
    // Initialize default times for available days
    for (var day in controller.availability) {
      _startTimes[day] = const TimeOfDay(hour: 9, minute: 0);
      _endTimes[day] = const TimeOfDay(hour: 17, minute: 0);
    }
  }

  void _toggleDay(String day) {
    if (controller.availability.contains(day)) {
      controller.availability.remove(day);
      _startTimes.remove(day);
      _endTimes.remove(day);
    } else {
      controller.availability.add(day);
      _startTimes[day] = const TimeOfDay(hour: 9, minute: 0);
      _endTimes[day] = const TimeOfDay(hour: 17, minute: 0);
    }
  }

  Future<void> _selectStartTime(String day) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTimes[day] ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _startTimes[day] = picked;
      });
      _updateTimings(day);
    }
  }

  Future<void> _selectEndTime(String day) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTimes[day] ?? const TimeOfDay(hour: 17, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _endTimes[day] = picked;
      });
      _updateTimings(day);
    }
  }

  void _updateTimings(String day) {
    final startTime = _startTimes[day];
    final endTime = _endTimes[day];
    
    if (startTime != null && endTime != null) {
      controller.timings[day] = {
        'start': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        'end': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      };
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Availability',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Available Days',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              
              // Day selection chips
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _allDays.map((day) {
                  final isSelected = controller.availability.contains(day);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(day),
                    onSelected: (_) => _toggleDay(day),
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: GoogleFonts.inter(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              
              SizedBox(height: 32.h),
              
              // Time slots for selected days
              if (controller.availability.isNotEmpty) ...[
                Text(
                  'Set Time Slots',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                
                ...controller.availability.map((day) => _buildTimeSlotRow(day)),
              ],
              
              SizedBox(height: 40.h),
              
              PrimaryTextButton(
                text: 'Save',
                onPressed: () {
                  Get.back(result: true);
                  Get.snackbar(
                    'Success',
                    'Availability saved successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primary,
                    colorText: Colors.white,
                  );
                },
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotRow(String day) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Day label
          SizedBox(
            width: 50.w,
            child: Text(
              day,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // Start time
          Expanded(
            child: InkWell(
              onTap: () => _selectStartTime(day),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, size: 16.r, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Text(
                      _formatTime(_startTimes[day]),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SizedBox(width: 12.w),
          
          Text(
            'to',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // End time
          Expanded(
            child: InkWell(
              onTap: () => _selectEndTime(day),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, size: 16.r, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    Text(
                      _formatTime(_endTimes[day]),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
