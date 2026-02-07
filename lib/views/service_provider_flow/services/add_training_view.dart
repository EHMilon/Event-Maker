import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/themes/app_colors.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_text_button.dart';
import '../../../shared/widgets/upload_widget.dart';
import 'add_training_controller.dart';

class AddTrainingView extends GetView<AddTrainingController> {
  const AddTrainingView({super.key});

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
          'Add New Training',
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
                  labelText: 'Training title',
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
                        onChanged: (v) {}, // TODO: Show time picker
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
                        onChanged: (v) {}, // TODO: Show date picker
                      ),
                    ),
                  ],
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
                SizedBox(height: 40.h),
                PrimaryTextButton(
                  text: 'Add Training',
                  onPressed: () => controller.addTraining(),
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
