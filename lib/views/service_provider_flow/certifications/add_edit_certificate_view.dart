import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/views/service_provider_flow/certifications/certification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEditCertificateView extends GetView<CertificationController> {
  final bool isEdit;
  final int? certificateId;

  const AddEditCertificateView({
    super.key,
    this.isEdit = false,
    this.certificateId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isEdit ? 'editCertification'.tr : 'addCertification'.tr,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
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
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.lightGrey,
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
                                  controller.imageUrl.value!.startsWith(
                                    'assets/',
                                  )
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
                                    color: AppColors.textSecondary.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'upload'.tr,
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
                                      color: AppColors.textSecondary,
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
                    'certName'.tr,
                    'Your title goes here...',
                    controller.titleController,
                  ),
                  SizedBox(height: 16.h),
                  _buildInputField(
                    'issuedBy'.tr,
                    'Institute Name',
                    controller.instituteController,
                  ),
                  SizedBox(height: 16.h),
                  _buildInputField(
                    'issueDate'.tr,
                    'dd/mm/yyyy',
                    controller.dateController,
                    isDate: true,
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),

          // Action Button - Fixed at bottom
          Padding(
            padding: EdgeInsets.all(24.w),
            child: SizedBox(
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
                  isEdit ? 'update'.tr : 'upload'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
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
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
          ),
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
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.lightGrey),
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
