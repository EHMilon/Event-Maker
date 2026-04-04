import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_maker/constants/app_colors.dart';
import 'package:event_maker/widgets/primary_text_button.dart';
import 'package:event_maker/app_routes.dart';
import 'package:event_maker/views/customer_flow/service_booking/service_booking_controller.dart';

class BookServiceRequestView extends StatelessWidget {
  const BookServiceRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceBookingController>();
    final specialRequestText = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'bookService'.tr,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'additionalRequest'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Text(
                    'specialRequests'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Text Area
                  Container(
                    height: 150.h,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: TextField(
                      controller: specialRequestText,
                      maxLines: null,
                      decoration: InputDecoration.collapsed(
                        hintText: 'specialRequestsHint'.tr,
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),

                  // Show error if any
                  if (controller.errorMessage.isNotEmpty) ...[
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        controller.errorMessage.value,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),
                ],
              ),
            ),
            // Loading overlay
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(
          () => PrimaryTextButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    // Set the special request
                    controller.setSpecialRequest(specialRequestText.text);
                    // Submit booking and navigate to next screen
                    await controller.navigateToNextScreen();
                  },
            text: 'continueText'.tr,
          ),
        ),
      ),
    );
  }
}
