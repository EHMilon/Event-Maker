import 'package:event_maker/core/routes/app_routes.dart';
import 'package:event_maker/core/themes/app_colors.dart';
import 'package:event_maker/views/service_provider_flow/certifications/certification_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CertificationListView extends GetView<CertificationController> {
  const CertificationListView({super.key});

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
          'Certification',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: ElevatedButton(
              onPressed: () {
                controller.clearFields();
                Get.toNamed(AppRoutes.spAddCertification);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, size: 18.sp, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text(
                    'Add',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () => Skeletonizer(
          enabled: controller.isLoading.value,
          child: ListView.builder(
            padding: EdgeInsets.all(24.w),
            itemCount: controller.certifications.length,
            itemBuilder: (context, index) {
              final cert = controller.certifications[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: InkWell(
                  onTap: () => Get.toNamed(
                    AppRoutes.spViewCertification,
                    arguments: cert,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cert.title,
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        cert.date,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        cert.school,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
