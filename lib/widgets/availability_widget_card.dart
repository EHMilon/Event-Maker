import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/env_config.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/google_map.dart';

class AvailabilityCardModel {
  final String id;
  final RxList<String> selectedDays;
  final TextEditingController locationController;
  final TextEditingController addressController;
  final Rxn<TimeOfDay> startTime;
  final Rxn<TimeOfDay> endTime;
  final RxString startTimeString;
  final RxString endTimeString;
  final RxString latitude;
  final RxString longitude;
  final RxBool cannotGoOutside;
  final RxBool canGoOutside;

  AvailabilityCardModel({
    required this.id,
    List<String>? days,
    String? location,
    String? address,
    TimeOfDay? startTimeVal,
    TimeOfDay? endTimeVal,
    String? startTimeStr,
    String? endTimeStr,
    String? latitudeVal,
    String? longitudeVal,
    bool cannotGoOutsideVal = false,
    bool canGoOutsideVal = false,
  }) : selectedDays = RxList<String>(days ?? []),
       locationController = TextEditingController(text: location),
       addressController = TextEditingController(
         text: address ?? location ?? '',
       ),
       startTime = Rxn<TimeOfDay>(startTimeVal),
       endTime = Rxn<TimeOfDay>(endTimeVal),
       startTimeString = RxString(startTimeStr ?? '09:00:00'),
       endTimeString = RxString(endTimeStr ?? '17:00:00'),
       latitude = RxString(latitudeVal ?? '0.0'),
       longitude = RxString(longitudeVal ?? '0.0'),
       cannotGoOutside = RxBool(cannotGoOutsideVal),
       canGoOutside = RxBool(canGoOutsideVal);

  void dispose() {
    locationController.dispose();
    addressController.dispose();
  }
}

class AvailabilityWidgetCard extends StatefulWidget {
  final AvailabilityCardModel card;
  final List<Map<String, String>> days;
  final bool Function(String) canSelectDay;
  final void Function(String) onDayTap;
  final VoidCallback? onRemove;
  final bool showRemoveButton;
  final bool isPrimary;
  final bool isEnabled;
  final bool showCannotGoOutside;
  final bool isServiceProvider;

  const AvailabilityWidgetCard({
    super.key,
    required this.card,
    required this.days,
    required this.canSelectDay,
    required this.onDayTap,
    this.onRemove,
    this.showRemoveButton = false,
    this.isPrimary = false,
    this.isEnabled = true,
    this.showCannotGoOutside = true,
    this.isServiceProvider = false,
  });

  @override
  State<AvailabilityWidgetCard> createState() => _AvailabilityWidgetCardState();
}

class _AvailabilityWidgetCardState extends State<AvailabilityWidgetCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: widget.isEnabled ? 1.0 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and remove button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isPrimary
                      ? 'availability'.tr
                      : 'additionalAvailability'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (widget.showRemoveButton)
                  GestureDetector(
                    onTap: widget.isEnabled ? widget.onRemove : null,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.r,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            // Day selection chips
            _buildDayChips(),
            SizedBox(height: 16.h),

            // Time row
            _buildTimeRow(context),
            SizedBox(height: 16.h),

            // Location field
            Text(
              'selectLocation'.tr,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: widget.isEnabled ? () => _openMapScreen(context) : null,
              child: AbsorbPointer(
                absorbing: true,
                child: CustomTextField(
                  controller: widget.card.addressController,
                  hintText: 'selectAddressHint'.tr,
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Cannot go outside location toggle (only for primary card)
            if (widget.showCannotGoOutside)
              Column(
                children: [
                  // Can't go outside option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'cannotGoOutsideLocation'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Obx(
                        () => Switch(
                          value: widget.card.cannotGoOutside.value,
                          onChanged: widget.isEnabled
                              ? (v) {
                                  widget.card.cannotGoOutside.value = v;
                                  // If enabling cannot go outside, disable can go outside
                                  if (v) {
                                    widget.card.canGoOutside.value = false;
                                  }
                                }
                              : null,
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Can go outside option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'canGoOutsideLocation'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Obx(
                        () => Switch(
                          value: widget.card.canGoOutside.value,
                          onChanged: widget.isEnabled
                              ? (v) {
                                  widget.card.canGoOutside.value = v;
                                  // If enabling can go outside, disable cannot go outside
                                  if (v) {
                                    widget.card.cannotGoOutside.value = false;
                                  }
                                }
                              : null,
                          activeThumbColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChips() {
    return Obx(
      () => Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: widget.days.map((day) {
          final key = day['key']!;
          final isSelected = widget.card.selectedDays.contains(key);
          final enabled =
              widget.isEnabled && (isSelected || widget.canSelectDay(key));
          final backgroundColor = isSelected
              ? AppColors.primary.withOpacity(0.15)
              : enabled
              ? Colors.white
              : AppColors.lightGrey;
          final borderColor = isSelected
              ? AppColors.primary
              : enabled
              ? AppColors.borderLight
              : AppColors.lightGrey;
          final textColor = isSelected
              ? AppColors.primary
              : enabled
              ? AppColors.textSecondary
              : AppColors.grey;
          return GestureDetector(
            onTap: enabled ? () => widget.onDayTap(key) : null,
            child: Container(
              width: 48.w,
              height: 40.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: backgroundColor,
                border: Border.all(color: borderColor),
              ),
              child: Text(
                day['label']!,
                style: GoogleFonts.inter(color: textColor, fontSize: 12.sp),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'startTime'.tr,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              _buildTimeInput(context, widget.card.startTime),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'endTime'.tr,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              _buildTimeInput(context, widget.card.endTime),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInput(BuildContext context, Rxn<TimeOfDay> value) {
    return Obx(
      () => GestureDetector(
        onTap: widget.isEnabled ? () => _pickTime(context, value) : null,
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: widget.isEnabled
                  ? AppColors.borderLight
                  : AppColors.lightGrey,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                color: widget.isEnabled ? AppColors.primary : AppColors.grey,
                size: 20.h,
              ),
              SizedBox(width: 10.w),
              Text(
                value.value == null ? 'select'.tr : _formatTime(value.value),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: value.value == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, Rxn<TimeOfDay> target) async {
    final initial = target.value ?? const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      // Basic validation check
      if (target == widget.card.startTime &&
          widget.card.endTime.value != null) {
        if (!_isBefore(picked, widget.card.endTime.value!)) {
          Get.snackbar(
            'invalidTime'.tr,
            'startTimeBeforeEndTime'.tr,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
          return;
        }
      } else if (target == widget.card.endTime &&
          widget.card.startTime.value != null) {
        if (!_isBefore(widget.card.startTime.value!, picked)) {
          Get.snackbar(
            'invalidTime'.tr,
            'startTimeBeforeEndTime'.tr,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
          return;
        }
      }
      target.value = picked;

      // Update string representation for consistency
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      if (target == widget.card.startTime) {
        widget.card.startTimeString.value = formattedTime;
      } else {
        widget.card.endTimeString.value = formattedTime;
      }
    }
  }

  bool _isBefore(TimeOfDay start, TimeOfDay end) {
    final startMin = start.hour * 60 + start.minute;
    final endMin = end.hour * 60 + end.minute;
    return startMin < endMin;
  }

  void _openMapScreen(BuildContext context) {
    Get.to(
      GoogleMapScreen(
        apiKey: EnvConfig.googleMapsApiKey,
        onLocationSelect: (location) {
          // Update the address controller with selected location name
          widget.card.addressController.text = location.name;
          // Update latitude and longitude
          widget.card.latitude.value = location.position.latitude.toString();
          widget.card.longitude.value = location.position.longitude.toString();
        },
      ),
    );
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'select'.tr;
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
