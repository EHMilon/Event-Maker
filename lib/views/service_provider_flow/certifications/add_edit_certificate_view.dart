import 'dart:io';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/service_provider_flow/certifications/certification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEditCertificateView extends GetView<CertificationController> {
  final bool isEdit;
  final String? certificateId;

  const AddEditCertificateView({
    super.key,
    this.isEdit = false,
    this.certificateId,
  });

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
          isEdit ? 'Edit Certificate' : 'Add Certificate',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Area
            GestureDetector(
              onTap: () => controller.pickImage(),
              child: Obx(
                () => Container(
                  width: double.infinity,
                  height: 180.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: controller.selectedImage.value != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.file(
                            controller.selectedImage.value!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : controller.imageUrl.value != null &&
                            controller.imageUrl.value!.startsWith('assets/')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.asset(
                            controller.imageUrl.value!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 40.sp,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Upload',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'PDF, JPG or PNG',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Form Fields
            _buildInputField(
              'Document Title',
              'Your title goes here...',
              controller.titleController,
            ),
            SizedBox(height: 16.h),
            _buildInputField(
              'Institute',
              'Institute Name',
              controller.instituteController,
            ),
            SizedBox(height: 16.h),
            _buildInputField(
              'Passing Year',
              'dd/mm/yyyy',
              controller.dateController,
              isDate: true,
            ),

            SizedBox(height: 100.h),
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  if (isEdit) {
                    controller.updateCertification(certificateId!);
                  } else {
                    controller.addCertification();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  isEdit ? 'Update' : 'Upload',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController textController, {
    bool isDate = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: textController,
          readOnly: isDate,
          onTap: isDate
              ? () async {
                  final date = await showDatePicker(
                    context: Get.context!,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) {
                    textController.text =
                        "${date.day}/${date.month}/${date.year}";
                  }
                }
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey.shade400,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            prefixIcon: isDate
                ? const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primary,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
