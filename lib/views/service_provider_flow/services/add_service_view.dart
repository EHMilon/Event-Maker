import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/themes/app_colors.dart';
import '../../../data/models/service_model.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_text_button.dart';
import '../../../shared/widgets/upload_widget.dart';
import 'add_service_controller.dart';

import 'packages_pricings_view.dart';

class AddServiceView extends StatefulWidget {
  final ServiceModel? service;
  final bool isEdit;

  const AddServiceView({super.key, this.service, this.isEdit = false});

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  late final AddServiceController controller;
  final _days = [
    {'key': 'Mon', 'label': 'mon'.tr},
    {'key': 'Tue', 'label': 'tue'.tr},
    {'key': 'Wed', 'label': 'wed'.tr},
    {'key': 'Thu', 'label': 'thu'.tr},
    {'key': 'Fri', 'label': 'fri'.tr},
    {'key': 'Sat', 'label': 'sat'.tr},
    {'key': 'Sun', 'label': 'sun'.tr},
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<AddServiceController>();
    // Initialize with service data if editing
    Future.delayed(Duration.zero, () {
      if (widget.isEdit && widget.service != null) {
        controller.initWithService(widget.service!);
      }
    });
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
          widget.isEdit ? 'editService'.tr : 'addNewService'.tr,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isLoading.value,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UploadWidget(onTap: () {}),
                SizedBox(height: 16.h),
                Obx(
                  () => DropdownButtonFormField<ServiceCategory>(
                    value: controller.selectedCategory.value,
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateCategory(value);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'selectServiceType'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                    ),
                    items: ServiceCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          _categoryLabel(category),
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    dropdownColor: Colors.white,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                CustomTextField(
                  controller: controller.titleController,
                  labelText: 'serviceTitle'.tr,
                  hintText: 'serviceTitleHint'.tr,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: controller.descriptionController,
                  labelText: 'description'.tr,
                  hintText: 'descriptionHint'.tr,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: controller.locationController,
                  labelText: 'selectLocation'.tr,
                  hintText: 'selectAddressHint'.tr,
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                ),

                SizedBox(height: 16.h),
                // Text(
                //   'setTimeSlots'.tr,
                //   style: GoogleFonts.inter(
                //     fontSize: 16.sp,
                //     fontWeight: FontWeight.w600,
                //     color: AppColors.textPrimary,
                //   ),
                // ),
                _buildTimeRow(),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'cannotGoOutsideLocation'.tr,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Obx(
                      () => Switch(
                        value: controller.outsideLocation.value,
                        onChanged: (v) => controller.outsideLocation.value = v,
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildAvailabilitySection(),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'packagesPricings'.tr,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openPackages(context),
                      icon: Icon(
                        Icons.add,
                        size: 18.sp,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        'addPackage'.tr,
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                PrimaryTextButton(
                  text: widget.isEdit ? 'updateService'.tr : 'addService'.tr,
                  onPressed: () async {
                    // TODO: Implement field validation before saving
                    await controller.saveService(
                      isEdit: widget.isEdit,
                      existingService: widget.service,
                    );
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _categoryLabel(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.hospitality:
        return 'hospitality'.tr;
      case ServiceCategory.event:
        return 'event'.tr;
      case ServiceCategory.trainer:
        return 'professionalTrainer'.tr;
    }
  }

  void _openPackages(BuildContext context) {
    Get.to(() => const PackagesPricingsView());
  }

  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'availability'.tr,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        _buildDayChips(
          selectedDays: controller.availability,
          onTap: controller.togglePrimaryDay,
          canSelect: controller.canSelectPrimaryDay,
        ),
        SizedBox(height: 12.h),
        _buildAdditionalToggle(),
        Obx(
          () => controller.showAdditionalAvailability.value
              ? _buildAdditionalSection()
              : const SizedBox(),
        ),
        // SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildDayChips({
    required RxList<String> selectedDays,
    required void Function(String) onTap,
    required bool Function(String) canSelect,
    bool isSecondary = false,
  }) {
    return Obx(
      () => Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: _days.map((day) {
          final key = day['key']!;
          final isSelected = selectedDays.contains(key);
          final enabled = isSelected || canSelect(key);
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
            onTap: enabled ? () => onTap(key) : null,
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

  Widget _buildAdditionalToggle() {
    return Obx(
      () => GestureDetector(
        onTap: controller.toggleAdditionalSection,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'additionalAvailability'.tr,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Text(
                  '+ ${'add'.tr}',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  controller.showAdditionalAvailability.value
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        _buildDayChips(
          selectedDays: controller.additionalAvailability,
          onTap: controller.toggleAdditionalDay,
          canSelect: controller.canSelectAdditionalDay,
          isSecondary: true,
        ),
        SizedBox(height: 12.h),
        Text(
          'location'.tr,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: controller.additionalLocationController,
          hintText: 'Dubai',
          prefixIcon: Icon(
            Icons.location_on_outlined,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRow() {
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
              _buildTimeInput(controller.startTime),
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
              _buildTimeInput(controller.endTime),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInput(Rxn<TimeOfDay> value) {
    return Obx(
      () => GestureDetector(
        onTap: () => _pickTime(value),
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, color: AppColors.primary, size: 20.h),
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

  Future<void> _pickTime(Rxn<TimeOfDay> target) async {
    final initial = target.value ?? const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      target.value = picked;
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'select'.tr;
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
