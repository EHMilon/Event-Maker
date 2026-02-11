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

import 'date_and_time_view.dart';
import 'packages_pricings_view.dart';

class AddServiceView extends StatefulWidget {
  final ServiceModel? service;
  final bool isEdit;

  const AddServiceView({
    super.key,
    this.service,
    this.isEdit = false,
  });

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  late final AddServiceController controller;

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
          widget.isEdit ? 'Edit Service' : 'Add New Service',
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
                SizedBox(height: 24.h),
                CustomTextField(
                  controller: controller.titleController,
                  labelText: 'Service Title',
                  hintText: 'Your title goes here...',
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: controller.descriptionController,
                  labelText: 'Description',
                  hintText: 'Your description goes here...',
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: controller.locationController,
                  labelText: 'Select location',
                  hintText: 'Select address',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Can\'t go outside the location',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Availability',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openAvailability(context),
                      child: Text(
                        'Edit',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildAvailabilityPreview(),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Packages & Pricings',
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
                        'Add Package',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                PrimaryTextButton(
                  text: widget.isEdit ? 'Update Service' : 'Add Service',
                  onPressed: () async {
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

  Widget _buildAvailabilityPreview() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((day) {
          final isSelected = controller.availability.contains(day);
          return Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected ? AppColors.primary : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openAvailability(BuildContext context) {
    Get.to(() => const DateAndTimeView());
  }

  void _openPackages(BuildContext context) {
    Get.to(() => const PackagesPricingsView());
  }
}
