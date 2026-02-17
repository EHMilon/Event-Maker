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
import 'add_event_controller.dart';

class AddEventView extends StatefulWidget {
  final ServiceModel? service;
  final bool isEdit;

  const AddEventView({
    super.key,
    this.service,
    this.isEdit = false,
  });

  @override
  State<AddEventView> createState() => _AddEventViewState();
}

class _AddEventViewState extends State<AddEventView> {
  late final AddEventController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AddEventController>();
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
          widget.isEdit ? 'Edit Event' : 'Add New Event',
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
                  labelText: 'Event title',
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
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: controller.timeController,
                        labelText: 'Select Time',
                        hintText: 'Select',
                        prefixIcon: Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                          size: 20.r,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: CustomTextField(
                        controller: controller.dateController,
                        labelText: 'Select Date',
                        hintText: 'dd/mm/yyyy',
                        prefixIcon: Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                          size: 20.r,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: controller.chargesController,
                  labelText: 'Event charges per hour',
                  hintText: '00.00',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(14.r),
                    child: Text(
                      r'$',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  controller: controller.capacityController,
                  labelText: 'Attendee capacity',
                  hintText: '250',
                  prefixIcon: Icon(
                    Icons.people_outline,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 40.h),
                PrimaryTextButton(
                  text: widget.isEdit ? 'Update Event' : 'Add Event',
                  onPressed: () async {
                    await controller.addEvent(
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
}
