import 'dart:io';
import 'package:event_maker/core/routes/app_routes.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/data/models/certification_model.dart';
import 'package:event_maker/views/service_provider_flow/certifications/certification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewCertificateView extends GetView<CertificationController> {
  const ViewCertificateView({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    final CertificationModel? cert = args is CertificationModel
        ? args
        : controller.certifications.firstWhereOrNull(
            (c) => c.id == args.toString(),
          );

    if (cert == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          'viewCertification'.tr,
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
                  // Certificate Image
                  Container(
                    width: double.infinity,
                    height: 250.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: cert.imageUrl != null
                          ? cert.imageUrl!.startsWith('assets/')
                                ? Image.asset(cert.imageUrl!, fit: BoxFit.cover)
                                : Image.file(
                                    File(cert.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                          : Icon(
                              Icons.description,
                              size: 50.sp,
                              color: AppColors.lightGrey,
                            ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Details
                  _buildDetailField('certName'.tr, cert.title),
                  SizedBox(height: 16.h),
                  _buildDetailField('issuedBy'.tr, cert.school),
                  SizedBox(height: 16.h),
                  _buildDetailField('issueDate'.tr, cert.date),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),

          // Edit Button - Fixed at bottom
          Padding(
            padding: EdgeInsets.all(24.w),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  controller.prepareEdit(cert);
                  Get.toNamed(
                    AppRoutes.spEditCertification,
                    arguments: cert.id,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'edit'.tr,
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

  Widget _buildDetailField(String label, String value) {
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
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
